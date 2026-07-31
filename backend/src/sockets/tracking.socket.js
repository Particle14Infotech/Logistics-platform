const Driver = require('../models/driver.model');
const Order = require('../models/order.model');
const Message = require('../models/message.model');
const { sendToUser } = require('../services/notification.service');

// Rooms are keyed by bookingId so only the relevant customer/driver/admin receive updates.
module.exports = function registerTrackingHandlers(io, socket) {
  // Customer/driver join a booking's tracking room
  socket.on('join_booking_room', ({ bookingId }) => {
    socket.join(`booking:${bookingId}`);
  });

  socket.on('leave_booking_room', ({ bookingId }) => {
    socket.leave(`booking:${bookingId}`);
  });

  // Driver app emits GPS every 3-5 seconds
  socket.on('driver_location_update', async ({ bookingId, lat, lng }) => {
    try {
      if (socket.user?.role !== 'driver') return;

      // Persist last known location (consider Redis for high write throughput)
      await Driver.findOneAndUpdate(
        { userId: socket.user.id },
        { currentLocation: { type: 'Point', coordinates: [lng, lat] } }
      );

      // Broadcast to everyone in this booking's room (customer + admin live map)
      io.to(`booking:${bookingId}`).emit('location_broadcast', {
        bookingId,
        lat,
        lng,
        timestamp: Date.now(),
      });
    } catch (err) {
      console.error('driver_location_update error:', err.message);
    }
  });

  // Customer app broadcasts its own live GPS too, while a trip is active -
  // a distinct event from driver_location_update/location_broadcast (the
  // driver's own position, persisted to Driver.currentLocation) since a
  // customer's live position isn't meaningful outside this one active
  // trip and has nowhere sensible to persist to. Purely a real-time relay;
  // whoever's in the room (currently just the driver app, if it listens)
  // gets it live with no database write.
  socket.on('customer_location_update', ({ bookingId, lat, lng }) => {
    if (socket.user?.role !== 'customer') return;
    io.to(`booking:${bookingId}`).emit('customer_location_broadcast', {
      bookingId,
      lat,
      lng,
      timestamp: Date.now(),
    });
  });

  // Order status transitions also propagate via sockets
  socket.on('order_status_update', ({ bookingId, status }) => {
    io.to(`booking:${bookingId}`).emit('status_broadcast', { bookingId, status, timestamp: Date.now() });
  });

  // In-trip chat between the customer and the assigned driver, scoped to
  // one booking. Persists to Message (durable history + offline delivery)
  // and broadcasts to whoever's currently in the room (real-time delivery
  // to the other party if their chat screen is open).
  socket.on('chat_message', async ({ bookingId, text }) => {
    try {
      if (!socket.user?.id || !text?.trim()) return;

      const order = await Order.findById(bookingId).populate('driverId', 'userId');
      if (!order) return;

      const isCustomer = String(order.customerId) === String(socket.user.id);
      const isDriver = order.driverId?.userId && String(order.driverId.userId) === String(socket.user.id);
      if (!isCustomer && !isDriver) return;

      const senderRole = isCustomer ? 'customer' : 'driver';
      const message = await Message.create({
        bookingId,
        senderId: socket.user.id,
        senderRole,
        text: text.trim(),
      });

      const payload = {
        id: message._id,
        bookingId,
        senderId: String(socket.user.id),
        senderRole,
        text: message.text,
        createdAt: message.createdAt,
      };
      io.to(`booking:${bookingId}`).emit('chat_message', payload);

      // Best-effort push to the other party, in case their chat screen
      // isn't open right now to catch the socket broadcast above.
      const recipientId = isCustomer ? order.driverId?.userId : order.customerId;
      if (recipientId) {
        sendToUser(recipientId, {
          title: 'New message',
          body: text.trim().slice(0, 100),
          data: { bookingId: String(bookingId), type: 'chat_message' },
        });
      }
    } catch (err) {
      console.error('chat_message error:', err.message);
    }
  });
};

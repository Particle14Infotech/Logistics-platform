const Driver = require('../models/driver.model');
const Order = require('../models/order.model');
const Message = require('../models/message.model');
const Enterprise = require('../models/enterprise.model');
const { sendToUser } = require('../services/notification.service');

// Same "who's allowed to see/act on this booking" rule used throughout
// booking.controller.js/enterprise.controller.js (owner, assigned driver,
// admin, or a member of the owning enterprise) - centralized here so every
// room-scoped socket event enforces it consistently, instead of trusting
// whoever happens to ask to join a room.
async function isAuthorizedForBooking(order, user) {
  if (!order || !user) return false;
  if (user.role === 'admin') return true;
  if (String(order.customerId) === String(user.id)) return true;
  if (order.driverId?.userId && String(order.driverId.userId) === String(user.id)) return true;
  if (order.enterpriseId) {
    const enterprise = await Enterprise.findOne({
      _id: order.enterpriseId,
      $or: [{ adminUserId: user.id }, { subUsers: user.id }],
    });
    if (enterprise) return true;
  }
  return false;
}

// Rooms are keyed by bookingId so only the relevant customer/driver/admin receive updates.
module.exports = function registerTrackingHandlers(io, socket) {
  // Customer/driver/admin/enterprise join a booking's tracking room - gated
  // so an unrelated authenticated user can't join an arbitrary bookingId
  // (e.g. one seen in a shared link or bookmarked URL) and silently
  // eavesdrop on someone else's live location and chat.
  socket.on('join_booking_room', async ({ bookingId }) => {
    try {
      const order = await Order.findById(bookingId).populate('driverId', 'userId');
      if (!(await isAuthorizedForBooking(order, socket.user))) return;
      socket.join(`booking:${bookingId}`);
    } catch (err) {
      console.error('join_booking_room error:', err.message);
    }
  });

  socket.on('leave_booking_room', ({ bookingId }) => {
    socket.leave(`booking:${bookingId}`);
  });

  // Driver app emits GPS every 3-5 seconds
  socket.on('driver_location_update', async ({ bookingId, lat, lng }) => {
    try {
      if (socket.user?.role !== 'driver') return;

      // Confirm this driver is actually the one assigned to this booking -
      // otherwise any driver account could broadcast a fake position into
      // an order that isn't theirs.
      const order = await Order.findById(bookingId).populate('driverId', 'userId');
      if (!order?.driverId?.userId || String(order.driverId.userId) !== String(socket.user.id)) return;

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
  socket.on('customer_location_update', async ({ bookingId, lat, lng }) => {
    try {
      if (socket.user?.role !== 'customer') return;

      // Confirm this is actually the booking's own customer, not just any
      // customer-role account, before relaying a position into the room.
      const order = await Order.findById(bookingId);
      if (!order || String(order.customerId) !== String(socket.user.id)) return;

      io.to(`booking:${bookingId}`).emit('customer_location_broadcast', {
        bookingId,
        lat,
        lng,
        timestamp: Date.now(),
      });
    } catch (err) {
      console.error('customer_location_update error:', err.message);
    }
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

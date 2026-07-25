const Driver = require('../models/driver.model');

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

  // Order status transitions also propagate via sockets
  socket.on('order_status_update', ({ bookingId, status }) => {
    io.to(`booking:${bookingId}`).emit('status_broadcast', { bookingId, status, timestamp: Date.now() });
  });
};

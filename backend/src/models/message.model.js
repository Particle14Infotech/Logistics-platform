const mongoose = require('mongoose');

// In-trip chat between a customer and driver, scoped to one order. Real-time
// delivery happens over the same Socket.IO booking room already used for
// live GPS/status broadcasts (see sockets/tracking.socket.js); this is the
// durable copy backing history for whoever opens the chat screen later or
// was offline when a message arrived.
const messageSchema = new mongoose.Schema(
  {
    bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true, index: true },
    senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    senderRole: { type: String, enum: ['customer', 'driver'], required: true },
    text: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Message', messageSchema);

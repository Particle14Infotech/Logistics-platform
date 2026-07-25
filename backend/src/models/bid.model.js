const mongoose = require('mongoose');

const bidSchema = new mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true },
    amount: { type: Number, required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
  },
  { timestamps: true }
);

bidSchema.index({ orderId: 1, driverId: 1 }, { unique: true });

module.exports = mongoose.model('Bid', bidSchema);

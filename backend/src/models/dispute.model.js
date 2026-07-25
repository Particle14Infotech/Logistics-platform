const mongoose = require('mongoose');

const disputeSchema = new mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    raisedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    raisedByRole: { type: String, enum: ['customer', 'driver'], required: true },
    category: {
      type: String,
      enum: ['payment', 'damage', 'delay', 'behavior', 'pricing', 'other'],
      default: 'other',
    },
    description: { type: String, required: true },
    status: { type: String, enum: ['open', 'investigating', 'resolved', 'rejected'], default: 'open' },
    resolutionNote: String,
    resolvedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    resolvedAt: Date,
  },
  { timestamps: true }
);

module.exports = mongoose.model('Dispute', disputeSchema);

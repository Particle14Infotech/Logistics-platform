const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    razorpayOrderId: String,
    razorpayPaymentId: String,
    razorpaySignature: String,
    amount: { type: Number, required: true }, // in paise
    currency: { type: String, default: 'INR' },
    status: { type: String, enum: ['created', 'captured', 'failed', 'refunded'], default: 'created' },
    refundId: String,
    // In paise, same unit as amount - absent/equal to amount for a full
    // refund, less than amount when a driver cancellation fee was withheld.
    refundedAmount: Number,
  },
  { timestamps: true }
);

module.exports = mongoose.model('Payment', paymentSchema);

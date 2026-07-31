const mongoose = require('mongoose');

// Append-only ledger backing Driver.walletBalance - every credit (trip
// earning, cancellation compensation) and debit (payout) gets a row here,
// so a driver/admin can see a full breakdown instead of just a running
// total. balanceAfter is a snapshot for cheap history display without
// re-summing the whole ledger every time.
const walletTransactionSchema = new mongoose.Schema(
  {
    driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true },
    type: {
      type: String,
      enum: ['trip_earning', 'cancellation_compensation', 'payout', 'adjustment'],
      required: true,
    },
    // Positive for a credit (trip_earning, cancellation_compensation,
    // upward adjustment), negative for a debit (payout, downward adjustment).
    amount: { type: Number, required: true },
    balanceAfter: { type: Number, required: true },
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', default: null },
    note: String,
  },
  { timestamps: true }
);

walletTransactionSchema.index({ driverId: 1, createdAt: -1 });

module.exports = mongoose.model('WalletTransaction', walletTransactionSchema);

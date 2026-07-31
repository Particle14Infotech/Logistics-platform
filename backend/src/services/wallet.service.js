const Driver = require('../models/driver.model');
const WalletTransaction = require('../models/walletTransaction.model');

// Applies a wallet credit/debit and records the ledger entry in one place,
// so driver.controller.js (trip earnings) and booking.controller.js
// (cancellation compensation) and admin payouts all stay consistent.
// amount: positive to credit, negative to debit. Uses $inc (atomic at the
// DB level) rather than read-modify-save, so concurrent transactions on
// the same driver can't race and drop an update.
exports.applyWalletTransaction = async ({ driverId, type, amount, orderId = null, note }) => {
  const driver = await Driver.findByIdAndUpdate(driverId, { $inc: { walletBalance: amount } }, { new: true });
  if (!driver) throw new Error(`Driver ${driverId} not found for wallet transaction`);

  await WalletTransaction.create({ driverId, type, amount, balanceAfter: driver.walletBalance, orderId, note });

  return driver;
};

// Shared by booking.controller.js (driver cancellation compensation) and
// COD order creation (advance amount collected online upfront) - both use
// the exact same formula on purpose: the COD advance is sized so that if
// the customer cancels after a driver accepts, the whole advance becomes
// the driver's compensation with nothing left to refund (see cancel()'s
// refund-amount comment in booking.controller.js).
const DRIVER_COMPENSATION_CAP = 300;

// 50% of the order value, capped at DRIVER_COMPENSATION_CAP - so a
// low-value order is never penalized more than half its own price, and a
// high-value order's fee/advance doesn't feel excessive.
function calculateCappedHalf(price) {
  return Math.min(DRIVER_COMPENSATION_CAP, Math.round(price * 0.5));
}

module.exports = { DRIVER_COMPENSATION_CAP, calculateCappedHalf };

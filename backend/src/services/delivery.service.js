const { sendToUser } = require('./notification.service');
const { applyWalletTransaction } = require('./wallet.service');

// Shared by driver.controller.js's uploadPod (cod / ungated / already-paid
// online orders, completed immediately) and payment.controller.js's
// verify/webhook (gated online orders, once the remainder payment lands
// while the order was sitting in 'awaiting_payment') - both paths converge
// here once a trip is actually finished, so wallet crediting, driver
// stats, and the customer notification only ever happen in one place.
async function completeDelivery({ order, driver, io }) {
  order.status = 'delivered';
  order.timeline.push({ status: 'delivered', note: 'Delivery confirmed' });
  await order.save();

  driver.totalTrips += 1;
  driver.totalEarnings += order.price;
  await driver.save();

  // For a cod order the driver already has the cash portion physically in
  // hand - only the advance (which the platform actually collected via
  // Razorpay) is money the platform owes back to the driver. Online orders
  // always credit the full price - the platform captured all of it,
  // whether in one payment (ungated) or two (gated advance + remainder).
  const walletCredit = order.paymentMethod === 'cod' ? order.advanceAmount : order.price;
  if (walletCredit > 0) {
    await applyWalletTransaction({
      driverId: driver._id,
      type: 'trip_earning',
      amount: walletCredit,
      orderId: order._id,
      note: order.paymentMethod === 'cod' ? 'Trip fare (advance - remainder collected in cash)' : 'Trip fare',
    });
  }

  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'delivered', timestamp: Date.now() });
  sendToUser(order.customerId, {
    title: 'Delivered!',
    body: 'Your shipment has been delivered successfully.',
    data: { bookingId: String(order._id), status: 'delivered' },
  });
}

module.exports = { completeDelivery };

const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Payment = require('../models/payment.model');
const User = require('../models/user.model');
const Driver = require('../models/driver.model');
const razorpayService = require('../services/razorpay.service');
const { completeDelivery } = require('../services/delivery.service');
const { notifyEligibleDriversOfNewJob } = require('../services/notification.service');

// POST /api/v1/payment/create-order  { orderId }
exports.createOrder = catchAsync(async (req, res) => {
  const { orderId } = req.body;
  if (!orderId) throw new AppError('orderId is required', 400);

  const order = await Order.findById(orderId);
  if (!order) throw new AppError('Booking not found', 404);
  if (String(order.customerId) !== String(req.user.id)) throw new AppError('Not authorized', 403);

  // order.advanceAmount was already computed (and locked in) at booking
  // time - see booking.controller.js's create(). Gated types only charge
  // that here, for either payment method - the rest is collected in cash
  // at delivery (cod) or via a second Razorpay payment near delivery
  // (online, see createRemainderOrder). Ungated types still pay the full
  // price in one shot, as before.
  const gated = order.advanceAmount > 0;
  if (order.paymentMethod === 'cod' && !gated) {
    throw new AppError('No online payment is required for this booking - the full amount is collected in cash at delivery', 400);
  }
  if (order.paymentStatus === 'paid') {
    throw new AppError(gated ? 'The advance for this booking is already paid' : 'This booking is already paid', 400);
  }

  const amountPaise = Math.round((gated ? order.advanceAmount : order.price) * 100);

  let razorpayOrder;
  try {
    razorpayOrder = await razorpayService.createRazorpayOrder({
      amountPaise,
      receipt: `order_${order._id}`,
      notes: { orderId: String(order._id), customerId: String(req.user.id) },
    });
  } catch (err) {
    if (err.message?.includes('not configured')) {
      throw new AppError('Payments are not set up on this server yet - add RAZORPAY_KEY_ID/SECRET to backend/.env', 503);
    }
    throw new AppError('Could not create payment order. Try again.', 502);
  }

  // Upsert in case the customer retries create-order for the same booking
  // (e.g. previous attempt's checkout was dismissed) rather than piling up
  // duplicate 'created' rows.
  const payment = await Payment.findOneAndUpdate(
    { orderId: order._id, status: 'created', purpose: { $ne: 'remainder' } },
    { userId: req.user.id, razorpayOrderId: razorpayOrder.id, amount: amountPaise, status: 'created', purpose: gated ? 'advance' : 'full' },
    { new: true, upsert: true }
  );

  // Best-effort - opening checkout with a customer_id is what lets it offer
  // "save this card" / show previously-saved cards, but a hiccup creating
  // the Razorpay customer must never block the actual payment itself.
  let customerId;
  try {
    const user = await User.findById(req.user.id);
    customerId = await razorpayService.ensureCustomer(user);
  } catch (err) {
    console.error('[payment.controller] ensureCustomer failed:', err.message);
  }

  return success(
    res,
    {
      razorpayOrderId: razorpayOrder.id,
      amount: amountPaise,
      currency: 'INR',
      keyId: process.env.RAZORPAY_KEY_ID,
      paymentId: payment._id,
      customerId,
    },
    'Payment order created',
    201
  );
});

// POST /api/v1/payment/create-remainder-order  { orderId }
// Only for gated 'online' orders - after the advance is captured
// (createOrder above), this charges the remaining amount. Paying it is
// what completes the delivery once the driver has confirmed drop-off (see
// verify()/webhook() below and driver.controller.js's uploadPod).
exports.createRemainderOrder = catchAsync(async (req, res) => {
  const { orderId } = req.body;
  if (!orderId) throw new AppError('orderId is required', 400);

  const order = await Order.findById(orderId);
  if (!order) throw new AppError('Booking not found', 404);
  if (String(order.customerId) !== String(req.user.id)) throw new AppError('Not authorized', 403);

  if (order.paymentMethod !== 'online' || order.advanceAmount <= 0) {
    throw new AppError('No remainder payment is required for this booking', 400);
  }
  if (order.paymentStatus !== 'paid') throw new AppError('Pay the advance first', 400);
  if (order.remainderPaid) throw new AppError('The remaining amount has already been paid', 400);

  const amountPaise = Math.round((order.price - order.advanceAmount) * 100);

  let razorpayOrder;
  try {
    razorpayOrder = await razorpayService.createRazorpayOrder({
      amountPaise,
      receipt: `order_${order._id}_remainder`,
      notes: { orderId: String(order._id), customerId: String(req.user.id) },
    });
  } catch (err) {
    if (err.message?.includes('not configured')) {
      throw new AppError('Payments are not set up on this server yet - add RAZORPAY_KEY_ID/SECRET to backend/.env', 503);
    }
    throw new AppError('Could not create payment order. Try again.', 502);
  }

  const payment = await Payment.findOneAndUpdate(
    { orderId: order._id, status: 'created', purpose: 'remainder' },
    { userId: req.user.id, razorpayOrderId: razorpayOrder.id, amount: amountPaise, status: 'created', purpose: 'remainder' },
    { new: true, upsert: true }
  );

  let customerId;
  try {
    const user = await User.findById(req.user.id);
    customerId = await razorpayService.ensureCustomer(user);
  } catch (err) {
    console.error('[payment.controller] ensureCustomer failed:', err.message);
  }

  return success(
    res,
    {
      razorpayOrderId: razorpayOrder.id,
      amount: amountPaise,
      currency: 'INR',
      keyId: process.env.RAZORPAY_KEY_ID,
      paymentId: payment._id,
      customerId,
    },
    'Remainder payment order created',
    201
  );
});

// POST /api/v1/payment/verify  { razorpay_order_id, razorpay_payment_id, razorpay_signature }
// Called directly by the client immediately after Razorpay Checkout
// succeeds. The webhook below is the more reliable path for production
// (doesn't depend on the client staying connected), but needs a public URL
// - use ngrok or similar to test it locally, since Razorpay can't reach
// localhost directly.
exports.verify = catchAsync(async (req, res) => {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
  if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
    throw new AppError('Missing Razorpay payment fields', 400);
  }

  const valid = razorpayService.verifySignature({
    orderId: razorpay_order_id,
    paymentId: razorpay_payment_id,
    signature: razorpay_signature,
  });
  if (!valid) throw new AppError('Payment signature verification failed', 400);

  const payment = await Payment.findOne({ razorpayOrderId: razorpay_order_id });
  if (!payment) throw new AppError('Payment record not found', 404);

  // Idempotency: the client callback (this endpoint) and the Razorpay
  // webhook both fire for the same successful payment in normal operation,
  // and a client could legitimately retry this call too - without this
  // guard, re-processing an already-captured payment could re-enter the
  // remainder-completes-delivery branch below and double-credit the
  // driver's wallet (see completeDelivery).
  if (payment.status === 'captured') {
    return success(res, { payment }, 'Payment verified');
  }

  payment.razorpayPaymentId = razorpay_payment_id;
  payment.razorpaySignature = razorpay_signature;
  payment.status = 'captured';
  await payment.save();

  if (payment.purpose === 'remainder') {
    // Paying the remainder is what completes the delivery, if the driver
    // already confirmed drop-off (order sitting in 'awaiting_payment').
    // Atomically claim that transition - only one of two concurrent
    // callers (this callback vs. the webhook, which can arrive within
    // milliseconds of each other) can find a matching document, so
    // completeDelivery only ever runs once for a given payment.
    const claimedOrder = await Order.findOneAndUpdate(
      { _id: payment.orderId, status: 'awaiting_payment' },
      { remainderPaid: true, status: 'delivered' },
      { new: true }
    );
    if (claimedOrder) {
      const driver = await Driver.findById(claimedOrder.driverId);
      if (driver) await completeDelivery({ order: claimedOrder, driver, io: req.app.get('io') });
    } else {
      // Paid before the driver confirmed drop-off - just record it,
      // uploadPod will complete the delivery once that happens.
      await Order.updateOne({ _id: payment.orderId }, { remainderPaid: true });
    }
  } else {
    const updatedOrder = await Order.findByIdAndUpdate(payment.orderId, { paymentStatus: 'paid' }, { new: true });
    // A gated order (any paymentMethod) only becomes visible to drivers once
    // its advance is paid (see driver.controller.js's availableOrders) - it
    // was never announced at creation for exactly that reason
    // (booking.controller.js's create()), so this is the first and only
    // moment drivers should be notified about it. Ungated orders
    // (advanceAmount 0) were already announced at creation, so skip
    // re-notifying them here.
    if (updatedOrder && updatedOrder.advanceAmount > 0) {
      notifyEligibleDriversOfNewJob(updatedOrder).catch(() => {});
    }
  }

  return success(res, { payment }, 'Payment verified');
});

// POST /api/v1/payment/webhook - Razorpay server-to-server event delivery.
// Configure this URL + RAZORPAY_WEBHOOK_SECRET in the Razorpay dashboard.
// Not behind `protect` - Razorpay authenticates via the signature instead
// of a user JWT. Relies on req.rawBody, captured by app.js's express.json
// verify callback (signature verification needs the exact raw bytes, which
// a re-serialized parsed body wouldn't reproduce reliably).
exports.webhook = catchAsync(async (req, res) => {
  const signature = req.headers['x-razorpay-signature'];
  const isValid = razorpayService.verifyWebhookSignature(req.rawBody, signature);
  if (!isValid) throw new AppError('Invalid webhook signature', 400);

  const event = req.body.event;
  const paymentEntity = req.body.payload?.payment?.entity;

  if (event === 'payment.captured' && paymentEntity) {
    const payment = await Payment.findOne({ razorpayOrderId: paymentEntity.order_id });
    if (payment && payment.status !== 'captured') {
      payment.razorpayPaymentId = paymentEntity.id;
      payment.status = 'captured';
      await payment.save();

      if (payment.purpose === 'remainder') {
        // Same atomic claim as verify() - see the comment there. Guards
        // against this webhook and a client verify() call racing for the
        // same payment.
        const claimedOrder = await Order.findOneAndUpdate(
          { _id: payment.orderId, status: 'awaiting_payment' },
          { remainderPaid: true, status: 'delivered' },
          { new: true }
        );
        if (claimedOrder) {
          const driver = await Driver.findById(claimedOrder.driverId);
          if (driver) await completeDelivery({ order: claimedOrder, driver, io: req.app.get('io') });
        } else {
          await Order.updateOne({ _id: payment.orderId }, { remainderPaid: true });
        }
      } else {
        await Order.findByIdAndUpdate(payment.orderId, { paymentStatus: 'paid' });
      }
    }
  } else if (event === 'payment.failed' && paymentEntity) {
    await Payment.findOneAndUpdate({ razorpayOrderId: paymentEntity.order_id }, { status: 'failed' });
  }

  return success(res, null, 'Webhook processed');
});

// POST /api/v1/payment/refund  { orderId }
exports.refund = catchAsync(async (req, res) => {
  const { orderId } = req.body;
  const order = await Order.findById(orderId);
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  if (!isOwner && req.user.role !== 'admin') throw new AppError('Not authorized', 403);

  // A gated online order can have two captured payments (advance +
  // remainder, if paid early) - refund every one of them, not just
  // whichever one a single findOne happens to return.
  const payments = await Payment.find({ orderId: order._id, status: 'captured' });
  if (payments.length === 0) throw new AppError('No captured payment found for this booking', 404);

  const refundedPayments = [];
  for (const payment of payments) {
    let refund;
    try {
      refund = await razorpayService.refundPayment(payment.razorpayPaymentId);
    } catch (err) {
      throw new AppError('Refund failed. Try again or contact support.', 502);
    }
    payment.status = 'refunded';
    payment.refundId = refund.id;
    await payment.save();
    refundedPayments.push(payment);
  }

  order.paymentStatus = 'refunded';
  await order.save();

  return success(res, { payments: refundedPayments }, 'Refund initiated');
});

// GET /api/v1/payment/history
exports.history = catchAsync(async (req, res) => {
  const payments = await Payment.find({ userId: req.user.id })
    .populate('orderId', 'pickupLocation dropLocation status')
    .sort({ createdAt: -1 });
  return success(res, { payments });
});

// GET /api/v1/payment/saved-cards
exports.listSavedCards = catchAsync(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user.razorpayCustomerId) return success(res, { cards: [] });

  const cards = await razorpayService.listSavedCards(user.razorpayCustomerId);
  return success(res, { cards });
});

// DELETE /api/v1/payment/saved-cards/:tokenId
exports.deleteSavedCard = catchAsync(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user.razorpayCustomerId) throw new AppError('No saved cards found', 404);

  await razorpayService.deleteSavedCard(user.razorpayCustomerId, req.params.tokenId);
  return success(res, {}, 'Card removed');
});

const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Payment = require('../models/payment.model');
const razorpayService = require('../services/razorpay.service');

// POST /api/v1/payment/create-order  { orderId }
exports.createOrder = catchAsync(async (req, res) => {
  const { orderId } = req.body;
  if (!orderId) throw new AppError('orderId is required', 400);

  const order = await Order.findById(orderId);
  if (!order) throw new AppError('Booking not found', 404);
  if (String(order.customerId) !== String(req.user.id)) throw new AppError('Not authorized', 403);
  if (order.paymentStatus === 'paid') throw new AppError('This booking is already paid', 400);

  const amountPaise = Math.round(order.price * 100);

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
    { orderId: order._id, status: 'created' },
    { userId: req.user.id, razorpayOrderId: razorpayOrder.id, amount: amountPaise, status: 'created' },
    { new: true, upsert: true }
  );

  return success(
    res,
    {
      razorpayOrderId: razorpayOrder.id,
      amount: amountPaise,
      currency: 'INR',
      keyId: process.env.RAZORPAY_KEY_ID,
      paymentId: payment._id,
    },
    'Payment order created',
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

  payment.razorpayPaymentId = razorpay_payment_id;
  payment.razorpaySignature = razorpay_signature;
  payment.status = 'captured';
  await payment.save();

  await Order.findByIdAndUpdate(payment.orderId, { paymentStatus: 'paid' });

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
      await Order.findByIdAndUpdate(payment.orderId, { paymentStatus: 'paid' });
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

  const payment = await Payment.findOne({ orderId: order._id, status: 'captured' });
  if (!payment) throw new AppError('No captured payment found for this booking', 404);

  let refund;
  try {
    refund = await razorpayService.refundPayment(payment.razorpayPaymentId);
  } catch (err) {
    throw new AppError('Refund failed. Try again or contact support.', 502);
  }

  payment.status = 'refunded';
  payment.refundId = refund.id;
  await payment.save();

  order.paymentStatus = 'refunded';
  await order.save();

  return success(res, { payment }, 'Refund initiated');
});

// GET /api/v1/payment/history
exports.history = catchAsync(async (req, res) => {
  const payments = await Payment.find({ userId: req.user.id })
    .populate('orderId', 'pickupLocation dropLocation status')
    .sort({ createdAt: -1 });
  return success(res, { payments });
});

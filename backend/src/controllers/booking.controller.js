const PDFDocument = require('pdfkit');
const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Driver = require('../models/driver.model');
const Payment = require('../models/payment.model');
const Message = require('../models/message.model');
const Review = require('../models/review.model');
const PricingConfig = require('../models/pricingConfig.model');
const { getRoadDistanceKm } = require('../services/maps.service');
const { sendToUser, sendToUsers } = require('../services/notification.service');
const razorpayService = require('../services/razorpay.service');
const { applyWalletTransaction } = require('../services/wallet.service');
const { VEHICLE_MAX_WEIGHT_KG } = require('../config/vehicleCapacity');
const { calculateAdvanceAmount } = require('../utils/pricingRules');

function assertWeightWithinCapacity(vehicleType, weightKg) {
  const maxWeight = VEHICLE_MAX_WEIGHT_KG[vehicleType];
  if (maxWeight != null && weightKg > maxWeight) {
    throw new AppError(`Weight exceeds the ${maxWeight}kg limit for ${vehicleType}`, 400);
  }
}

// Haversine distance in km between two [lng, lat] points. Used as a stand-in
// for a real routing distance until Google Distance Matrix API is wired in
// (needs GOOGLE_MAPS_API_KEY - see backend/.env.example).
function haversineKm([lng1, lat1], [lng2, lat2]) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function calculateFare({ vehicleType, distanceKm, weightKg }) {
  const config = await PricingConfig.findOne({ vehicleType });
  if (!config) throw new AppError(`No pricing configured for vehicle type "${vehicleType}"`, 400);

  const distanceCharge = distanceKm * config.perKmRate;
  const weightCharge = (weightKg || 0) * (config.perKgRate || 0);
  const surgeMultiplier = config.isSurgeActive ? config.surgeMultiplier : 1;
  const subtotal = config.baseFare + distanceCharge + weightCharge;
  const estimatedPrice = Math.round(subtotal * surgeMultiplier);

  return {
    estimatedPrice,
    breakdown: {
      baseFare: config.baseFare,
      distanceCharge: Math.round(distanceCharge),
      weightCharge: Math.round(weightCharge),
      surgeMultiplier,
      surgeApplied: config.isSurgeActive,
    },
  };
}

// POST /api/v1/booking/estimate
// body: { pickupLocation: {lat,lng,address}, dropLocation: {lat,lng,address}, vehicleType, weightKg }
exports.estimate = catchAsync(async (req, res) => {
  const { pickupLocation, dropLocation, vehicleType, weightKg } = req.body;
  if (!pickupLocation || !dropLocation || !vehicleType) {
    throw new AppError('pickupLocation, dropLocation, and vehicleType are required', 400);
  }
  if (weightKg) assertWeightWithinCapacity(vehicleType, weightKg);

  let distanceKm;
  if (pickupLocation.lat != null && dropLocation.lat != null) {
    // Try the real road distance first (needs GOOGLE_MAPS_API_KEY configured
    // - see backend/.env.example). Falls back to a straight-line haversine
    // estimate if no key is set or the API call fails, so booking still
    // works end to end either way.
    const roadDistanceKm = await getRoadDistanceKm({
      originLat: pickupLocation.lat,
      originLng: pickupLocation.lng,
      destLat: dropLocation.lat,
      destLng: dropLocation.lng,
    });

    distanceKm =
      roadDistanceKm ??
      Math.max(1, Math.round(haversineKm([pickupLocation.lng, pickupLocation.lat], [dropLocation.lng, dropLocation.lat]) * 10) / 10);
  } else {
    // No coordinates available yet (Maps/Places not wired) - use a flat
    // placeholder distance so the flow is still testable end to end.
    distanceKm = 10;
  }

  const { estimatedPrice, breakdown } = await calculateFare({ vehicleType, distanceKm, weightKg });
  const advanceAmount = await calculateAdvanceAmount(estimatedPrice, vehicleType);

  return success(res, { distanceKm, estimatedPrice, breakdown, advanceAmount });
});

// POST /api/v1/booking/create
exports.create = catchAsync(async (req, res) => {
  const {
    pickupLocation,
    dropLocation,
    waypoints,
    vehicleType,
    goodsType,
    weightKg,
    isFragile,
    insuranceOpted,
    distanceKm,
    paymentMethod,
  } = req.body;

  if (!pickupLocation?.address || !dropLocation?.address || !vehicleType) {
    throw new AppError('pickupLocation, dropLocation, and vehicleType are required', 400);
  }
  if (weightKg) assertWeightWithinCapacity(vehicleType, weightKg);
  if (paymentMethod && !['online', 'cod'].includes(paymentMethod)) {
    throw new AppError("paymentMethod must be 'online' or 'cod'", 400);
  }

  const finalDistanceKm = distanceKm || 10;
  // Price is always recalculated server-side - never trust a client-sent price.
  const { estimatedPrice } = await calculateFare({ vehicleType, distanceKm: finalDistanceKm, weightKg });
  const finalPaymentMethod = paymentMethod || 'online';
  // Only vehicle types the admin has configured with advanceRequired carry
  // an advance at all - see order.model.js's advanceAmount comment.
  // Applies to both cod and online.
  const advanceAmount = await calculateAdvanceAmount(estimatedPrice, vehicleType);

  const order = await Order.create({
    customerId: req.user.id,
    pickupLocation: {
      type: 'Point',
      coordinates: [pickupLocation.lng || 0, pickupLocation.lat || 0],
      address: pickupLocation.address,
    },
    dropLocation: {
      type: 'Point',
      coordinates: [dropLocation.lng || 0, dropLocation.lat || 0],
      address: dropLocation.address,
    },
    waypoints: waypoints || [],
    vehicleType,
    goodsType,
    weightKg,
    isFragile: Boolean(isFragile),
    insuranceOpted: Boolean(insuranceOpted),
    distanceKm: finalDistanceKm,
    price: estimatedPrice,
    paymentMethod: finalPaymentMethod,
    advanceAmount,
    status: 'pending',
    timeline: [{ status: 'pending', note: 'Booking created' }],
  });

  // Best-effort "new job available" push to online, approved drivers with
  // a matching vehicle type - doesn't block the response if it's slow or
  // Firebase isn't configured, and never throws back to the customer.
  Driver.find({ vehicleType, isAvailable: true, isApproved: true })
    .select('userId')
    .then((eligibleDrivers) => {
      const userIds = eligibleDrivers.map((d) => d.userId);
      sendToUsers(userIds, {
        title: 'New job available',
        body: `${pickupLocation.address} → ${dropLocation.address}`,
        data: { bookingId: String(order._id) },
      });
    })
    .catch(() => {});

  return success(res, { order }, 'Booking created', 201);
});

// GET /api/v1/booking/:id
exports.getById = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id).populate({
    path: 'driverId',
    select: 'vehicleNumber vehicleType rating ratingCount currentLocation',
    populate: { path: 'userId', select: 'name phone' },
  });
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  if (!isOwner && req.user.role !== 'admin') throw new AppError('Not authorized to view this booking', 403);

  // Delivery OTP is only meaningful (and only shown) once the driver has
  // picked up - it's how the customer proves receipt at drop-off, standing
  // in for a real SMS-delivered code since no SMS gateway is wired here.
  // Start OTP serves the same purpose one step earlier: proves the trip is
  // genuinely starting, so it's only shown while the order is 'picked_up'
  // (before the driver taps "Start trip") - already consumed once in_transit.
  const orderObj = order.toObject();
  if (!['picked_up', 'in_transit'].includes(order.status)) {
    delete orderObj.deliveryOtp;
  }
  if (order.status !== 'picked_up') {
    delete orderObj.startOtp;
  }

  // Lets the customer app know whether to show the "rate your driver"
  // prompt or the already-submitted review (see submitReview below).
  orderObj.review = await Review.findOne({ orderId: order._id }).lean();

  return success(res, { order: orderObj });
});

// POST /api/v1/booking/:id/review  { rating, comment? }
// Only the order's own customer, only once the trip is actually delivered,
// only once per order (enforced by review.model.js's unique orderId index,
// not just this check - belt and suspenders against a race between two
// concurrent submissions). Recomputes the driver's rating from every real
// Review they have, rather than incrementing a running average - trivially
// correct even if a review is ever edited or removed later.
exports.submitReview = catchAsync(async (req, res) => {
  const { rating, comment } = req.body;
  if (!rating || rating < 1 || rating > 5) throw new AppError('rating must be between 1 and 5', 400);

  const order = await Order.findById(req.params.id);
  if (!order) throw new AppError('Booking not found', 404);
  if (String(order.customerId) !== String(req.user.id)) throw new AppError('Not authorized to review this booking', 403);
  if (order.status !== 'delivered') throw new AppError('You can only review a booking once it has been delivered', 400);

  let review;
  try {
    review = await Review.create({
      orderId: order._id,
      driverId: order.driverId,
      customerId: req.user.id,
      rating,
      comment: comment?.trim() || undefined,
    });
  } catch (err) {
    if (err.code === 11000) throw new AppError("You've already reviewed this trip", 400);
    throw err;
  }

  const [agg] = await Review.aggregate([
    { $match: { driverId: order.driverId } },
    { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } },
  ]);
  await Driver.findByIdAndUpdate(order.driverId, { rating: agg.avg, ratingCount: agg.count });

  return success(res, { review }, 'Review submitted', 201);
});

// GET /api/v1/booking/:id/invoice - generates a simple receipt PDF on the
// fly, for individual (non-enterprise) orders. Mirrors the shape of
// enterprise.controller.js's downloadInvoicePdf, but scoped to one order
// and its actual Payment (rather than an aggregated Invoice) - only
// available once a payment has actually been captured, and only to that
// order's own customer (or admin).
exports.downloadInvoicePdf = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id);
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  if (!isOwner && req.user.role !== 'admin') throw new AppError('Not authorized to view this booking', 403);

  const payment = await Payment.findOne({ orderId: order._id, status: 'captured' }).sort({ createdAt: -1 });
  if (!payment) throw new AppError('No completed payment found for this booking yet', 400);

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename="receipt-${order._id}.pdf"`);

  const doc = new PDFDocument({ margin: 50 });
  doc.pipe(res);

  doc.fontSize(18).text('Pan-India Logistics Platform', { align: 'left' });
  doc.fontSize(10).fillColor('#555').text('Payment Receipt', { align: 'left' });
  doc.moveDown(1.5);

  doc.fontSize(12).fillColor('#000').text(`Order: ${order._id.toString().slice(-8).toUpperCase()}`);
  doc.text(`Date: ${order.createdAt.toLocaleDateString('en-IN')}`);
  doc.text(`Route: ${order.pickupLocation?.address ?? '—'} -> ${order.dropLocation?.address ?? '—'}`);
  doc.text(`Vehicle: ${order.vehicleType.replace('_', ' ')}`);
  doc.text(`Goods: ${order.goodsType}${order.weightKg ? ` (${order.weightKg} kg)` : ''}`);
  doc.moveDown();

  doc.fontSize(11).text('Payment', { underline: true });
  doc.moveDown(0.5);
  doc.fontSize(10).text(`Order price: Rs ${order.price}`);
  if (order.paymentMethod === 'cod') {
    if (order.advanceAmount > 0) {
      doc.text(`Payment method: Cash on delivery (advance paid online)`);
      doc.text(`Advance paid online: Rs ${order.advanceAmount}`);
      doc.text(`Remainder collected in cash: Rs ${(order.price - order.advanceAmount).toFixed(2)}`);
    } else {
      doc.text(`Payment method: Cash on delivery`);
      doc.text(`Amount collected in cash: Rs ${order.price}`);
    }
  } else if (order.advanceAmount > 0) {
    doc.text(`Payment method: Online (paid in two instalments)`);
    doc.text(`Advance paid online: Rs ${order.advanceAmount}`);
    doc.text(
      order.remainderPaid
        ? `Remainder paid online: Rs ${(order.price - order.advanceAmount).toFixed(2)}`
        : `Remainder paid online: Rs 0.00 (not yet paid)`
    );
  } else {
    doc.text(`Payment method: Online`);
    doc.text(`Amount paid: Rs ${(payment.amount / 100).toFixed(2)}`);
  }
  if (payment.refundedAmount) doc.text(`Refunded: Rs ${(payment.refundedAmount / 100).toFixed(2)}`);
  doc.text(`Razorpay payment ID: ${payment.razorpayPaymentId ?? '—'}`);
  doc.moveDown();

  doc.fontSize(9).fillColor('#888').text('This is a system-generated receipt.', { align: 'left' });

  doc.end();
});

// GET /api/v1/booking/:id/messages - chat history for one booking. Real-time
// delivery is the Socket.IO 'chat_message' event (sockets/tracking.socket.js);
// this is for populating history when the chat screen first opens, or
// catching up on messages sent while offline.
exports.listMessages = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id).populate('driverId', 'userId');
  if (!order) throw new AppError('Booking not found', 404);

  const isCustomer = String(order.customerId) === String(req.user.id);
  const isDriver = order.driverId?.userId && String(order.driverId.userId) === String(req.user.id);
  if (!isCustomer && !isDriver && req.user.role !== 'admin') {
    throw new AppError('Not authorized to view this conversation', 403);
  }

  const messages = await Message.find({ bookingId: order._id }).sort({ createdAt: 1 });
  return success(res, { messages });
});

// GET /api/v1/booking/user/:userId?status=&page=&limit=
exports.listByUser = catchAsync(async (req, res) => {
  if (req.params.userId !== req.user.id && req.user.role !== 'admin') {
    throw new AppError('Not authorized to view these bookings', 403);
  }

  const { status, page = 1, limit = 20 } = req.query;
  const filter = { customerId: req.params.userId };
  if (status) filter.status = status;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [orders, total] = await Promise.all([
    Order.find(filter)
      .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating ratingCount', populate: { path: 'userId', select: 'name phone' } })
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    Order.countDocuments(filter),
  ]);

  return success(res, { orders, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// PUT /api/v1/booking/:id/cancel
exports.cancel = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id);
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  if (!isOwner && req.user.role !== 'admin') throw new AppError('Not authorized to cancel this booking', 403);

  // 'awaiting_payment' means the goods are already physically with the
  // customer (driver confirmed drop-off via OTP) - only the online
  // remainder is outstanding, so cancelling makes no sense at that point.
  if (['delivered', 'cancelled', 'awaiting_payment'].includes(order.status)) {
    throw new AppError(`Cannot cancel a booking that is already ${order.status}`, 400);
  }

  // Only charge the driver-compensation fee once a driver has actually
  // accepted the job - nothing to compensate if cancelled while still
  // 'pending' with no driver assigned yet. Uses the order's own stored
  // advanceAmount (locked in at booking time) rather than recomputing from
  // current pricing config, so an admin editing the config later doesn't
  // retroactively change what's owed on an already-placed order.
  const driverWasAssigned = ['accepted', 'picked_up', 'in_transit'].includes(order.status);
  const cancellationFee = driverWasAssigned ? order.advanceAmount : 0;

  // If the customer already paid, refund immediately minus the fee - the
  // fee itself gets credited to the driver's wallet below instead of
  // staying with the platform. Based on what was actually captured across
  // ALL captured payments for this order (not just one) - a gated online
  // order can have two by now (the advance and, if paid early via
  // createRemainderOrder, the remainder too), so this refunds/marks-
  // refunded every one of them until the fee is accounted for, rather than
  // silently leaving a second payment untouched. Gated on paymentStatus
  // alone (not cancellationFee > 0) - an ungated vehicle type can have a 0
  // fee while still having been fully paid (ungated online), and that
  // customer is still owed a full refund. A refund failure shouldn't block
  // the cancellation itself - the booking still needs to come off the
  // driver's job list - so it's logged on the timeline for manual
  // follow-up instead.
  if (order.paymentStatus === 'paid') {
    const payments = await Payment.find({ orderId: order._id, status: 'captured' });
    let remainingToWithhold = Math.round(cancellationFee * 100);
    let anyRefundFailed = false;
    for (const payment of payments) {
      const withheldFromThis = Math.min(payment.amount, remainingToWithhold);
      const refundAmountPaise = payment.amount - withheldFromThis;
      remainingToWithhold -= withheldFromThis;
      if (refundAmountPaise > 0) {
        try {
          const refund = await razorpayService.refundPayment(payment.razorpayPaymentId, refundAmountPaise);
          payment.status = 'refunded';
          payment.refundId = refund.id;
          payment.refundedAmount = refundAmountPaise;
          await payment.save();
        } catch (err) {
          anyRefundFailed = true;
        }
      } else {
        // This payment is fully consumed by the driver's compensation -
        // nothing left to refund from it.
        payment.status = 'refunded';
        payment.refundedAmount = 0;
        await payment.save();
      }
    }
    if (payments.length > 0) {
      order.paymentStatus = 'refunded';
      if (anyRefundFailed) {
        order.timeline.push({ status: 'cancelled', note: `Refund failed for one or more payments (₹${cancellationFee} driver fee applies) - needs manual follow-up` });
      }
    }
  }

  if (cancellationFee > 0 && order.driverId) {
    await applyWalletTransaction({
      driverId: order.driverId,
      type: 'cancellation_compensation',
      amount: cancellationFee,
      orderId: order._id,
      note: 'Customer cancelled after accepting',
    });
  }

  order.status = 'cancelled';
  order.cancellationFeeAmount = cancellationFee;
  order.timeline.push({ status: 'cancelled', note: 'Cancelled by customer' });
  await order.save();

  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'cancelled', timestamp: Date.now() });

  return success(res, { order, cancellationFee }, 'Booking cancelled');
});

// GET /api/v1/booking/:id/track
exports.track = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id).populate('driverId', 'currentLocation vehicleNumber');
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  if (!isOwner && req.user.role !== 'admin') throw new AppError('Not authorized to track this booking', 403);

  return success(res, {
    status: order.status,
    driverLocation: order.driverId?.currentLocation ?? null,
    vehicleNumber: order.driverId?.vehicleNumber ?? null,
  });
});

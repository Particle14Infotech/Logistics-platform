const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Driver = require('../models/driver.model');
const User = require('../models/user.model');
const Payment = require('../models/payment.model');
const PricingConfig = require('../models/pricingConfig.model');
const Dispute = require('../models/dispute.model');
const Banner = require('../models/banner.model');
const Faq = require('../models/faq.model');
const Notification = require('../models/notification.model');
const Enterprise = require('../models/enterprise.model');

// GET /api/v1/admin/orders?status=&vehicleType=&search=&dateFrom=&dateTo=&page=&limit=
exports.listOrders = catchAsync(async (req, res) => {
  const { status, vehicleType, search, dateFrom, dateTo, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (status) filter.status = status;
  if (vehicleType) filter.vehicleType = vehicleType;
  if (dateFrom || dateTo) {
    filter.createdAt = {};
    if (dateFrom) filter.createdAt.$gte = new Date(dateFrom);
    if (dateTo) filter.createdAt.$lte = new Date(dateTo);
  }
  if (search) {
    // Match on order id or the customer's populated name/email requires a
    // pre-lookup; for now support matching goodsType/id substrings directly.
    filter.$or = [
      { goodsType: { $regex: search, $options: 'i' } },
      { 'pickupLocation.address': { $regex: search, $options: 'i' } },
      { 'dropLocation.address': { $regex: search, $options: 'i' } },
    ];
  }

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [orders, total] = await Promise.all([
    Order.find(filter)
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .populate('customerId', 'name email phone')
      .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating', populate: { path: 'userId', select: 'name phone' } })
      .lean(),
    Order.countDocuments(filter),
  ]);

  return success(res, {
    orders,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) },
  });
});

// GET /api/v1/admin/orders/:id
exports.getOrderById = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id)
    .populate('customerId', 'name email phone')
    .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating currentLocation', populate: { path: 'userId', select: 'name phone' } });

  if (!order) throw new AppError('Order not found', 404);
  return success(res, { order });
});

// PUT /api/v1/admin/orders/:id/assign  { driverId }
exports.assignDriver = catchAsync(async (req, res) => {
  const { driverId } = req.body;
  if (!driverId) throw new AppError('driverId is required', 400);

  const driver = await Driver.findById(driverId);
  if (!driver) throw new AppError('Driver not found', 404);
  if (!driver.isApproved) throw new AppError('Driver is not approved for operations', 400);

  const order = await Order.findById(req.params.id);
  if (!order) throw new AppError('Order not found', 404);
  if (['delivered', 'cancelled'].includes(order.status)) {
    throw new AppError(`Cannot assign a driver to a ${order.status} order`, 400);
  }

  order.driverId = driver._id;
  order.status = 'accepted';
  order.timeline.push({ status: 'accepted', note: `Manually assigned by admin to driver ${driver.vehicleNumber}` });
  await order.save();

  // Notify the driver + customer over the tracking socket, if connected
  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'accepted', timestamp: Date.now() });

  return success(res, { order }, 'Driver assigned');
});

// GET /api/v1/admin/drivers?isApproved=&isAvailable=&vehicleType=&search=&page=&limit=
exports.listDrivers = catchAsync(async (req, res) => {
  const { isApproved, isAvailable, vehicleType, search, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (isApproved !== undefined) filter.isApproved = isApproved === 'true';
  if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';
  if (vehicleType) filter.vehicleType = vehicleType;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  let query = Driver.find(filter).populate('userId', 'name phone email isBlocked');
  if (search) {
    query = query.populate({
      path: 'userId',
      match: { name: { $regex: search, $options: 'i' } },
      select: 'name phone email isBlocked',
    });
  }

  const [drivers, total] = await Promise.all([
    query.sort({ createdAt: -1 }).skip((pageNum - 1) * limitNum).limit(limitNum).lean(),
    Driver.countDocuments(filter),
  ]);

  return success(res, {
    drivers: search ? drivers.filter((d) => d.userId) : drivers,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) },
  });
});

// PUT /api/v1/admin/drivers/:id  { isApproved?, isBlocked? } - approve/suspend a driver
exports.updateDriverStatus = catchAsync(async (req, res) => {
  const { isApproved, isBlocked } = req.body;
  const driver = await Driver.findById(req.params.id);
  if (!driver) throw new AppError('Driver not found', 404);

  if (isApproved !== undefined) {
    // A fleet owner can create a Driver row directly (AddVehicleScreen) with
    // no selfie ever captured - the app's own routing now forces that
    // driver through the selfie step before reaching the dashboard, but
    // that's a client-side nudge, not enforcement. This is the actual gate:
    // no facial KYC photo, no approval, regardless of how the request got here.
    if (isApproved && !driver.documents?.photoUrl) {
      throw new AppError('Cannot approve - no KYC selfie has been uploaded for this driver yet', 400);
    }
    driver.isApproved = isApproved;
    if (!isApproved) driver.isAvailable = false; // pull an unapproved driver off the road
    await driver.save();
  }

  if (isBlocked !== undefined) {
    await User.findByIdAndUpdate(driver.userId, { isBlocked });
  }

  const updated = await Driver.findById(driver._id).populate('userId', 'name phone email isBlocked');
  return success(res, { driver: updated }, 'Driver status updated');
});

// GET /api/v1/admin/drivers/:id - full detail incl. documents, for KYC review
exports.getDriverById = catchAsync(async (req, res) => {
  const driver = await Driver.findById(req.params.id).populate('userId', 'name phone email isBlocked createdAt');
  if (!driver) throw new AppError('Driver not found', 404);

  const [totalOrders, deliveredOrders] = await Promise.all([
    Order.countDocuments({ driverId: driver._id }),
    Order.countDocuments({ driverId: driver._id, status: 'delivered' }),
  ]);

  return success(res, { driver, stats: { totalOrders, deliveredOrders } });
});

// GET /api/v1/admin/analytics - KPI + revenue snapshot for the dashboard
exports.analytics = catchAsync(async (req, res) => {
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  const sevenDaysAgo = new Date(todayStart);
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6); // 7 days inclusive of today

  const [
    ordersToday,
    revenueAgg,
    activeDrivers,
    totalDrivers,
    deliveredToday,
    cancelledToday,
    dailyAgg,
    activeOrders,
    activeTrips,
    statusAgg,
    vehicleAgg,
  ] = await Promise.all([
    Order.countDocuments({ createdAt: { $gte: todayStart } }),
    Order.aggregate([
      { $match: { createdAt: { $gte: todayStart }, paymentStatus: 'paid' } },
      { $group: { _id: null, total: { $sum: '$price' } } },
    ]),
    Driver.countDocuments({ isAvailable: true, isApproved: true }),
    Driver.countDocuments({ isApproved: true }),
    Order.countDocuments({ createdAt: { $gte: todayStart }, status: 'delivered' }),
    Order.countDocuments({ createdAt: { $gte: todayStart }, status: 'cancelled' }),
    // Powers the dashboard's "last 7 days" charts - grouped by calendar day
    // rather than fetched per-day in a loop, one aggregation for the whole
    // window.
    // timezone: 'Asia/Kolkata' - matches todayStart above, which is built
    // from the server's local clock (IST). Without pinning this, Mongo
    // groups by UTC calendar day while the fill-loop below (and the
    // weekday label) use local time, so "today" silently lands in
    // yesterday's bucket whenever local time is ahead of UTC.
    Order.aggregate([
      { $match: { createdAt: { $gte: sevenDaysAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt', timezone: 'Asia/Kolkata' } },
          orders: { $sum: 1 },
          revenue: { $sum: { $cond: [{ $eq: ['$paymentStatus', 'paid'] }, '$price', 0] } },
        },
      },
    ]),
    // "Active" here means still moving through the pipeline right now,
    // regardless of when it was created - unlike ordersToday, a shipment
    // booked yesterday that's still in_transit today is still active.
    Order.countDocuments({ status: { $in: ['pending', 'accepted', 'picked_up', 'in_transit'] } }),
    // Subset of the above that's actually assigned to a driver and moving
    // (excludes 'pending', which is still waiting for a driver to accept).
    Order.countDocuments({ status: { $in: ['accepted', 'picked_up', 'in_transit'] } }),
    Order.aggregate([
      { $match: { status: { $in: ['pending', 'accepted', 'picked_up', 'in_transit'] } } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
    Driver.aggregate([{ $match: { isApproved: true } }, { $group: { _id: '$vehicleType', count: { $sum: 1 } } }]),
  ]);

  const completedToday = deliveredToday + cancelledToday;
  const successRate = completedToday > 0 ? (deliveredToday / completedToday) * 100 : 0;

  const statusCounts = { pending: 0, accepted: 0, picked_up: 0, in_transit: 0 };
  statusAgg.forEach((s) => { statusCounts[s._id] = s.count; });
  const ordersByStatus = [
    { status: 'pending', label: 'Pending', count: statusCounts.pending },
    { status: 'accepted', label: 'Accepted', count: statusCounts.accepted },
    { status: 'picked_up', label: 'Picked up', count: statusCounts.picked_up },
    { status: 'in_transit', label: 'In transit', count: statusCounts.in_transit },
    { status: 'delivered', label: 'Delivered (today)', count: deliveredToday },
    { status: 'cancelled', label: 'Cancelled (today)', count: cancelledToday },
  ];

  const VEHICLE_TYPE_LABELS = {
    bike: 'Bike',
    auto: 'Auto',
    mini_truck: 'Mini truck',
    medium_truck: 'Medium truck',
    large_truck: 'Large truck',
  };
  const vehicleCounts = Object.fromEntries(vehicleAgg.map((v) => [v._id, v.count]));
  const fleetByVehicleType = Object.entries(VEHICLE_TYPE_LABELS).map(([type, label]) => ({
    type,
    label,
    count: vehicleCounts[type] ?? 0,
  }));

  // Fill in any day with zero orders so the chart always shows exactly 7
  // evenly-spaced points instead of gaps. Built from local date parts, not
  // toISOString() (which converts to UTC and would disagree with the
  // Asia/Kolkata-grouped keys above whenever local time is ahead of UTC).
  const last7Days = [];
  for (let i = 6; i >= 0; i--) {
    const d = new Date(todayStart);
    d.setDate(d.getDate() - i);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    const found = dailyAgg.find((x) => x._id === key);
    last7Days.push({
      date: key,
      label: d.toLocaleDateString('en-IN', { weekday: 'short' }),
      orders: found?.orders ?? 0,
      revenue: found?.revenue ?? 0,
    });
  }

  return success(res, {
    ordersToday,
    revenueToday: revenueAgg[0]?.total ?? 0,
    activeDrivers,
    totalDrivers,
    activeOrders,
    activeTrips,
    deliverySuccessRate: Math.round(successRate * 10) / 10,
    last7Days,
    ordersByStatus,
    fleetByVehicleType,
  });
});

// GET /api/v1/admin/vehicles?vehicleType=&isAvailable=&search=
// Vehicles are derived from Driver records (one vehicle per driver in this
// model) rather than a separate collection, since that's how the data is
// actually captured today. "Needs attention" flags drivers missing key
// compliance documents (RC, insurance, pollution cert).
exports.listVehicles = catchAsync(async (req, res) => {
  const { vehicleType, isAvailable, search, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (vehicleType) filter.vehicleType = vehicleType;
  if (isAvailable !== undefined) filter.isAvailable = isAvailable === 'true';

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  if (search) filter.vehicleNumber = { $regex: search, $options: 'i' };

  const [drivers, total] = await Promise.all([
    Driver.find(filter)
      .populate('userId', 'name phone')
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    Driver.countDocuments(filter),
  ]);

  const vehicles = drivers.map((d) => {
    const missingCompliance = ['rcUrl', 'insuranceUrl', 'pollutionCertUrl'].filter((k) => !d.documents?.[k]);
    return {
      _id: d._id,
      vehicleNumber: d.vehicleNumber,
      vehicleType: d.vehicleType,
      isAvailable: d.isAvailable,
      isApproved: d.isApproved,
      owner: d.userId,
      needsAttention: missingCompliance.length > 0,
      missingCompliance,
    };
  });

  return success(res, { vehicles, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// GET /api/v1/admin/pricing - current rate card for every vehicle type
exports.getPricing = catchAsync(async (req, res) => {
  const configs = await PricingConfig.find().sort({ vehicleType: 1 });
  return success(res, { pricing: configs });
});

// PUT /api/v1/admin/pricing  { vehicleType, baseFare, perKmRate, perKgRate?, surgeMultiplier?, isSurgeActive? }
exports.updatePricing = catchAsync(async (req, res) => {
  const { vehicleType, baseFare, perKmRate, perKgRate, surgeMultiplier, isSurgeActive } = req.body;
  if (!vehicleType) throw new AppError('vehicleType is required', 400);

  const config = await PricingConfig.findOneAndUpdate(
    { vehicleType },
    {
      $set: {
        ...(baseFare !== undefined && { baseFare }),
        ...(perKmRate !== undefined && { perKmRate }),
        ...(perKgRate !== undefined && { perKgRate }),
        ...(surgeMultiplier !== undefined && { surgeMultiplier }),
        ...(isSurgeActive !== undefined && { isSurgeActive }),
        updatedBy: req.user.id,
      },
    },
    { new: true, upsert: true }
  );

  return success(res, { pricing: config }, 'Pricing updated');
});

// GET /api/v1/admin/payments?status=&search=&page=&limit=
exports.listPayments = catchAsync(async (req, res) => {
  const { status, search, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (status) filter.status = status;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  let query = Payment.find(filter).populate('userId', 'name email phone').populate('orderId', 'pickupLocation dropLocation');
  if (search) {
    query = query.populate({ path: 'userId', match: { name: { $regex: search, $options: 'i' } }, select: 'name email phone' });
  }

  const [payments, total] = await Promise.all([
    query.sort({ createdAt: -1 }).skip((pageNum - 1) * limitNum).limit(limitNum).lean(),
    Payment.countDocuments(filter),
  ]);

  return success(res, {
    payments: search ? payments.filter((p) => p.userId) : payments,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) },
  });
});

// PUT /api/v1/admin/payments/:id/refund  { reason? }
exports.refundPayment = catchAsync(async (req, res) => {
  const payment = await Payment.findById(req.params.id);
  if (!payment) throw new AppError('Payment not found', 404);
  if (payment.status !== 'captured') throw new AppError(`Cannot refund a payment with status "${payment.status}"`, 400);

  const razorpayConfigured = Boolean(process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET);

  if (razorpayConfigured) {
    try {
      const refund = await razorpayService.refundPayment(payment.razorpayPaymentId);
      payment.refundId = refund.id;
    } catch (err) {
      throw new AppError('Razorpay refund failed. Check that this payment exists in your Razorpay dashboard.', 502);
    }
  }
  // Razorpay not configured yet -> fall back to a DB-only refund so this
  // stays testable without real credentials, same as before Razorpay was
  // wired in. Once RAZORPAY_KEY_ID/SECRET are set, this automatically
  // starts hitting the real refund API instead.

  payment.status = 'refunded';
  await payment.save();

  await Order.findByIdAndUpdate(payment.orderId, { paymentStatus: 'refunded' });

  return success(
    res,
    { payment },
    razorpayConfigured ? 'Payment refunded' : 'Payment marked as refunded (Razorpay not configured - simulated)'
  );
});

// GET /api/v1/admin/disputes?status=&category=&page=&limit=
exports.listDisputes = catchAsync(async (req, res) => {
  const { status, category, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (status) filter.status = status;
  if (category) filter.category = category;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [disputes, total] = await Promise.all([
    Dispute.find(filter)
      .populate('raisedBy', 'name phone role')
      .populate('orderId', 'pickupLocation dropLocation price status')
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    Dispute.countDocuments(filter),
  ]);

  return success(res, { disputes, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// PUT /api/v1/admin/disputes/:id/resolve  { status, resolutionNote }
exports.resolveDispute = catchAsync(async (req, res) => {
  const { status, resolutionNote } = req.body;
  if (!['resolved', 'rejected', 'investigating'].includes(status)) {
    throw new AppError('status must be one of: investigating, resolved, rejected', 400);
  }

  const dispute = await Dispute.findById(req.params.id);
  if (!dispute) throw new AppError('Dispute not found', 404);

  dispute.status = status;
  dispute.resolutionNote = resolutionNote;
  if (status === 'resolved' || status === 'rejected') {
    dispute.resolvedBy = req.user.id;
    dispute.resolvedAt = new Date();
  }
  await dispute.save();

  return success(res, { dispute }, 'Dispute updated');
});

// --- Content: Banners ---

// GET /api/v1/admin/banners
exports.listBanners = catchAsync(async (req, res) => {
  const banners = await Banner.find().sort({ sortOrder: 1, createdAt: -1 });
  return success(res, { banners });
});

// POST /api/v1/admin/banners  { title, imageUrl, linkUrl?, sortOrder? }
exports.createBanner = catchAsync(async (req, res) => {
  const { title, imageUrl, linkUrl, sortOrder } = req.body;
  if (!title || !imageUrl) throw new AppError('title and imageUrl are required', 400);
  const banner = await Banner.create({ title, imageUrl, linkUrl, sortOrder: sortOrder ?? 0 });
  return success(res, { banner }, 'Banner created', 201);
});

// PUT /api/v1/admin/banners/:id  { title?, imageUrl?, linkUrl?, isActive?, sortOrder? }
exports.updateBanner = catchAsync(async (req, res) => {
  const banner = await Banner.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!banner) throw new AppError('Banner not found', 404);
  return success(res, { banner }, 'Banner updated');
});

// DELETE /api/v1/admin/banners/:id
exports.deleteBanner = catchAsync(async (req, res) => {
  const banner = await Banner.findByIdAndDelete(req.params.id);
  if (!banner) throw new AppError('Banner not found', 404);
  return success(res, null, 'Banner deleted');
});

// --- Content: FAQs ---

// GET /api/v1/admin/faqs
exports.listFaqs = catchAsync(async (req, res) => {
  const faqs = await Faq.find().sort({ sortOrder: 1, createdAt: -1 });
  return success(res, { faqs });
});

// POST /api/v1/admin/faqs  { question, answer, category?, sortOrder? }
exports.createFaq = catchAsync(async (req, res) => {
  const { question, answer, category, sortOrder } = req.body;
  if (!question || !answer) throw new AppError('question and answer are required', 400);
  const faq = await Faq.create({ question, answer, category: category || 'general', sortOrder: sortOrder ?? 0 });
  return success(res, { faq }, 'FAQ created', 201);
});

// PUT /api/v1/admin/faqs/:id
exports.updateFaq = catchAsync(async (req, res) => {
  const faq = await Faq.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!faq) throw new AppError('FAQ not found', 404);
  return success(res, { faq }, 'FAQ updated');
});

// DELETE /api/v1/admin/faqs/:id
exports.deleteFaq = catchAsync(async (req, res) => {
  const faq = await Faq.findByIdAndDelete(req.params.id);
  if (!faq) throw new AppError('FAQ not found', 404);
  return success(res, null, 'FAQ deleted');
});

// --- Content: Notification Blasts ---

// GET /api/v1/admin/notifications
exports.listNotifications = catchAsync(async (req, res) => {
  const notifications = await Notification.find().populate('sentBy', 'name').sort({ createdAt: -1 }).limit(50);
  return success(res, { notifications });
});

// POST /api/v1/admin/notifications  { title, body, audience }
// Sends a real push to matching recipients via notification.service.js
// (which no-ops quietly if Firebase isn't configured, same pattern as
// Maps - see backend/.env.example FIREBASE_* vars). Record is saved
// regardless, so the history list in Content > Announcements works either
// way.
exports.sendNotification = catchAsync(async (req, res) => {
  const { title, body, audience } = req.body;
  if (!title || !body) throw new AppError('title and body are required', 400);

  const recipientFilter = audience && audience !== 'all' ? { role: audience } : { role: { $in: ['customer', 'driver'] } };
  const recipients = await User.find(recipientFilter).select('_id');
  const recipientCount = recipients.length;

  const notification = await Notification.create({
    title,
    body,
    audience: audience || 'all',
    sentBy: req.user.id,
    status: isConfigured() ? 'sent' : 'queued',
    recipientCount,
  });

  sendToUsers(recipients.map((u) => u._id), { title, body, data: { type: 'admin_announcement' } });

  return success(res, { notification }, `Announcement ${isConfigured() ? 'sent to' : 'queued for'} ${recipientCount} recipient(s)`, 201);
});

// GET /api/v1/admin/enterprises?status=pending|approved&page=&limit=
// status=pending -> isActive:false (awaiting approval), status=approved -> isActive:true
exports.listEnterprises = catchAsync(async (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (status === 'pending') filter.isActive = false;
  if (status === 'approved') filter.isActive = true;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [enterprises, total] = await Promise.all([
    Enterprise.find(filter)
      .populate('adminUserId', 'name email')
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    Enterprise.countDocuments(filter),
  ]);

  return success(res, { enterprises, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// PUT /api/v1/admin/enterprises/:id/status  { isActive }
// isActive:true approves a pending signup; isActive:false suspends/rejects
// one (whether pending or previously-approved) - a single boolean serves
// both purposes rather than a separate reject state.
exports.updateEnterpriseStatus = catchAsync(async (req, res) => {
  const { isActive } = req.body;
  if (typeof isActive !== 'boolean') throw new AppError('isActive must be a boolean', 400);

  const enterprise = await Enterprise.findByIdAndUpdate(req.params.id, { isActive }, { new: true });
  if (!enterprise) throw new AppError('Enterprise not found', 404);

  return success(res, { enterprise }, isActive ? 'Enterprise approved' : 'Enterprise suspended');
});

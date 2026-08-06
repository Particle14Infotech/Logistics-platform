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
const Fleet = require('../models/fleet.model');
const WalletTransaction = require('../models/walletTransaction.model');
const Invoice = require('../models/invoice.model');
const { applyWalletTransaction } = require('../services/wallet.service');
const { sendToUsers, isConfigured } = require('../services/notification.service');
const razorpayService = require('../services/razorpay.service');
const { VEHICLE_MAX_WEIGHT_KG } = require('../config/vehicleCapacity');

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
      .populate('enterpriseId', 'companyName')
      .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating ratingCount', populate: { path: 'userId', select: 'name phone' } })
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
    .populate('enterpriseId', 'companyName')
    .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating ratingCount currentLocation', populate: { path: 'userId', select: 'name phone' } });

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

  // .lean() skips schema defaults, so drivers created before the wallet
  // feature existed would otherwise come back with walletBalance: undefined.
  const normalized = drivers.map((d) => ({ ...d, walletBalance: d.walletBalance ?? 0 }));

  return success(res, {
    drivers: search ? normalized.filter((d) => d.userId) : normalized,
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

// POST /api/v1/admin/drivers/:id/payout  { amount? }
// Marks a payout as settled - no bank-transfer automation exists yet, this
// is purely bookkeeping for whatever transfer the admin already did
// manually using driver.bankDetails. Defaults to paying out the full
// current balance if amount isn't given.
exports.payoutDriver = catchAsync(async (req, res) => {
  const driver = await Driver.findById(req.params.id);
  if (!driver) throw new AppError('Driver not found', 404);

  const amount = req.body.amount != null ? Number(req.body.amount) : driver.walletBalance;
  if (!(amount > 0)) throw new AppError('Payout amount must be greater than zero', 400);
  if (amount > driver.walletBalance) throw new AppError(`Cannot pay out ₹${amount} - wallet balance is only ₹${driver.walletBalance}`, 400);

  const updated = await applyWalletTransaction({
    driverId: driver._id,
    type: 'payout',
    amount: -amount,
    note: 'Payout processed by admin',
  });

  return success(res, { balance: updated.walletBalance }, 'Payout recorded');
});

// GET /api/v1/admin/drivers/:id/wallet - ledger for a specific driver
exports.getDriverWallet = catchAsync(async (req, res) => {
  const driver = await Driver.findById(req.params.id);
  if (!driver) throw new AppError('Driver not found', 404);

  const transactions = await WalletTransaction.find({ driverId: driver._id }).sort({ createdAt: -1 }).limit(100);
  return success(res, { balance: driver.walletBalance, transactions });
});

// GET /api/v1/admin/analytics - KPI + revenue snapshot for the dashboard
exports.analytics = catchAsync(async (req, res) => {
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  const sevenDaysAgo = new Date(todayStart);
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6); // 7 days inclusive of today

  // An order with advanceAmount > 0 (whichever vehicle types the admin has
  // configured that way at the time it was booked - see
  // pricingConfig.model.js) never had its full price captured in one shot.
  // Within that: a cod order only ever has its advance actually captured
  // online (the remainder is cash the driver collects directly, never
  // platform revenue in the sense this figure means); an online order has
  // captured either just the advance so far, or the full price once
  // remainderPaid flips true. Everything else (advanceAmount 0) is captured
  // in full at booking - 'paymentStatus: paid' already implies that.
  const paidAmountExpr = {
    $cond: [
      { $gt: ['$advanceAmount', 0] },
      { $cond: [{ $eq: ['$paymentMethod', 'cod'] }, '$advanceAmount', { $cond: ['$remainderPaid', '$price', '$advanceAmount'] }] },
      '$price',
    ],
  };

  const [
    ordersToday,
    revenueAgg,
    enterpriseRevenueAgg,
    activeDrivers,
    totalDrivers,
    deliveredToday,
    cancelledToday,
    dailyAgg,
    activeOrders,
    activeTrips,
    statusAgg,
    vehicleAgg,
    todayStatusAgg,
  ] = await Promise.all([
    Order.countDocuments({ createdAt: { $gte: todayStart } }),
    Order.aggregate([
      { $match: { createdAt: { $gte: todayStart }, paymentStatus: 'paid' } },
      { $group: { _id: null, total: { $sum: paidAmountExpr } } },
    ]),
    // Enterprise billing is a separate invoice-based system, not the
    // per-order Payment/paymentStatus flow individual customers use - an
    // enterprise order's own paymentStatus never becomes 'paid', so it was
    // previously invisible to both this figure and admin/payments entirely.
    // updatedAt is used as a paid-today proxy since Invoice has no
    // dedicated paidAt field.
    Invoice.aggregate([
      { $match: { status: 'paid', updatedAt: { $gte: todayStart } } },
      { $group: { _id: null, total: { $sum: '$totalAmount' } } },
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
          revenue: { $sum: { $cond: [{ $eq: ['$paymentStatus', 'paid'] }, paidAmountExpr, 0] } },
        },
      },
    ]),
    // "Active" here means still moving through the pipeline right now,
    // regardless of when it was created - unlike ordersToday, a shipment
    // booked yesterday that's still in_transit today is still active.
    Order.countDocuments({ status: { $in: ['pending', 'accepted', 'picked_up', 'in_transit', 'awaiting_payment'] } }),
    // Subset of the above that's actually assigned to a driver and moving
    // (excludes 'pending', which is still waiting for a driver to accept).
    Order.countDocuments({ status: { $in: ['accepted', 'picked_up', 'in_transit', 'awaiting_payment'] } }),
    Order.aggregate([
      { $match: { status: { $in: ['pending', 'accepted', 'picked_up', 'in_transit', 'awaiting_payment'] } } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
    Driver.aggregate([{ $match: { isApproved: true } }, { $group: { _id: '$vehicleType', count: { $sum: 1 } } }]),
    // Distinct from the "live right now" pipeline above (which mixes
    // regardless-of-creation-date pending/accepted/picked_up/in_transit
    // counts with today-only delivered/cancelled counts into one
    // confusing array) - this is every order actually created today,
    // grouped by whatever status it's at right now, so "today's activity"
    // has its own real answer instead of being folded into that one.
    Order.aggregate([
      { $match: { createdAt: { $gte: todayStart } } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
  ]);

  const completedToday = deliveredToday + cancelledToday;
  const successRate = completedToday > 0 ? (deliveredToday / completedToday) * 100 : 0;

  const statusCounts = { pending: 0, accepted: 0, picked_up: 0, in_transit: 0, awaiting_payment: 0 };
  statusAgg.forEach((s) => { statusCounts[s._id] = s.count; });
  const ordersByStatus = [
    { status: 'pending', label: 'Pending', count: statusCounts.pending },
    { status: 'accepted', label: 'Accepted', count: statusCounts.accepted },
    { status: 'picked_up', label: 'Picked up', count: statusCounts.picked_up },
    { status: 'in_transit', label: 'In transit', count: statusCounts.in_transit },
    { status: 'awaiting_payment', label: 'Awaiting payment', count: statusCounts.awaiting_payment },
    { status: 'delivered', label: 'Delivered (today)', count: deliveredToday },
    { status: 'cancelled', label: 'Cancelled (today)', count: cancelledToday },
  ];

  const todayStatusCounts = { pending: 0, accepted: 0, picked_up: 0, in_transit: 0, awaiting_payment: 0, delivered: 0, cancelled: 0 };
  todayStatusAgg.forEach((s) => { todayStatusCounts[s._id] = s.count; });
  const todayOrdersByStatus = [
    { status: 'pending', label: 'Pending', count: todayStatusCounts.pending },
    { status: 'accepted', label: 'Accepted', count: todayStatusCounts.accepted },
    { status: 'picked_up', label: 'Picked up', count: todayStatusCounts.picked_up },
    { status: 'in_transit', label: 'In transit', count: todayStatusCounts.in_transit },
    { status: 'awaiting_payment', label: 'Awaiting payment', count: todayStatusCounts.awaiting_payment },
    { status: 'delivered', label: 'Delivered', count: todayStatusCounts.delivered },
    { status: 'cancelled', label: 'Cancelled', count: todayStatusCounts.cancelled },
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

  const individualRevenueToday = revenueAgg[0]?.total ?? 0;
  const enterpriseRevenueToday = enterpriseRevenueAgg[0]?.total ?? 0;

  return success(res, {
    ordersToday,
    revenueToday: individualRevenueToday + enterpriseRevenueToday,
    individualRevenueToday,
    enterpriseRevenueToday,
    activeDrivers,
    totalDrivers,
    activeOrders,
    activeTrips,
    deliverySuccessRate: Math.round(successRate * 10) / 10,
    last7Days,
    ordersByStatus,
    todayOrdersByStatus,
    fleetByVehicleType,
  });
});

// GET /api/v1/admin/fleet-live - vehicles currently on an active trip, for
// the dashboard's FleetTicker (previously fed permanently-frozen mock data
// - see web-portal-admin/src/admin/dashboard/mockData.js - this is the real
// feed it was never wired to). No dedicated ETA service exists anywhere in
// the backend, so rather than fabricate one, this reports how fresh each
// vehicle's last known position is instead of a made-up arrival estimate.
exports.fleetLive = catchAsync(async (req, res) => {
  const orders = await Order.find({ status: { $in: ['accepted', 'picked_up', 'in_transit'] } })
    .populate({ path: 'driverId', select: 'vehicleNumber updatedAt' })
    .select('status pickupLocation dropLocation driverId')
    .sort({ updatedAt: -1 })
    .limit(20)
    .lean();

  // A driver can end up with more than one order in an "active" status in
  // this data (test/seed data mostly, but not schema-enforced either way) -
  // dedupe to one ticker entry per vehicle, keeping whichever is most
  // recently updated (orders are already sorted updatedAt desc above).
  const seenPlates = new Set();
  const vehicles = [];
  for (const o of orders) {
    if (!o.driverId || seenPlates.has(o.driverId.vehicleNumber)) continue;
    seenPlates.add(o.driverId.vehicleNumber);

    const minutesAgo = Math.max(0, Math.round((Date.now() - new Date(o.driverId.updatedAt).getTime()) / 60000));
    vehicles.push({
      plate: o.driverId.vehicleNumber,
      state: o.status === 'in_transit' ? 'in_transit' : 'loading',
      route: `${o.pickupLocation?.address ?? '—'} → ${o.dropLocation?.address ?? '—'}`,
      // Scaled to minutes/hours/days rather than always raw minutes - stale
      // seed/demo data (a driver untouched for days) was producing strings
      // like "Updated 14042m ago", long enough to overflow FleetTicker's
      // fixed-width chips and wrap into the row below it.
      eta:
        minutesAgo === 0
          ? 'Updated just now'
          : minutesAgo < 60
            ? `Updated ${minutesAgo}m ago`
            : minutesAgo < 1440
              ? `Updated ${Math.round(minutesAgo / 60)}h ago`
              : `Updated ${Math.round(minutesAgo / 1440)}d ago`,
    });
  }

  return success(res, { vehicles });
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

// GET /api/v1/admin/fleets?search=&page=&limit= - fleet-owner oversight list
exports.listFleets = catchAsync(async (req, res) => {
  const { search, page = 1, limit = 20 } = req.query;

  const filter = {};
  if (search) filter.companyName = { $regex: search, $options: 'i' };

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [fleets, total] = await Promise.all([
    Fleet.find(filter)
      .populate('ownerId', 'name phone email')
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    Fleet.countDocuments(filter),
  ]);

  const fleetsWithCounts = await Promise.all(
    fleets.map(async (fleet) => {
      const vehicles = await Driver.find({ fleetId: fleet._id }, 'isApproved documents').lean();
      const needsAttention = vehicles.filter(
        (v) => !v.isApproved || ['rcUrl', 'insuranceUrl', 'pollutionCertUrl'].some((k) => !v.documents?.[k])
      ).length;
      return {
        _id: fleet._id,
        companyName: fleet.companyName,
        owner: fleet.ownerId,
        createdAt: fleet.createdAt,
        vehicleCount: vehicles.length,
        needsAttention,
      };
    })
  );

  return success(res, {
    fleets: fleetsWithCounts,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) },
  });
});

// GET /api/v1/admin/fleets/:id - one fleet's owner + every vehicle/driver under it
exports.getFleetById = catchAsync(async (req, res) => {
  const fleet = await Fleet.findById(req.params.id).populate('ownerId', 'name phone email createdAt');
  if (!fleet) throw new AppError('Fleet not found', 404);

  const drivers = await Driver.find({ fleetId: fleet._id }).populate('userId', 'name phone email').lean();
  const vehicles = drivers.map((d) => {
    const missingCompliance = ['rcUrl', 'insuranceUrl', 'pollutionCertUrl'].filter((k) => !d.documents?.[k]);
    return {
      _id: d._id,
      vehicleNumber: d.vehicleNumber,
      vehicleType: d.vehicleType,
      isApproved: d.isApproved,
      isAvailable: d.isAvailable,
      rating: d.rating,
      ratingCount: d.ratingCount,
      driver: d.userId,
      documentsUploaded: Object.values(d.documents || {}).filter(Boolean).length,
      documentsTotal: Object.keys(d.documents || {}).length || 8,
      missingCompliance,
    };
  });

  return success(res, { fleet, vehicles });
});

// GET /api/v1/admin/pricing - current rate card for every vehicle type
exports.getPricing = catchAsync(async (req, res) => {
  const configs = await PricingConfig.find().sort({ vehicleType: 1 });
  // Older docs (predating maxWeightKg) show the hardcoded default here
  // rather than blank, so the admin always sees a real editable value.
  const pricing = configs.map((c) => {
    const doc = c.toObject();
    if (doc.maxWeightKg == null) doc.maxWeightKg = VEHICLE_MAX_WEIGHT_KG[doc.vehicleType];
    return doc;
  });
  return success(res, { pricing });
});

// PUT /api/v1/admin/pricing  { vehicleType, baseFare, perKmRate, perKgRate?, surgeMultiplier?, isSurgeActive?, advanceRequired?, advanceMode?, advanceValue?, maxWeightKg? }
exports.updatePricing = catchAsync(async (req, res) => {
  const { vehicleType, baseFare, perKmRate, perKgRate, surgeMultiplier, isSurgeActive, advanceRequired, advanceMode, advanceValue, maxWeightKg } = req.body;
  if (!vehicleType) throw new AppError('vehicleType is required', 400);

  // The admin pricing UI already clamps these client-side, but that's UX,
  // not enforcement - this is the actual guard. surgeMultiplier is the
  // sharp edge: calculateFare() (booking.controller.js) multiplies the
  // whole subtotal by it whenever isSurgeActive is true, so 0 (or an
  // empty field parsing to 0) zeroes out every fare for that vehicle type
  // platform-wide, not just this one config value. A negative baseFare/
  // perKmRate/perKgRate has the same effect in miniature - it subtracts
  // from the price instead of adding.
  const nonNegative = { baseFare, perKmRate, perKgRate };
  for (const [field, value] of Object.entries(nonNegative)) {
    if (value !== undefined && (typeof value !== 'number' || !Number.isFinite(value) || value < 0)) {
      throw new AppError(`${field} cannot be negative`, 400);
    }
  }
  if (surgeMultiplier !== undefined && (typeof surgeMultiplier !== 'number' || !Number.isFinite(surgeMultiplier) || surgeMultiplier <= 0)) {
    throw new AppError('surgeMultiplier must be greater than 0', 400);
  }
  if (maxWeightKg !== undefined && (typeof maxWeightKg !== 'number' || !Number.isFinite(maxWeightKg) || maxWeightKg <= 0)) {
    throw new AppError('maxWeightKg must be greater than 0', 400);
  }

  const config = await PricingConfig.findOneAndUpdate(
    { vehicleType },
    {
      $set: {
        ...(baseFare !== undefined && { baseFare }),
        ...(perKmRate !== undefined && { perKmRate }),
        ...(perKgRate !== undefined && { perKgRate }),
        ...(surgeMultiplier !== undefined && { surgeMultiplier }),
        ...(isSurgeActive !== undefined && { isSurgeActive }),
        ...(advanceRequired !== undefined && { advanceRequired }),
        ...(advanceMode !== undefined && { advanceMode }),
        ...(advanceValue !== undefined && { advanceValue }),
        ...(maxWeightKg !== undefined && { maxWeightKg }),
        updatedBy: req.user.id,
      },
    },
    { new: true, upsert: true }
  );

  return success(res, { pricing: config }, 'Pricing updated');
});

// GET /api/v1/admin/payments?status=&search=&page=&limit=
// Unifies individual customer payments (Payment collection - Razorpay
// checkout/cod advance) with enterprise invoices (Invoice collection -
// entirely separate billing path, never went through Payment/paymentStatus
// at all) into one list, so nothing is invisible here just because it came
// through a different billing mechanism. Two collections with different
// status vocabularies (StatusBadge already has color/label mappings for
// both) can't be paginated together at the DB level, so this fetches both
// fully and paginates the merged, sorted result in memory - fine at this
// project's scale.
exports.listPayments = catchAsync(async (req, res) => {
  const { status, search, page = 1, limit = 20 } = req.query;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const paymentFilter = {};
  if (status) paymentFilter.status = status;
  const invoiceFilter = {};
  if (status) invoiceFilter.status = status;

  const [payments, invoices] = await Promise.all([
    Payment.find(paymentFilter)
      .populate('userId', 'name email phone')
      .populate('orderId', 'pickupLocation dropLocation')
      .sort({ createdAt: -1 })
      .lean(),
    Invoice.find(invoiceFilter).populate('enterpriseId', 'companyName').sort({ createdAt: -1 }).lean(),
  ]);

  const individualRows = payments
    .filter((p) => !search || p.userId?.name?.toLowerCase().includes(search.toLowerCase()))
    .map((p) => ({
      _id: p._id,
      type: 'individual',
      reference: p.razorpayPaymentId ?? String(p._id).slice(-8),
      partyName: p.userId?.name ?? '—',
      route: p.orderId ? `${p.orderId.pickupLocation?.address ?? '?'} → ${p.orderId.dropLocation?.address ?? '?'}` : null,
      amount: p.amount, // already paise
      status: p.status,
      createdAt: p.createdAt,
    }));

  const enterpriseRows = invoices
    .filter((inv) => !search || inv.enterpriseId?.companyName?.toLowerCase().includes(search.toLowerCase()))
    .map((inv) => ({
      _id: inv._id,
      type: 'enterprise',
      reference: `INV-${String(inv._id).slice(-8).toUpperCase()}`,
      partyName: inv.enterpriseId?.companyName ?? '—',
      route: inv.periodStart && inv.periodEnd
        ? `${new Date(inv.periodStart).toLocaleDateString('en-IN')} – ${new Date(inv.periodEnd).toLocaleDateString('en-IN')}`
        : null,
      amount: Math.round((inv.totalAmount ?? 0) * 100), // rupees -> paise, to match individual rows
      status: inv.status,
      createdAt: inv.createdAt,
    }));

  const merged = [...individualRows, ...enterpriseRows].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  const total = merged.length;
  const pageRows = merged.slice((pageNum - 1) * limitNum, (pageNum - 1) * limitNum + limitNum);

  return success(res, {
    payments: pageRows,
    pagination: { page: pageNum, limit: limitNum, total, pages: Math.max(1, Math.ceil(total / limitNum)) },
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

// PUT /api/v1/admin/invoices/:id/status  { status }
// No online payment gateway is wired to enterprise invoices - this is
// bookkeeping for whatever bank transfer/settlement already happened
// offline, same "admin marks it done" pattern as the driver wallet payout.
exports.updateInvoiceStatus = catchAsync(async (req, res) => {
  const { status } = req.body;
  if (!['draft', 'sent', 'paid', 'overdue'].includes(status)) {
    throw new AppError("status must be one of: draft, sent, paid, overdue", 400);
  }
  const invoice = await Invoice.findByIdAndUpdate(req.params.id, { status }, { new: true });
  if (!invoice) throw new AppError('Invoice not found', 404);
  return success(res, { invoice }, 'Invoice status updated');
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

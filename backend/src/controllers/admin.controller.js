const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Driver = require('../models/driver.model');
const User = require('../models/user.model');

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

  const [ordersToday, revenueAgg, activeDrivers, deliveredToday, cancelledToday] = await Promise.all([
    Order.countDocuments({ createdAt: { $gte: todayStart } }),
    Order.aggregate([
      { $match: { createdAt: { $gte: todayStart }, paymentStatus: 'paid' } },
      { $group: { _id: null, total: { $sum: '$price' } } },
    ]),
    Driver.countDocuments({ isAvailable: true, isApproved: true }),
    Order.countDocuments({ createdAt: { $gte: todayStart }, status: 'delivered' }),
    Order.countDocuments({ createdAt: { $gte: todayStart }, status: 'cancelled' }),
  ]);

  const completedToday = deliveredToday + cancelledToday;
  const successRate = completedToday > 0 ? (deliveredToday / completedToday) * 100 : 0;

  return success(res, {
    ordersToday,
    revenueToday: revenueAgg[0]?.total ?? 0,
    activeDrivers,
    deliverySuccessRate: Math.round(successRate * 10) / 10,
  });
});

// PUT /api/v1/admin/pricing - base fare / per-km / surge config
// TODO: back this with a dedicated PricingConfig collection (per city/vehicle type).
// Stubbed as a no-op success until that collection + admin UI form exist.
exports.updatePricing = catchAsync(async (req, res) => {
  return success(res, { received: req.body }, 'Pricing config received (persistence not yet implemented)', 200);
});

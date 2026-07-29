const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Driver = require('../models/driver.model');
const PricingConfig = require('../models/pricingConfig.model');
const { getRoadDistanceKm } = require('../services/maps.service');
const { sendToUser, sendToUsers } = require('../services/notification.service');
const { VEHICLE_MAX_WEIGHT_KG } = require('../config/vehicleCapacity');

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

  return success(res, { distanceKm, estimatedPrice, breakdown });
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
  } = req.body;

  if (!pickupLocation?.address || !dropLocation?.address || !vehicleType) {
    throw new AppError('pickupLocation, dropLocation, and vehicleType are required', 400);
  }
  if (weightKg) assertWeightWithinCapacity(vehicleType, weightKg);

  const finalDistanceKm = distanceKm || 10;
  // Price is always recalculated server-side - never trust a client-sent price.
  const { estimatedPrice } = await calculateFare({ vehicleType, distanceKm: finalDistanceKm, weightKg });

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
    select: 'vehicleNumber vehicleType rating currentLocation',
    populate: { path: 'userId', select: 'name phone' },
  });
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  if (!isOwner && req.user.role !== 'admin') throw new AppError('Not authorized to view this booking', 403);

  // Delivery OTP is only meaningful (and only shown) once the driver has
  // picked up - it's how the customer proves receipt at drop-off, standing
  // in for a real SMS-delivered code since no SMS gateway is wired here.
  const orderObj = order.toObject();
  if (!['picked_up', 'in_transit'].includes(order.status)) {
    delete orderObj.deliveryOtp;
  }

  return success(res, { order: orderObj });
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
      .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating', populate: { path: 'userId', select: 'name phone' } })
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

  if (['delivered', 'cancelled'].includes(order.status)) {
    throw new AppError(`Cannot cancel a booking that is already ${order.status}`, 400);
  }

  order.status = 'cancelled';
  order.timeline.push({ status: 'cancelled', note: 'Cancelled by customer' });
  await order.save();

  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'cancelled', timestamp: Date.now() });

  return success(res, { order }, 'Booking cancelled');
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

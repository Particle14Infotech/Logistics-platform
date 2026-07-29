const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Driver = require('../models/driver.model');
const Order = require('../models/order.model');
const { sendToUser } = require('../services/notification.service');

// Local-disk storage for dev (uploads/ served statically by app.js). Swap
// for an S3 multer-storage adapter in production using the AWS_* vars
// already present in .env.example.
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, '../../uploads')),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `${req.user.id}-${crypto.randomBytes(6).toString('hex')}${ext}`);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) return cb(new AppError('Only image files are allowed', 400));
    cb(null, true);
  },
});
exports.uploadMiddleware = upload.single('file');

// Maps the :documentType route param to the corresponding field on
// Driver.documents - keeps the URL/param a stable, readable key ('license',
// 'rc', ...) independent of the exact schema field name.
const DOCUMENT_TYPE_MAP = {
  photo: 'photoUrl',
  license: 'licenseUrl',
  rc: 'rcUrl',
  aadhaar: 'aadhaarUrl',
  insurance: 'insuranceUrl',
  permit: 'permitUrl',
  pollution: 'pollutionCertUrl',
  pan: 'panCardUrl',
};

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

async function getOwnDriverDoc(userId) {
  const driver = await Driver.findOne({ userId });
  if (!driver) throw new AppError('No driver profile found for this account', 404);
  return driver;
}

// POST /api/v1/driver/documents/:documentType  (multipart, field name 'file')
// Generic KYC document upload - covers all 8 document types (selfie photo,
// license, RC, Aadhaar, insurance, permit, pollution cert, PAN), all
// stored on Driver.documents and displayed in the Admin > Drivers KYC
// review grid, which already knows about every one of these fields.
// NOTE: this saves the file and records the URL - it does not run any OCR/
// authenticity verification. A human admin reviewing each document is the
// actual verification step today.
exports.uploadDocument = catchAsync(async (req, res) => {
  const { documentType } = req.params;
  const field = DOCUMENT_TYPE_MAP[documentType];
  if (!field) throw new AppError(`Unknown document type "${documentType}"`, 400);
  if (!req.file) throw new AppError('No file received', 400);

  const driver = await Driver.findOne({ userId: req.user.id });
  if (!driver) throw new AppError('Complete vehicle setup before uploading documents', 404);

  driver.documents = { ...(driver.documents || {}), [field]: `/uploads/${req.file.filename}` };
  await driver.save();

  return success(res, { documentType, url: driver.documents[field] }, 'Document uploaded for review');
});

// GET /api/v1/driver/profile
exports.getProfile = catchAsync(async (req, res) => {
  const driver = await Driver.findOne({ userId: req.user.id });
  // 404 here is expected for a brand-new driver who hasn't completed vehicle
  // setup yet - the app treats that as "show the setup screen", not an error.
  if (!driver) return success(res, { driver: null });
  return success(res, { driver });
});

// POST /api/v1/driver/profile  { vehicleType, vehicleNumber, licenseNumber }
// Creates the Driver record for a first-time signup. Starts unapproved -
// shows up in the Admin > Drivers "Pending review" queue immediately.
exports.createProfile = catchAsync(async (req, res) => {
  const existing = await Driver.findOne({ userId: req.user.id });
  if (existing) throw new AppError('A driver profile already exists for this account', 400);

  const { vehicleType, vehicleNumber, licenseNumber } = req.body;
  if (!vehicleType || !vehicleNumber || !licenseNumber) {
    throw new AppError('vehicleType, vehicleNumber, and licenseNumber are required', 400);
  }

  const driver = await Driver.create({
    userId: req.user.id,
    vehicleType,
    vehicleNumber,
    licenseNumber,
    isApproved: false,
    isAvailable: false,
  });

  return success(res, { driver }, 'Profile submitted - pending admin approval', 201);
});

// GET /api/v1/driver/available-orders
// NOTE: filters to pending, unassigned orders matching the driver's vehicle
// type, excluding orders this driver already passed on (rejectedDriverIds,
// set by rejectOrder below) - real geospatial "nearby" filtering needs live
// lat/lng from the customer app's location picker, which isn't wired yet
// (no Maps key) - see booking.controller.js's estimate() for the same
// limitation.
exports.availableOrders = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  if (!driver.isApproved) throw new AppError('Your account is pending KYC approval', 403);

  const orders = await Order.find({
    status: 'pending',
    driverId: null,
    vehicleType: driver.vehicleType,
    rejectedDriverIds: { $ne: driver._id },
  })
    .populate('customerId', 'name phone')
    .sort({ createdAt: 1 })
    .limit(20);

  return success(res, { orders });
});

// POST /api/v1/driver/accept/:bookingId
exports.acceptOrder = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  if (!driver.isApproved) throw new AppError('Your account is pending KYC approval', 403);
  if (!driver.isAvailable) throw new AppError('Go online before accepting jobs', 400);

  const orderCheck = await Order.findById(req.params.bookingId);
  if (!orderCheck) throw new AppError('Booking not found', 404);
  if (orderCheck.vehicleType !== driver.vehicleType) {
    throw new AppError('Vehicle type mismatch', 400);
  }

  // Atomic compare-and-swap: without this, two drivers hitting Accept on the
  // same order within the same instant could both pass a plain
  // findById + JS-side status check before either had saved, and both
  // would get a 200 "Booking accepted" - whichever .save() landed second
  // would silently overwrite the first driver's assignment. Matching the
  // query's status/driverId conditions in the update itself means only one
  // concurrent request can ever succeed; the other gets null back.
  const order = await Order.findOneAndUpdate(
    { _id: req.params.bookingId, status: 'pending', driverId: null },
    {
      $set: { driverId: driver._id, status: 'accepted' },
      $push: { timeline: { status: 'accepted', note: `Accepted by driver ${driver.vehicleNumber}` } },
    },
    { new: true }
  );
  if (!order) throw new AppError('This booking is no longer available', 409);

  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'accepted', timestamp: Date.now() });
  sendToUser(order.customerId, {
    title: 'Driver assigned!',
    body: `A driver is on the way for your ${driver.vehicleType.replace('_', ' ')} booking.`,
    data: { bookingId: String(order._id), status: 'accepted' },
  });

  return success(res, { order }, 'Booking accepted');
});

// POST /api/v1/driver/reject/:bookingId
// Records this driver's pass on rejectedDriverIds so availableOrders
// excludes it going forward - previously this was a no-op acknowledgment
// only, so a passed job reappeared for the same driver on the very next
// poll (contradicting what "Pass" tells the driver just happened).
exports.rejectOrder = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findById(req.params.bookingId);
  if (!order) throw new AppError('Booking not found', 404);

  if (!order.rejectedDriverIds.some((id) => String(id) === String(driver._id))) {
    order.rejectedDriverIds.push(driver._id);
    await order.save();
  }

  return success(res, null, 'Booking passed');
});

exports.updateStatus = catchAsync(async (req, res) => {
  const { isAvailable } = req.body;
  const driver = await getOwnDriverDoc(req.user.id);

  if (isAvailable && !driver.isApproved) {
    throw new AppError('Your account is pending KYC approval', 403);
  }

  driver.isAvailable = Boolean(isAvailable);
  await driver.save();

  return success(res, { driver }, isAvailable ? "You're online" : "You're offline");
});

// GET /api/v1/driver/orders?status=&page=&limit= - this driver's assigned trips
exports.listMyOrders = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const { status, page = 1, limit = 20 } = req.query;

  const filter = { driverId: driver._id };
  if (status) filter.status = status;

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [orders, total] = await Promise.all([
    Order.find(filter)
      .populate('customerId', 'name phone')
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum),
    Order.countDocuments(filter),
  ]);

  return success(res, { orders, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// GET /api/v1/driver/orders/:id
exports.getOrder = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findOne({ _id: req.params.id, driverId: driver._id }).populate('customerId', 'name phone');
  if (!order) throw new AppError('Trip not found', 404);
  return success(res, { order });
});

// PUT /api/v1/driver/orders/:id/status  { status: 'picked_up' | 'in_transit' }
// Delivered is handled separately by uploadPod below, since it needs OTP
// verification. Generates a delivery OTP when moving to picked_up, which
// booking.controller.js's getById exposes back to the customer so they can
// hand the code to the driver in person - a stand-in for SMS delivery.
exports.updateOrderStatus = catchAsync(async (req, res) => {
  const { status, note } = req.body;
  if (!['picked_up', 'in_transit'].includes(status)) {
    throw new AppError('status must be picked_up or in_transit', 400);
  }

  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findOne({ _id: req.params.id, driverId: driver._id });
  if (!order) throw new AppError('Trip not found', 404);

  const validTransitions = { accepted: 'picked_up', picked_up: 'in_transit' };
  if (validTransitions[order.status] !== status) {
    throw new AppError(`Cannot move from "${order.status}" to "${status}"`, 400);
  }

  order.status = status;
  if (status === 'picked_up' && !order.deliveryOtp) {
    order.deliveryOtp = generateOtp();
  }
  const baseNote = `Marked ${status.replace('_', ' ')} by driver`;
  order.timeline.push({ status, note: note ? `${baseNote} (barcode: ${note})` : baseNote });
  await order.save();

  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status, timestamp: Date.now() });
  const statusMessages = {
    picked_up: 'Your shipment has been picked up.',
    in_transit: 'Your shipment is on its way.',
  };
  sendToUser(order.customerId, {
    title: 'Booking update',
    body: statusMessages[status] ?? `Your booking status changed to ${status}.`,
    data: { bookingId: String(order._id), status },
  });

  return success(res, { order }, 'Status updated');
});

// POST /api/v1/driver/pod/:bookingId  { otp }
exports.uploadPod = catchAsync(async (req, res) => {
  const { otp } = req.body;
  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findOne({ _id: req.params.bookingId, driverId: driver._id });
  if (!order) throw new AppError('Trip not found', 404);
  if (order.status !== 'in_transit') throw new AppError('Trip must be in transit before delivery can be confirmed', 400);
  if (!otp || otp !== order.deliveryOtp) throw new AppError('Incorrect delivery code', 400);

  order.status = 'delivered';
  order.timeline.push({ status: 'delivered', note: 'Delivery confirmed via OTP' });
  await order.save();

  driver.totalTrips += 1;
  driver.totalEarnings += order.price;
  await driver.save();

  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'delivered', timestamp: Date.now() });
  sendToUser(order.customerId, {
    title: 'Delivered!',
    body: 'Your shipment has been delivered successfully.',
    data: { bookingId: String(order._id), status: 'delivered' },
  });

  return success(res, { order }, 'Delivery confirmed');
});

// GET /api/v1/driver/earnings
exports.earnings = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);

  const weekStart = new Date();
  weekStart.setDate(weekStart.getDate() - 7);
  const monthStart = new Date();
  monthStart.setDate(1);
  monthStart.setHours(0, 0, 0, 0);

  const [weekAgg, monthAgg] = await Promise.all([
    Order.aggregate([
      { $match: { driverId: driver._id, status: 'delivered', updatedAt: { $gte: weekStart } } },
      { $group: { _id: null, total: { $sum: '$price' }, trips: { $sum: 1 } } },
    ]),
    Order.aggregate([
      { $match: { driverId: driver._id, status: 'delivered', updatedAt: { $gte: monthStart } } },
      { $group: { _id: null, total: { $sum: '$price' }, trips: { $sum: 1 } } },
    ]),
  ]);

  return success(res, {
    totalEarnings: driver.totalEarnings,
    totalTrips: driver.totalTrips,
    thisWeek: { total: weekAgg[0]?.total ?? 0, trips: weekAgg[0]?.trips ?? 0 },
    thisMonth: { total: monthAgg[0]?.total ?? 0, trips: monthAgg[0]?.trips ?? 0 },
  });
});

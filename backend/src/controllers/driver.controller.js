const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Driver = require('../models/driver.model');
const Order = require('../models/order.model');
const Enterprise = require('../models/enterprise.model');
const { assertValidVehicleType, getVehicleCategoryName } = require('../services/vehicleCategory.service');
const WalletTransaction = require('../models/walletTransaction.model');
const { sendToUser } = require('../services/notification.service');
const { completeDelivery } = require('../services/delivery.service');

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

// Pickup documents (LR copy, invoice, packing list, gate pass - whatever
// the consignor physically hands over) - deliberately no fileFilter, since
// unlike a selfie/KYC photo this can legitimately be a PDF, a Word doc, or
// anything else, not just an image. Same 5MB-per-file ceiling as the image
// uploader above (basic abuse/storage hygiene, not a real limit anyone
// hits from paperwork photos or scans) and no cap on file count at all -
// multer just accepts as many parts as the request actually has.
const pickupDocsUpload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
});
exports.uploadPickupDocumentsMiddleware = pickupDocsUpload.array('files');
// Same multer instance (no fileFilter, no count cap) reused for delivery-
// side documents - the upload mechanics are identical, only the allowed
// order status and the field they're saved to differ. See
// uploadDeliveryDocuments below.
exports.uploadDeliveryDocumentsMiddleware = pickupDocsUpload.array('files');

// Shared with admin.controller.js (see that file's updateDriverDocument) so
// the driver app's own upload and the admin portal's replace/upload can
// never drift out of sync on which param maps to which field.
const DOCUMENT_TYPE_MAP = require('../constants/driverDocumentTypes');

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

async function getOwnDriverDoc(userId) {
  const driver = await Driver.findOne({ userId });
  if (!driver) throw new AppError('No driver profile found for this account', 404);
  return driver;
}

// POST /api/v1/driver/documents/:documentType  (multipart, field name 'file')
// Generic KYC document upload - covers every document type in
// DOCUMENT_TYPE_MAP (selfie photo, license/RC/Aadhaar front+back, insurance,
// permit, pollution cert, PAN, cancelled cheque), all stored on
// Driver.documents and displayed in the Admin > Drivers KYC review grid,
// which already knows about every one of these fields.
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

// POST /api/v1/driver/orders/:id/pickup-documents  (multipart, field name 'files', repeatable)
// Paperwork handed over at the pickup point - any format, any number of
// files, additive (each call appends rather than replacing). Only allowed
// once the trip is actually picked_up (there's nothing to upload before
// that), and this is the same requirement updateOrderStatus checks before
// allowing picked_up -> in_transit.
exports.uploadPickupDocuments = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findOne({ _id: req.params.id, driverId: driver._id });
  if (!order) throw new AppError('Trip not found', 404);
  if (order.status !== 'picked_up') {
    throw new AppError('Pickup documents can only be added once the shipment has been picked up', 400);
  }
  if (!req.files || req.files.length === 0) throw new AppError('No files received', 400);

  const newDocs = req.files.map((f) => ({ url: `/uploads/${f.filename}`, originalName: f.originalname }));
  order.pickupDocuments.push(...newDocs);
  await order.save();

  return success(res, { pickupDocuments: order.pickupDocuments }, `${newDocs.length} document(s) uploaded`);
});

// POST /api/v1/driver/orders/:id/delivery-documents  (multipart, field name 'files', repeatable)
// Proof-of-delivery paperwork - any format, any number of files, additive.
// Only allowed while the trip is in_transit (the stage before delivery is
// confirmed) - this is the same requirement uploadPod checks below before
// allowing in_transit -> awaiting_payment/delivered.
exports.uploadDeliveryDocuments = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findOne({ _id: req.params.id, driverId: driver._id });
  if (!order) throw new AppError('Trip not found', 404);
  if (order.status !== 'in_transit') {
    throw new AppError('Delivery documents can only be added while the trip is in transit', 400);
  }
  if (!req.files || req.files.length === 0) throw new AppError('No files received', 400);

  const newDocs = req.files.map((f) => ({ url: `/uploads/${f.filename}`, originalName: f.originalname }));
  order.deliveryDocuments.push(...newDocs);
  await order.save();

  return success(res, { deliveryDocuments: order.deliveryDocuments }, `${newDocs.length} document(s) uploaded`);
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

  const { vehicleType, vehicleNumber, licenseNumber, enterpriseInviteCode } = req.body;
  if (!vehicleType || !vehicleNumber || !licenseNumber) {
    throw new AppError('vehicleType, vehicleNumber, and licenseNumber are required', 400);
  }
  await assertValidVehicleType(vehicleType);

  // Optional - links this driver to an enterprise's private fleet instead
  // of the public marketplace (see Driver.enterpriseId). A code that
  // doesn't match rejects loudly rather than silently registering the
  // driver as independent, so a typo doesn't quietly misroute them.
  let enterpriseId = null;
  if (enterpriseInviteCode) {
    const enterprise = await Enterprise.findOne({
      driverInviteCode: enterpriseInviteCode.trim().toUpperCase(),
      isActive: true,
    });
    if (!enterprise) throw new AppError('Invalid enterprise invite code', 400);
    enterpriseId = enterprise._id;
  }

  const driver = await Driver.create({
    userId: req.user.id,
    vehicleType,
    vehicleNumber,
    licenseNumber,
    enterpriseId,
    isApproved: false,
    isAvailable: false,
  });

  return success(res, { driver }, 'Profile submitted - pending admin approval', 201);
});

// PUT /api/v1/driver/vehicle  { vehicleType, vehicleNumber }
// Changing vehicle info resets isApproved to false, same reasoning as a
// fresh KYC submission - the admin's approval was for a specific
// vehicle/plate, so a change needs a quick re-review, mirroring how
// document re-uploads already require re-approval.
exports.updateVehicle = catchAsync(async (req, res) => {
  const driver = await Driver.findOne({ userId: req.user.id });
  if (!driver) throw new AppError('No driver profile found', 404);

  const { vehicleType, vehicleNumber } = req.body;
  if (!vehicleType || !vehicleNumber) throw new AppError('vehicleType and vehicleNumber are required', 400);
  await assertValidVehicleType(vehicleType);

  driver.vehicleType = vehicleType;
  driver.vehicleNumber = vehicleNumber;
  driver.isApproved = false;
  await driver.save();

  return success(res, { driver }, 'Vehicle updated - pending re-approval');
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
    // Dedicated enterprise drivers only see that enterprise's own orders;
    // independent drivers only see the public marketplace pool. Orders
    // placed by an enterprise are reserved for that enterprise's private
    // fleet, not the shared pool, and vice versa.
    enterpriseId: driver.enterpriseId ?? null,
    // Any order with an advance due isn't shown to drivers (or "registered"
    // to the customer as a real, trackable booking) until that advance is
    // actually paid - that's the whole point of the advance (no-show/fraud
    // protection), so it can't be skipped by just never paying it. This
    // applies regardless of paymentMethod - an 'online' order still owes
    // the same upfront advance as a gated 'cod' one, just a different
    // remainder-collection method. Ungated orders (advanceAmount 0) have no
    // advance to wait for, so they're visible immediately.
    $or: [{ advanceAmount: 0 }, { paymentStatus: 'paid' }],
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
  // Belt-and-suspenders on top of availableOrders' filtering - a direct
  // API call must not be able to cross the enterprise/public-pool
  // boundary just because availableOrders never surfaced this order.
  const orderEnterpriseId = orderCheck.enterpriseId ? String(orderCheck.enterpriseId) : null;
  const driverEnterpriseId = driver.enterpriseId ? String(driver.enterpriseId) : null;
  if (orderEnterpriseId !== driverEnterpriseId) {
    throw new AppError('This booking is not available to your account', 403);
  }
  // Same belt-and-suspenders for cod's advance-paid gate as the
  // enterprise check above - a direct API call must not be able to accept
  // an unpaid cod order just because availableOrders never surfaced it.
  // Ungated cod (advanceAmount 0) has nothing to wait for.
  if (orderCheck.paymentMethod === 'cod' && orderCheck.advanceAmount > 0 && orderCheck.paymentStatus !== 'paid') {
    throw new AppError('This booking is not available yet - the customer has not paid the advance', 400);
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
    body: `A driver is on the way for your ${await getVehicleCategoryName(driver.vehicleType)} booking.`,
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

// PUT /api/v1/driver/location  { bookingId, lat, lng }
// A plain REST fallback for driver_location_update (the Socket.IO event
// active_trip_screen.dart normally uses) - the background foreground-service
// task handler runs in its own isolate with no access to the app's live
// socket connection, so it calls this instead. Same effect either way:
// persists Driver.currentLocation and broadcasts to the booking room.
exports.updateLocation = catchAsync(async (req, res) => {
  const { bookingId, lat, lng } = req.body;
  if (!bookingId || lat == null || lng == null) {
    throw new AppError('bookingId, lat, and lng are required', 400);
  }

  const driver = await getOwnDriverDoc(req.user.id);
  driver.currentLocation = { type: 'Point', coordinates: [lng, lat] };
  await driver.save();

  const io = req.app.get('io');
  if (io) {
    io.to(`booking:${bookingId}`).emit('location_broadcast', {
      bookingId,
      lat,
      lng,
      timestamp: Date.now(),
    });
  }

  return success(res, {}, 'Location updated');
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

// PUT /api/v1/driver/orders/:id/status  { status: 'picked_up' | 'in_transit', pickupCode?, otp? }
// Delivered is handled separately by uploadPod below, since it needs OTP
// verification. Generates a start OTP and a delivery OTP when moving to
// picked_up (both up front, so the customer has them ready) -
// booking.controller.js's getById exposes each back to the customer at the
// right time, a stand-in for SMS delivery. The start OTP mirrors the
// delivery OTP but confirms the driver is actually beginning the trip
// (picked_up -> in_transit, the "Start trip" action) rather than final
// drop-off - previously that transition had no verification at all.
//
// pickupCode is the order's own id, shown as a QR in the customer app and
// scanned here - previously a scanned barcode was just logged as free text
// on the timeline note, never actually checked against anything.
exports.updateOrderStatus = catchAsync(async (req, res) => {
  const { status, pickupCode, otp, manualConfirm } = req.body;
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

  // Pickup can be confirmed two ways: scanning the customer's QR (checked
  // against the real order id below) or a plain, deliberately unverified
  // manual tap (manualConfirm) for when scanning genuinely isn't possible -
  // a product decision to keep that fallback frictionless rather than
  // asking the driver to type anything.
  if (status === 'picked_up' && !manualConfirm) {
    if (pickupCode !== order._id.toString()) {
      throw new AppError("Incorrect pickup code - scan the QR code shown in the customer's app", 400);
    }
  }
  if (status === 'in_transit' && (!otp || otp !== order.startOtp)) {
    throw new AppError('Incorrect start code', 400);
  }
  // Paperwork the consignor hands over at pickup - required before the
  // trip can actually start, same as the start code itself. Checked here
  // (not just left to the app to enforce) since this is the one place
  // that transition can really happen - a client-side-only check would be
  // trivial to bypass by calling the API directly.
  if (status === 'in_transit' && order.pickupDocuments.length === 0) {
    throw new AppError('Upload the pickup documents before starting the trip', 400);
  }

  order.status = status;
  if (status === 'picked_up' && !order.deliveryOtp) {
    order.deliveryOtp = generateOtp();
    order.startOtp = generateOtp();
  }
  let baseNote = `Marked ${status.replace('_', ' ')} by driver`;
  if (status === 'picked_up') baseNote = manualConfirm ? 'Picked up (marked manually, no scan)' : 'Picked up (pickup code verified)';
  if (status === 'in_transit') baseNote = 'Trip started (start code verified)';
  order.timeline.push({ status, note: baseNote });
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

// POST /api/v1/driver/pod/:bookingId  { otp, cashCollected? }
exports.uploadPod = catchAsync(async (req, res) => {
  const { otp, cashCollected } = req.body;
  const driver = await getOwnDriverDoc(req.user.id);
  const order = await Order.findOne({ _id: req.params.bookingId, driverId: driver._id });
  if (!order) throw new AppError('Trip not found', 404);
  if (order.status !== 'in_transit') throw new AppError('Trip must be in transit before delivery can be confirmed', 400);
  // Proof-of-delivery paperwork, required before the trip can actually end -
  // mirrors the pickupDocuments check in updateOrderStatus above, just at
  // the opposite transition. Checked server-side (not just left to the app)
  // since this is the one place the transition can really happen.
  if (order.deliveryDocuments.length === 0) {
    throw new AppError('Upload the delivery documents before completing delivery', 400);
  }
  if (!otp || otp !== order.deliveryOtp) throw new AppError('Incorrect delivery code', 400);
  // The remaining cash must be physically collected before a cod delivery
  // can be finalized - closes the loop with an explicit record, rather
  // than just assuming it happened. Works unchanged for ungated cod too -
  // advanceAmount is 0 there, so the full price is due in cash.
  if (order.paymentMethod === 'cod' && !cashCollected) {
    throw new AppError(`Confirm you've collected the remaining ₹${order.price - order.advanceAmount} cash before completing delivery`, 400);
  }
  // For a gated online order, the remaining amount is a second Razorpay
  // payment the customer makes themselves - the driver can't self-attest it
  // like cash. Rather than blocking here, drop-off is confirmed (OTP
  // verified) and the order moves to 'awaiting_payment' - the payment
  // itself is what completes the delivery, see payment.controller.js's
  // verify()/webhook().
  const pendingOnlineRemainder = order.paymentMethod === 'online' && order.advanceAmount > 0 && !order.remainderPaid;

  // Atomically claim the in_transit -> {awaiting_payment|delivered}
  // transition, rather than a plain order.save() - closes a double-tap
  // race (driver taps "Confirm delivery" twice under network lag) that
  // would otherwise let two concurrent requests both pass the checks above
  // and both run the completion path (and its wallet credit / driver
  // stats) for the same trip. Only one concurrent call's filter can still
  // match 'in_transit' once the other has written its update.
  const claimed = await Order.findOneAndUpdate(
    { _id: order._id, status: 'in_transit' },
    pendingOnlineRemainder
      ? { status: 'awaiting_payment' }
      : { status: 'delivered', ...(order.paymentMethod === 'cod' ? { codCashCollected: true } : {}) },
    { new: true }
  );
  if (!claimed) throw new AppError('This trip was already completed', 409);

  if (pendingOnlineRemainder) {
    claimed.timeline.push({ status: 'awaiting_payment', note: 'Drop-off confirmed via OTP - awaiting remaining online payment' });
    await claimed.save();

    const io = req.app.get('io');
    if (io) io.to(`booking:${claimed._id}`).emit('status_broadcast', { bookingId: claimed._id, status: 'awaiting_payment', timestamp: Date.now() });
    sendToUser(claimed.customerId, {
      title: 'Almost done!',
      body: `Pay the remaining ₹${claimed.price - claimed.advanceAmount} online to complete your delivery.`,
      data: { bookingId: String(claimed._id), status: 'awaiting_payment' },
    });

    return success(res, { order: claimed }, 'Drop-off confirmed - waiting for the customer to pay the remaining amount online');
  }

  await completeDelivery({ order: claimed, driver, io: req.app.get('io') });

  return success(res, { order: claimed }, 'Delivery confirmed');
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

// GET /api/v1/driver/wallet - balance + recent ledger entries (trip
// earnings, cancellation compensation, payouts). Pagination isn't needed
// yet at expected transaction volumes; revisit if this list gets long.
exports.wallet = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const transactions = await WalletTransaction.find({ driverId: driver._id })
    .sort({ createdAt: -1 })
    .limit(100);

  return success(res, { balance: driver.walletBalance, transactions });
});

// PUT /api/v1/driver/bank-details  { accountNumber, ifsc, accountHolderName }
// Used by admin.controller.js's payoutDriver as the reference for where a
// manual bank transfer actually went - no automated payout integration
// reads this directly.
exports.updateBankDetails = catchAsync(async (req, res) => {
  const driver = await getOwnDriverDoc(req.user.id);
  const { accountNumber, ifsc, accountHolderName } = req.body;
  if (!accountNumber || !ifsc || !accountHolderName) {
    throw new AppError('accountNumber, ifsc, and accountHolderName are all required', 400);
  }

  driver.bankDetails = { accountNumber, ifsc, accountHolderName };
  await driver.save();

  return success(res, { driver }, 'Bank details updated');
});

const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const PDFDocument = require('pdfkit');
const { catchAsync, success, AppError } = require('../utils/apiResponse');
const { signAccessToken, signRefreshToken } = require('../utils/jwt');
const { admin, ensureInitialized } = require('../config/firebaseAdmin');
const User = require('../models/user.model');
const Enterprise = require('../models/enterprise.model');
const Driver = require('../models/driver.model');
const Order = require('../models/order.model');
const Invoice = require('../models/invoice.model');
const { VEHICLE_MAX_WEIGHT_KG } = require('../config/vehicleCapacity');

const VEHICLE_BASE_PRICE = { bike: 100, auto: 150, mini_truck: 300, medium_truck: 600, large_truck: 1000 };

// Resolves the Enterprise doc for the logged-in user, whether they're the
// admin (adminUserId) or an invited sub-user (subUsers array). JWTs only
// carry { id, role }, so this always looks it up fresh rather than trusting
// a cached enterpriseId on the User doc.
//
// requireActive gates every enterprise feature behind admin approval
// (isActive) by default - the one exception is the `status` endpoint below,
// which needs to report isActive:false without throwing. selectApiKey pulls
// back the otherwise select:false apiKey field for getApiKey.
async function resolveEnterprise(userId, { requireActive = true, selectApiKey = false } = {}) {
  const projection = selectApiKey ? '+apiKey' : undefined;
  let enterprise = await Enterprise.findOne({ adminUserId: userId }).select(projection);
  if (!enterprise) enterprise = await Enterprise.findOne({ subUsers: userId }).select(projection);
  if (!enterprise) throw new AppError('No enterprise account associated with this user', 404);
  if (requireActive && !enterprise.isActive) {
    throw new AppError('Your enterprise account is pending approval', 403);
  }
  return enterprise;
}

// POST /api/v1/enterprise/signup  { companyName, contactName, email, password, gstin?, billingEmail? }
// Public self-service signup: creates the User (role: enterprise_admin) and
// its Enterprise doc together, starting inactive (Enterprise.model.js
// isActive defaults to false) until an admin approves it via
// PUT /admin/enterprises/:id/status. Logs the user in immediately (same
// token shape as verifyOtp/firebaseSession) so the frontend can show a
// pending-approval screen instead of an email-verification wait.
exports.signup = catchAsync(async (req, res) => {
  const { companyName, contactName, email, password, gstin, billingEmail } = req.body;
  if (!companyName || !contactName || !email || !password) {
    throw new AppError('companyName, contactName, email, and password are required', 400);
  }
  if (password.length < 6) throw new AppError('Password must be at least 6 characters', 400);

  const existing = await User.findOne({ email });
  if (existing) throw new AppError('An account with this email already exists', 400);

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ name: contactName, email, passwordHash, role: 'enterprise_admin' });

  const enterprise = await Enterprise.create({ companyName, gstin, billingEmail, adminUserId: user._id });
  user.enterpriseId = enterprise._id;
  await user.save();

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  return success(res, { user, accessToken, refreshToken, enterprise }, 'Enterprise account created - pending approval', 201);
});

// POST /api/v1/enterprise/firebase-signup  { idToken, companyName, contactName, gstin?, billingEmail? }
// Firebase-credentialed counterpart to the bcrypt `signup` above - Firebase
// owns the password + email verification, this just exchanges a verified ID
// token for a session. Also handles migrating an existing bcrypt account
// (e.g. a seeded/pre-Firebase enterprise_admin) onto a Firebase identity:
// found-by-email links firebaseUid to the EXISTING User/Enterprise instead
// of creating a duplicate, so an already-approved account stays approved.
exports.firebaseSignup = catchAsync(async (req, res) => {
  const { idToken, companyName, contactName, gstin, billingEmail } = req.body;
  if (!idToken) throw new AppError('idToken is required', 400);
  if (!ensureInitialized()) throw new AppError('Firebase is not configured', 500);

  let decoded;
  try {
    decoded = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    throw new AppError('Invalid or expired Firebase token', 401);
  }
  if (!decoded.email_verified) throw new AppError('Email not verified', 403);

  let user = await User.findOne({ firebaseUid: decoded.uid });
  let enterprise = null;

  if (!user) {
    user = await User.findOne({ email: decoded.email });
    if (user) {
      // Migration case: an existing (likely bcrypt) enterprise_admin claims
      // this Firebase identity - reuse it and its Enterprise rather than
      // creating a second one. Any other existing account (customer,
      // driver, an invited enterprise_user, etc.) on this email is NOT a
      // migration - it must not get silently promoted into a brand-new
      // Enterprise's admin just by hitting this signup endpoint.
      if (user.role !== 'enterprise_admin') {
        throw new AppError('An account with this email already exists - log in instead, or contact support.', 400);
      }
      user.firebaseUid = decoded.uid;
      user.isVerified = true;
      // A user created via the old auth/firebase-session auto-create path
      // (see auth.controller.js) has no name at all - this is the one
      // place contactName is actually collected for that account, so
      // backfill it rather than leaving it permanently blank.
      if (!user.name && contactName) user.name = contactName;
      await user.save();
      enterprise = await Enterprise.findOne({ adminUserId: user._id });
    }
  }

  if (!user) {
    if (!companyName || !contactName) {
      throw new AppError('companyName and contactName are required', 400);
    }
    user = await User.create({
      name: contactName,
      email: decoded.email,
      firebaseUid: decoded.uid,
      isVerified: true,
      role: 'enterprise_admin',
    });
  }

  if (!enterprise) {
    enterprise = await Enterprise.create({
      companyName: companyName || user.name,
      gstin,
      billingEmail,
      adminUserId: user._id,
    });
    user.enterpriseId = enterprise._id;
    await user.save();
  }

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);

  return success(res, { user, accessToken, refreshToken, enterprise }, 'Enterprise account ready', 201);
});

// GET /api/v1/enterprise/status - lightweight check the frontend calls right
// after login/signup to decide whether to show the real dashboard or a
// pending-approval screen, without requireActive throwing on it.
exports.status = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id, { requireActive: false });
  return success(res, { companyName: enterprise.companyName, isActive: enterprise.isActive });
});

// POST /api/v1/enterprise/create  { companyName, gstin, billingEmail }
exports.createAccount = catchAsync(async (req, res) => {
  const { companyName, gstin, billingEmail } = req.body;
  if (!companyName) throw new AppError('companyName is required', 400);

  const existing = await Enterprise.findOne({ adminUserId: req.user.id });
  if (existing) throw new AppError('An enterprise account already exists for this user', 400);

  const enterprise = await Enterprise.create({ companyName, gstin, billingEmail, adminUserId: req.user.id });
  await User.findByIdAndUpdate(req.user.id, { role: 'enterprise_admin', enterpriseId: enterprise._id });

  return success(res, { enterprise }, 'Enterprise account created - pending approval', 201);
});

// GET /api/v1/enterprise/dashboard
exports.dashboard = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const monthStart = new Date();
  monthStart.setDate(1);
  monthStart.setHours(0, 0, 0, 0);

  const sixMonthsAgo = new Date(monthStart);
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 5); // 6 months inclusive of the current one

  const [
    spendAgg,
    activeShipments,
    topDestinationsAgg,
    pendingInvoices,
    monthlyAgg,
    statusAgg,
    deliveredThisMonth,
    cancelledThisMonth,
    thisMonthStatusAgg,
  ] = await Promise.all([
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id, createdAt: { $gte: monthStart } } },
      { $group: { _id: null, total: { $sum: '$price' } } },
    ]),
    Order.countDocuments({ enterpriseId: enterprise._id, status: { $in: ['accepted', 'picked_up', 'in_transit', 'awaiting_payment'] } }),
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id } },
      { $group: { _id: '$dropLocation.address', orders: { $sum: 1 } } },
      { $sort: { orders: -1 } },
      { $limit: 5 },
    ]),
    Invoice.countDocuments({ enterpriseId: enterprise._id, status: { $in: ['sent', 'draft'] } }),
    // Powers the dashboard's spend-trend chart - grouped by calendar month
    // in one aggregation rather than fetched per-month in a loop.
    // timezone: 'Asia/Kolkata' - matches monthStart above (built from the
    // server's local clock); without pinning this, Mongo groups by UTC
    // calendar month while the fill-loop below uses local time, silently
    // shifting every bucket by a month whenever local time is ahead of UTC.
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id, createdAt: { $gte: sixMonthsAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m', date: '$createdAt', timezone: 'Asia/Kolkata' } },
          spend: { $sum: '$price' },
        },
      },
    ]),
    // Live shipment pipeline, same shape as admin.controller.js's
    // ordersByStatus - a shipment created last month that's still
    // in_transit today is still "active" regardless of when it was booked.
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id, status: { $in: ['pending', 'accepted', 'picked_up', 'in_transit', 'awaiting_payment'] } } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
    Order.countDocuments({ enterpriseId: enterprise._id, createdAt: { $gte: monthStart }, status: 'delivered' }),
    Order.countDocuments({ enterpriseId: enterprise._id, createdAt: { $gte: monthStart }, status: 'cancelled' }),
    // Distinct from the "live" pipeline above (which mixes regardless-of-
    // creation-date pending/accepted/picked_up/in_transit with this-month-
    // only delivered/cancelled into one array) - every shipment actually
    // created this month, grouped by whatever status it's at right now.
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id, createdAt: { $gte: monthStart } } },
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]),
  ]);

  const totalDestOrders = topDestinationsAgg.reduce((s, d) => s + d.orders, 0) || 1;

  const shipmentStatusCounts = { pending: 0, accepted: 0, picked_up: 0, in_transit: 0, awaiting_payment: 0 };
  statusAgg.forEach((s) => { shipmentStatusCounts[s._id] = s.count; });
  const shipmentsByStatus = [
    { status: 'pending', label: 'Pending', count: shipmentStatusCounts.pending },
    { status: 'accepted', label: 'Accepted', count: shipmentStatusCounts.accepted },
    { status: 'picked_up', label: 'Picked up', count: shipmentStatusCounts.picked_up },
    { status: 'in_transit', label: 'In transit', count: shipmentStatusCounts.in_transit },
    { status: 'awaiting_payment', label: 'Awaiting payment', count: shipmentStatusCounts.awaiting_payment },
    { status: 'delivered', label: 'Delivered (this month)', count: deliveredThisMonth },
    { status: 'cancelled', label: 'Cancelled (this month)', count: cancelledThisMonth },
  ];

  const thisMonthStatusCounts = { pending: 0, accepted: 0, picked_up: 0, in_transit: 0, awaiting_payment: 0, delivered: 0, cancelled: 0 };
  thisMonthStatusAgg.forEach((s) => { thisMonthStatusCounts[s._id] = s.count; });
  const thisMonthShipmentsByStatus = [
    { status: 'pending', label: 'Pending', count: thisMonthStatusCounts.pending },
    { status: 'accepted', label: 'Accepted', count: thisMonthStatusCounts.accepted },
    { status: 'picked_up', label: 'Picked up', count: thisMonthStatusCounts.picked_up },
    { status: 'in_transit', label: 'In transit', count: thisMonthStatusCounts.in_transit },
    { status: 'awaiting_payment', label: 'Awaiting payment', count: thisMonthStatusCounts.awaiting_payment },
    { status: 'delivered', label: 'Delivered', count: thisMonthStatusCounts.delivered },
    { status: 'cancelled', label: 'Cancelled', count: thisMonthStatusCounts.cancelled },
  ];

  // Fill in any month with no orders so the chart always shows exactly 6
  // evenly-spaced points instead of gaps. Built from local date parts, not
  // toISOString() (see timezone note above).
  const spendTrend = [];
  for (let i = 5; i >= 0; i--) {
    const d = new Date(monthStart);
    d.setMonth(d.getMonth() - i);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    const found = monthlyAgg.find((x) => x._id === key);
    spendTrend.push({
      month: key,
      label: d.toLocaleDateString('en-IN', { month: 'short' }),
      spend: found?.spend ?? 0,
    });
  }

  return success(res, {
    companyName: enterprise.companyName,
    monthlySpend: spendAgg[0]?.total ?? 0,
    activeShipments,
    pendingInvoices,
    topDestinations: topDestinationsAgg.map((d) => ({
      city: d._id ?? 'Unknown',
      orders: d.orders,
      share: Math.round((d.orders / totalDestOrders) * 100),
    })),
    spendTrend,
    shipmentsByStatus,
    thisMonthShipmentsByStatus,
  });
});

// GET /api/v1/enterprise/orders?status=&dateFrom=&dateTo=&page=&limit=
exports.listOrders = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { status, dateFrom, dateTo, page = 1, limit = 20 } = req.query;

  const filter = { enterpriseId: enterprise._id };
  if (status) filter.status = status;
  if (dateFrom || dateTo) {
    filter.createdAt = {};
    if (dateFrom) filter.createdAt.$gte = new Date(dateFrom);
    if (dateTo) filter.createdAt.$lte = new Date(dateTo);
  }

  const pageNum = Math.max(1, parseInt(page, 10) || 1);
  const limitNum = Math.min(100, Math.max(1, parseInt(limit, 10) || 20));

  const [orders, total] = await Promise.all([
    Order.find(filter)
      .populate('customerId', 'name email')
      .populate({ path: 'driverId', select: 'vehicleNumber vehicleType', populate: { path: 'userId', select: 'name phone' } })
      .sort({ createdAt: -1 })
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .lean(),
    Order.countDocuments(filter),
  ]);

  // Same reveal-only-when-relevant rule as booking.controller.js's getById:
  // startOtp only matters while picked_up (needed to start the trip);
  // deliveryOtp matters from picked_up through in_transit (shown early so
  // whoever's handing off the shipment has it ready before the driver
  // arrives). No frontend for this existed before now - enterprise orders
  // had no way to hand these codes to the driver at all.
  for (const order of orders) {
    if (!['picked_up', 'in_transit'].includes(order.status)) delete order.deliveryOtp;
    if (order.status !== 'picked_up') delete order.startOtp;
  }

  return success(res, { orders, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// GET /api/v1/enterprise/orders/:id - single order detail, scoped to the
// caller's whole enterprise (same filter as listOrders above) rather than
// just orders they personally booked, so any teammate can look up a
// shipment via direct link/refresh, not only via the list.
exports.getOrderById = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);

  const order = await Order.findOne({ _id: req.params.id, enterpriseId: enterprise._id })
    .populate('customerId', 'name email')
    .populate({
      path: 'driverId',
      select: 'vehicleNumber vehicleType currentLocation',
      populate: { path: 'userId', select: 'name phone' },
    })
    .lean();
  if (!order) throw new AppError('Order not found', 404);

  if (!['picked_up', 'in_transit'].includes(order.status)) delete order.deliveryOtp;
  if (order.status !== 'picked_up') delete order.startOtp;

  return success(res, { order });
});

// POST /api/v1/enterprise/bulk-booking  { rows: [{ pickupAddress, dropAddress, vehicleType, goodsType, weightKg }] }
exports.bulkBooking = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  // Belt-and-suspenders on top of the portal's own UI gate - a viewer must
  // not be able to create bookings via a direct API call either. req.user
  // only carries {id, role} from the JWT payload, not enterpriseRole, so
  // this needs an actual lookup rather than trusting the token.
  if (req.user.role === 'enterprise_user') {
    const requestingUser = await User.findById(req.user.id).select('enterpriseRole');
    if (requestingUser?.enterpriseRole === 'viewer') {
      throw new AppError('Your account has Viewer access - only Managers can create bulk bookings', 403);
    }
  }
  const { rows } = req.body;
  if (!Array.isArray(rows) || rows.length === 0) throw new AppError('rows must be a non-empty array', 400);

  const results = { created: 0, failed: 0, errors: [] };

  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    try {
      if (!row.pickupAddress || !row.dropAddress) throw new Error('pickupAddress and dropAddress are required');
      if (!VEHICLE_BASE_PRICE[row.vehicleType]) throw new Error(`Invalid vehicleType "${row.vehicleType}"`);

      const weightKg = Number(row.weightKg) || 0;
      const maxWeight = VEHICLE_MAX_WEIGHT_KG[row.vehicleType];
      if (maxWeight != null && weightKg > maxWeight) {
        throw new Error(`Weight exceeds the ${maxWeight}kg limit for ${row.vehicleType}`);
      }
      const price = VEHICLE_BASE_PRICE[row.vehicleType] + weightKg * 0.5;

      // Coordinates come from the Places autocomplete selection on the
      // frontend, when available - falls back to [0, 0] (no real
      // geolocation) for a plain typed address with no selected suggestion,
      // same as before this was wired up.
      const pickupCoords = Number.isFinite(row.pickupLng) && Number.isFinite(row.pickupLat)
        ? [row.pickupLng, row.pickupLat]
        : [0, 0];
      const dropCoords = Number.isFinite(row.dropLng) && Number.isFinite(row.dropLat)
        ? [row.dropLng, row.dropLat]
        : [0, 0];

      await Order.create({
        customerId: req.user.id,
        enterpriseId: enterprise._id,
        pickupLocation: { type: 'Point', coordinates: pickupCoords, address: row.pickupAddress },
        dropLocation: { type: 'Point', coordinates: dropCoords, address: row.dropAddress },
        vehicleType: row.vehicleType,
        goodsType: row.goodsType || 'General cargo',
        weightKg,
        price,
        status: 'pending',
        timeline: [{ status: 'pending', note: 'Created via enterprise bulk booking' }],
      });
      results.created++;
    } catch (err) {
      results.failed++;
      results.errors.push({ row: i + 1, reason: err.message });
    }
  }

  return success(res, results, `${results.created} booking(s) created, ${results.failed} failed`);
});

// GET /api/v1/enterprise/users
exports.listUsers = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const populated = await Enterprise.findById(enterprise._id)
    .populate('adminUserId', 'name email phone isBlocked')
    .populate('subUsers', 'name email phone isBlocked enterpriseRole');
  return success(res, { admin: populated.adminUserId, subUsers: populated.subUsers });
});

// POST /api/v1/enterprise/users/invite  { name, email, role? }
// NOTE: creates the account directly (no email invite delivery yet - that
// needs SendGrid wired in notification.service). Sub-user logs in with OTP
// once they set up a phone number, or via a password reset flow (future work).
exports.inviteUser = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { name, email, role } = req.body;
  if (!name || !email) throw new AppError('name and email are required', 400);
  if (role && !['manager', 'viewer'].includes(role)) {
    throw new AppError("role must be 'manager' or 'viewer'", 400);
  }

  let user = await User.findOne({ email });
  if (!user) {
    user = await User.create({
      name,
      email,
      role: 'enterprise_user',
      enterpriseRole: role || 'manager',
      enterpriseId: enterprise._id,
      isVerified: false,
    });
  } else if (String(user.enterpriseId) !== String(enterprise._id)) {
    throw new AppError('This email is already associated with a different account', 400);
  }

  if (!enterprise.subUsers.some((id) => String(id) === String(user._id))) {
    enterprise.subUsers.push(user._id);
    await enterprise.save();
  }

  return success(res, { user }, 'Team member added', 201);
});

// PUT /api/v1/enterprise/users/:id/role  { role }
exports.updateUserRole = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { role } = req.body;
  if (!['manager', 'viewer'].includes(role)) {
    throw new AppError("role must be 'manager' or 'viewer'", 400);
  }
  if (!enterprise.subUsers.some((id) => String(id) === req.params.id)) {
    throw new AppError('Team member not found', 404);
  }

  const user = await User.findByIdAndUpdate(req.params.id, { enterpriseRole: role }, { new: true });
  if (!user) throw new AppError('Team member not found', 404);

  return success(res, { user }, 'Role updated');
});

// DELETE /api/v1/enterprise/users/:id
// Fully removes the account, not just this enterprise's link to it -
// inviteUser only ever creates a sub-user fresh and exclusively for this
// enterprise (never repurposes an unrelated existing account), so there's
// nothing else the record needs to survive for.
exports.removeUser = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  if (!enterprise.subUsers.some((id) => String(id) === req.params.id)) {
    throw new AppError('Team member not found', 404);
  }

  enterprise.subUsers = enterprise.subUsers.filter((id) => String(id) !== req.params.id);
  await enterprise.save();
  await User.findByIdAndDelete(req.params.id);

  return success(res, null, 'Team member removed');
});

// GET /api/v1/enterprise/invoices
exports.listInvoices = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const invoices = await Invoice.find({ enterpriseId: enterprise._id }).sort({ periodEnd: -1 });
  return success(res, { invoices });
});

// GET /api/v1/enterprise/invoices/:id/pdf - generates a GST-style PDF on the fly
exports.downloadInvoicePdf = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const invoice = await Invoice.findOne({ _id: req.params.id, enterpriseId: enterprise._id }).populate('orderIds');
  if (!invoice) throw new AppError('Invoice not found', 404);

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename="invoice-${invoice._id}.pdf"`);

  const doc = new PDFDocument({ margin: 50 });
  doc.pipe(res);

  doc.fontSize(18).text('Pan-India Logistics Platform', { align: 'left' });
  doc.fontSize(10).fillColor('#555').text('Tax Invoice', { align: 'left' });
  doc.moveDown(1.5);

  doc.fontSize(12).fillColor('#000').text(`Invoice: INV-${invoice._id.toString().slice(-8).toUpperCase()}`);
  doc.text(`Billed to: ${enterprise.companyName}`);
  if (enterprise.gstin) doc.text(`GSTIN: ${enterprise.gstin}`);
  doc.text(`Period: ${invoice.periodStart?.toLocaleDateString('en-IN')} - ${invoice.periodEnd?.toLocaleDateString('en-IN')}`);
  doc.moveDown();

  doc.fontSize(11).text('Shipments', { underline: true });
  doc.moveDown(0.5);
  (invoice.orderIds || []).forEach((o, i) => {
    doc.fontSize(10).text(`${i + 1}. ${o.pickupLocation?.address ?? '—'} -> ${o.dropLocation?.address ?? '—'}  |  Rs ${o.price}`);
  });
  doc.moveDown();

  doc.fontSize(11).text(`Subtotal: Rs ${invoice.subtotal?.toLocaleString('en-IN') ?? 0}`);
  doc.text(`GST: Rs ${invoice.gstAmount?.toLocaleString('en-IN') ?? 0}`);
  doc.fontSize(13).text(`Total: Rs ${invoice.totalAmount?.toLocaleString('en-IN') ?? 0}`, { underline: true });

  doc.end();
});

// GET /api/v1/enterprise/contract-pricing
exports.getContractPricing = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  return success(res, { contractPricing: enterprise.contractPricing || {} });
});

// PUT /api/v1/enterprise/contract-pricing  { vehicleType, discountPercent }
exports.updateContractPricing = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { vehicleType, discountPercent } = req.body;
  if (!vehicleType) throw new AppError('vehicleType is required', 400);

  const contractPricing = { ...(enterprise.contractPricing || {}) };
  contractPricing[vehicleType] = { discountPercent: Number(discountPercent) || 0 };
  enterprise.contractPricing = contractPricing;
  await enterprise.save();

  return success(res, { contractPricing: enterprise.contractPricing }, 'Contract pricing updated');
});

// GET /api/v1/enterprise/api-key - returns masked key if one exists
exports.getApiKey = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id, { selectApiKey: true });

  const masked = enterprise.apiKey ? `${enterprise.apiKey.slice(0, 8)}${'•'.repeat(20)}` : null;
  return success(res, { apiKey: masked, hasKey: Boolean(enterprise.apiKey) });
});

// POST /api/v1/enterprise/api-key/regenerate - only the enterprise_admin can do this
exports.regenerateApiKey = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);

  const newKey = `lgk_${crypto.randomBytes(24).toString('hex')}`;
  enterprise.apiKey = newKey;
  await enterprise.save();

  // Full key is only ever shown once, right after generation
  return success(res, { apiKey: newKey }, 'API key regenerated - copy it now, it will not be shown again');
});

const generateDriverInviteCode = () => `ENT-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;

// GET /api/v1/enterprise/driver-invite-code - lazily generates one on first
// fetch. Unlike the API key this isn't secret - it's meant to be handed out
// to drivers, so it's always returned in full (no masking).
exports.getDriverInviteCode = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  if (!enterprise.driverInviteCode) {
    enterprise.driverInviteCode = generateDriverInviteCode();
    await enterprise.save();
  }
  return success(res, { driverInviteCode: enterprise.driverInviteCode });
});

// POST /api/v1/enterprise/driver-invite-code/regenerate - old code stops
// linking new drivers immediately; already-linked drivers are unaffected
// (enterpriseId was already written to their Driver doc).
exports.regenerateDriverInviteCode = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  enterprise.driverInviteCode = generateDriverInviteCode();
  await enterprise.save();
  return success(
    res,
    { driverInviteCode: enterprise.driverInviteCode },
    'Driver invite code regenerated - the old code no longer links new drivers to your account'
  );
});

// GET /api/v1/enterprise/drivers - this enterprise's own dedicated fleet
exports.listDrivers = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const drivers = await Driver.find({ enterpriseId: enterprise._id })
    .populate('userId', 'name phone')
    .sort({ createdAt: -1 });
  return success(res, { drivers });
});

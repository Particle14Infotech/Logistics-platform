const crypto = require('crypto');
const PDFDocument = require('pdfkit');
const { catchAsync, success, AppError } = require('../utils/apiResponse');
const User = require('../models/user.model');
const Enterprise = require('../models/enterprise.model');
const Order = require('../models/order.model');
const Invoice = require('../models/invoice.model');

const VEHICLE_BASE_PRICE = { bike: 100, auto: 150, mini_truck: 300, medium_truck: 600, large_truck: 1000 };

// Resolves the Enterprise doc for the logged-in user, whether they're the
// admin (adminUserId) or an invited sub-user (subUsers array). JWTs only
// carry { id, role }, so this always looks it up fresh rather than trusting
// a cached enterpriseId on the User doc.
async function resolveEnterprise(userId) {
  let enterprise = await Enterprise.findOne({ adminUserId: userId });
  if (!enterprise) enterprise = await Enterprise.findOne({ subUsers: userId });
  if (!enterprise) throw new AppError('No enterprise account associated with this user', 404);
  return enterprise;
}

// POST /api/v1/enterprise/create  { companyName, gstin, billingEmail }
exports.createAccount = catchAsync(async (req, res) => {
  const { companyName, gstin, billingEmail } = req.body;
  if (!companyName) throw new AppError('companyName is required', 400);

  const existing = await Enterprise.findOne({ adminUserId: req.user.id });
  if (existing) throw new AppError('An enterprise account already exists for this user', 400);

  const enterprise = await Enterprise.create({ companyName, gstin, billingEmail, adminUserId: req.user.id });
  await User.findByIdAndUpdate(req.user.id, { role: 'enterprise_admin', enterpriseId: enterprise._id });

  return success(res, { enterprise }, 'Enterprise account created', 201);
});

// GET /api/v1/enterprise/dashboard
exports.dashboard = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const monthStart = new Date();
  monthStart.setDate(1);
  monthStart.setHours(0, 0, 0, 0);

  const [spendAgg, activeShipments, topDestinationsAgg, pendingInvoices] = await Promise.all([
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id, createdAt: { $gte: monthStart } } },
      { $group: { _id: null, total: { $sum: '$price' } } },
    ]),
    Order.countDocuments({ enterpriseId: enterprise._id, status: { $in: ['accepted', 'picked_up', 'in_transit'] } }),
    Order.aggregate([
      { $match: { enterpriseId: enterprise._id } },
      { $group: { _id: '$dropLocation.address', orders: { $sum: 1 } } },
      { $sort: { orders: -1 } },
      { $limit: 5 },
    ]),
    Invoice.countDocuments({ enterpriseId: enterprise._id, status: { $in: ['sent', 'draft'] } }),
  ]);

  const totalDestOrders = topDestinationsAgg.reduce((s, d) => s + d.orders, 0) || 1;

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
  });
});

// GET /api/v1/enterprise/orders?status=&page=&limit=
exports.listOrders = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { status, page = 1, limit = 20 } = req.query;

  const filter = { enterpriseId: enterprise._id };
  if (status) filter.status = status;

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

  return success(res, { orders, pagination: { page: pageNum, limit: limitNum, total, pages: Math.ceil(total / limitNum) } });
});

// POST /api/v1/enterprise/bulk-booking  { rows: [{ pickupAddress, dropAddress, vehicleType, goodsType, weightKg }] }
exports.bulkBooking = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { rows } = req.body;
  if (!Array.isArray(rows) || rows.length === 0) throw new AppError('rows must be a non-empty array', 400);

  const results = { created: 0, failed: 0, errors: [] };

  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    try {
      if (!row.pickupAddress || !row.dropAddress) throw new Error('pickupAddress and dropAddress are required');
      if (!VEHICLE_BASE_PRICE[row.vehicleType]) throw new Error(`Invalid vehicleType "${row.vehicleType}"`);

      const weightKg = Number(row.weightKg) || 0;
      const price = VEHICLE_BASE_PRICE[row.vehicleType] + weightKg * 0.5;

      await Order.create({
        customerId: req.user.id,
        enterpriseId: enterprise._id,
        pickupLocation: { type: 'Point', coordinates: [0, 0], address: row.pickupAddress },
        dropLocation: { type: 'Point', coordinates: [0, 0], address: row.dropAddress },
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
    .populate('subUsers', 'name email phone isBlocked');
  return success(res, { admin: populated.adminUserId, subUsers: populated.subUsers });
});

// POST /api/v1/enterprise/users/invite  { name, email }
// NOTE: creates the account directly (no email invite delivery yet - that
// needs SendGrid wired in notification.service). Sub-user logs in with OTP
// once they set up a phone number, or via a password reset flow (future work).
exports.inviteUser = catchAsync(async (req, res) => {
  const enterprise = await resolveEnterprise(req.user.id);
  const { name, email } = req.body;
  if (!name || !email) throw new AppError('name and email are required', 400);

  let user = await User.findOne({ email });
  if (!user) {
    user = await User.create({ name, email, role: 'enterprise_user', enterpriseId: enterprise._id, isVerified: false });
  } else if (String(user.enterpriseId) !== String(enterprise._id)) {
    throw new AppError('This email is already associated with a different account', 400);
  }

  if (!enterprise.subUsers.some((id) => String(id) === String(user._id))) {
    enterprise.subUsers.push(user._id);
    await enterprise.save();
  }

  return success(res, { user }, 'Team member added', 201);
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
  const enterprise = await Enterprise.findOne({ adminUserId: req.user.id }).select('+apiKey');
  if (!enterprise) throw new AppError('No enterprise account associated with this user', 404);

  const masked = enterprise.apiKey ? `${enterprise.apiKey.slice(0, 8)}${'•'.repeat(20)}` : null;
  return success(res, { apiKey: masked, hasKey: Boolean(enterprise.apiKey) });
});

// POST /api/v1/enterprise/api-key/regenerate - only the enterprise_admin can do this
exports.regenerateApiKey = catchAsync(async (req, res) => {
  const enterprise = await Enterprise.findOne({ adminUserId: req.user.id });
  if (!enterprise) throw new AppError('No enterprise account associated with this user', 404);

  const newKey = `lgk_${crypto.randomBytes(24).toString('hex')}`;
  enterprise.apiKey = newKey;
  await enterprise.save();

  // Full key is only ever shown once, right after generation
  return success(res, { apiKey: newKey }, 'API key regenerated - copy it now, it will not be shown again');
});

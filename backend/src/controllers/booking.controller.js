const PDFDocument = require('pdfkit');
const companyInfo = require('../config/companyInfo');
const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Order = require('../models/order.model');
const Driver = require('../models/driver.model');
const User = require('../models/user.model');
const Payment = require('../models/payment.model');
const Message = require('../models/message.model');
const Review = require('../models/review.model');
const PricingConfig = require('../models/pricingConfig.model');
const { getRoadDistanceKm } = require('../services/maps.service');
const { sendToUser, notifyEligibleDriversOfNewJob } = require('../services/notification.service');
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

// Used by downloadInvoicePdf/updateWaybillDetails, which need to let the
// order's own assigned driver through in addition to its customer/admin -
// works whether order.driverId is populated (an object) or not (a plain id).
async function isAssignedDriverForOrder(order, userId) {
  if (!order.driverId) return false;
  const driverDoc = await Driver.findOne({ userId });
  if (!driverDoc) return false;
  const orderDriverId = order.driverId._id ?? order.driverId;
  return String(driverDoc._id) === String(orderDriverId);
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
    consigneeName,
    consigneePhone,
    consigneeGstin,
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

  // Seeds the waybill with whatever's already known at booking time, so the
  // LR (see downloadInvoicePdf) starts more complete instead of relying
  // entirely on someone filling in every field after the fact - still all
  // editable later via PUT /booking/:id/waybill-details.
  const bookingCustomer = await User.findById(req.user.id).select('gstin');
  const waybillDetails = {
    ...(consigneeName && { consigneeName }),
    ...(consigneePhone && { consigneePhone }),
    ...(consigneeGstin && { consigneeGstin }),
    ...(bookingCustomer?.gstin && { consignorGstin: bookingCustomer.gstin }),
    gstPayableBy: 'consignor',
    ...(isFragile && { remark: 'Fragile - handle with care' }),
  };

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
    waybillDetails,
    status: 'pending',
    timeline: [{ status: 'pending', note: 'Booking created' }],
  });

  // Best-effort "new job available" push to online, approved drivers with
  // a matching vehicle type - doesn't block the response if it's slow or
  // Firebase isn't configured, and never throws back to the customer.
  //
  // Must mirror availableOrders' own eligibility filter exactly (enterpriseId
  // scoping + cod-advance gating below) - otherwise a driver gets pushed
  // "New job available" for an order that never actually shows up in their
  // Jobs list (an enterprise-dedicated driver notified about a public-pool
  // order, or anyone notified about a gated cod order before its advance is
  // paid), which reads as "jobs not updating in real-time" even though
  // nothing was ever broken - the order correctly isn't visible yet.
  const isImmediatelyVisible = order.paymentMethod !== 'cod' || order.advanceAmount === 0 || order.paymentStatus === 'paid';
  if (isImmediatelyVisible) {
    notifyEligibleDriversOfNewJob(order).catch(() => {});
  }
  // If it's a gated cod order, drivers get notified once the advance is
  // actually paid instead - see payment.controller.js's verify()/webhook().

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
  const order = await Order.findById(req.params.id)
    .populate({ path: 'driverId', select: 'vehicleNumber licenseNumber', populate: { path: 'userId', select: 'name phone' } })
    .populate('customerId', 'name phone');
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId?._id ?? order.customerId) === String(req.user.id);
  const isDriver = !isOwner && req.user.role === 'driver' && (await isAssignedDriverForOrder(order, req.user.id));
  if (!isOwner && !isDriver && req.user.role !== 'admin') throw new AppError('Not authorized to view this booking', 403);

  const payment = await Payment.findOne({ orderId: order._id, status: 'captured' }).sort({ createdAt: -1 });
  if (!payment) throw new AppError('No completed payment found for this booking yet', 400);

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename="waybill-${order._id}.pdf"`);

  const doc = new PDFDocument({ margin: 28, size: 'A4' });
  doc.pipe(res);

  const wb = order.waybillDetails || {};
  const driver = order.driverId;
  const customer = order.customerId;
  const refNo = order._id.toString().slice(-8).toUpperCase();
  const pageLeft = doc.page.margins.left;
  const pageWidth = doc.page.width - pageLeft - doc.page.margins.right;
  const pageRight = pageLeft + pageWidth;

  const sgst = wb.taxType === 'intra_state' ? Math.round((wb.gstAmount || 0) / 2) : 0;
  const cgst = sgst;
  const igst = wb.taxType === 'inter_state' ? wb.gstAmount || 0 : 0;
  const totalWithTax = order.price + (wb.gstAmount || 0);
  const balanceDue = totalWithTax - order.advanceAmount;
  // Shown next to each tax line (e.g. "SGST @ 2.5 %") - derived from
  // whatever gstAmount was actually entered, not a hardcoded slab rate.
  const totalGstPercent = wb.gstAmount && order.price > 0 ? (wb.gstAmount / order.price) * 100 : 0;
  const sgstPercentLabel = wb.taxType === 'intra_state' && totalGstPercent > 0 ? `${(totalGstPercent / 2).toFixed(1)} %` : '-';
  const cgstPercentLabel = sgstPercentLabel;
  const igstPercentLabel = wb.taxType === 'inter_state' && totalGstPercent > 0 ? `${totalGstPercent.toFixed(1)} %` : '-';
  // Both fall back to a computed/reasonable default when the admin hasn't
  // manually entered one via waybill-details, instead of printing blank.
  const ratePerTon = wb.ratePerTon != null ? wb.ratePerTon : order.weightKg ? order.price / (order.weightKg / 1000) : null;
  const declaredValue = wb.declaredValue != null ? wb.declaredValue : order.price;

  let y = doc.y;
  const rowLine = (h) => {
    doc.moveTo(pageLeft, y + h).lineTo(pageRight, y + h).stroke();
  };
  const cell = (text, x, w, opts = {}) => {
    doc.fontSize(opts.size || 8).font(opts.bold ? 'Helvetica-Bold' : 'Helvetica')
      .text(text ?? '', x + 3, y + 3, {
        width: w - 6,
        align: opts.align || 'left',
        // Long free-text values (addresses) would otherwise wrap to a
        // second line and bleed into the row below, which is a fixed
        // single-line height - truncate with '…' instead.
        ...(opts.singleLine && { height: 10, ellipsis: true }),
      });
  };
  const vLine = (x, h) => doc.moveTo(x, y).lineTo(x, y + h).stroke();

  // Outer border for the whole document, drawn last against a known
  // bottom - start it now and close it once the final y is known.
  const docTop = y;

  // --- Letterhead ---
  doc.fontSize(26).font('Helvetica-Bold').text(companyInfo.brandName, pageLeft, y, { width: pageWidth, align: 'center' });
  y += 32;
  doc.fontSize(11).font('Helvetica-Bold').text(companyInfo.legalName, pageLeft, y, { width: pageWidth, align: 'center' });
  y += 18;
  doc.rect(pageLeft, y, pageWidth, 16).fill('#000');
  doc.fontSize(10).font('Helvetica-Bold').fillColor('#fff').text(`GST NO. ${companyInfo.gstin}`, pageLeft, y + 4, { width: pageWidth, align: 'center' });
  doc.fillColor('#000');
  y += 16;
  doc.fontSize(8).font('Helvetica').text(companyInfo.address, pageLeft, y + 4, { width: pageWidth, align: 'center' });
  y += 18;

  // --- Truck / LR / Date ---
  doc.rect(pageLeft, y, pageWidth, 16).stroke();
  const c1 = pageLeft, c2 = pageLeft + pageWidth * 0.15, c3 = pageLeft + pageWidth * 0.45, c4 = pageLeft + pageWidth * 0.6, c5 = pageLeft + pageWidth * 0.8;
  cell('Truck No.', c1, c2 - c1, { bold: true });
  cell(driver?.vehicleNumber || '—', c2, c3 - c2);
  cell('L.R. NO.', c3, c4 - c3, { bold: true });
  cell(refNo, c4, c5 - c4);
  cell('DATE', c5, pageRight - c5 - (pageRight - c5) * 0.5, { bold: true });
  cell(order.createdAt.toLocaleDateString('en-IN'), c5 + (pageRight - c5) * 0.3, (pageRight - c5) * 0.7);
  vLine(c2, 16); vLine(c3, 16); vLine(c4, 16); vLine(c5, 16);
  y += 16;

  // --- Driver name / mobile ---
  doc.rect(pageLeft, y, pageWidth, 16).stroke();
  cell('Driver Name', c1, c2 - c1, { bold: true });
  cell(driver?.userId?.name || '—', c2, c4 - c2);
  cell('Driver Mo.', c4, c5 - c4, { bold: true });
  cell(driver?.userId?.phone || '—', c5, pageRight - c5);
  vLine(c2, 16); vLine(c4, 16); vLine(c5, 16);
  y += 16;

  // --- From / To ---
  doc.rect(pageLeft, y, pageWidth, 16).stroke();
  cell('From', c1, c2 - c1, { bold: true });
  cell(order.pickupLocation?.address || '—', c2, c4 - c2, { singleLine: true });
  cell('To', c4, c5 - c4, { bold: true });
  cell(order.dropLocation?.address || '—', c5, pageRight - c5, { singleLine: true });
  vLine(c2, 16); vLine(c4, 16); vLine(c5, 16);
  y += 16;

  // --- Consignor / Consignee ---
  const half = pageLeft + pageWidth / 2;
  doc.rect(pageLeft, y, pageWidth, 44).stroke();
  vLine(half, 44);
  cell('Consignor :', pageLeft, half - pageLeft, { bold: true });
  doc.fontSize(8).font('Helvetica').text(`${customer?.name || '—'}\nPh: ${customer?.phone || '—'}`, pageLeft + 3, y + 15, { width: half - pageLeft - 6 });
  cell('Consignee :', half, pageRight - half, { bold: true });
  doc.fontSize(8).font('Helvetica').text(`${wb.consigneeName || '—'}\nPh: ${wb.consigneePhone || '—'}`, half + 3, y + 15, { width: pageRight - half - 6 });
  y += 44;

  // --- GSTIN row ---
  doc.rect(pageLeft, y, pageWidth, 14).stroke();
  vLine(half, 14);
  cell(`GSTIN NO. : ${wb.consignorGstin || 'NOT PROVIDED'}`, pageLeft, half - pageLeft, { bold: true });
  cell(`GSTIN NO. : ${wb.consigneeGstin || 'NOT PROVIDED'}`, half, pageRight - half, { bold: true });
  y += 14;

  // --- E-Way Bill ---
  doc.rect(pageLeft, y, pageWidth, 14).stroke();
  cell(`E-Way Bill No. : ${wb.ewayBillNo || '—'}`, pageLeft, pageWidth, { bold: true });
  y += 14;

  doc.fontSize(7).font('Helvetica-Oblique').text(
    'We are not Responsible any Breakages of Your Goods, No Deduct Lorry Frieght, Please Take Insurance of your Goods.',
    pageLeft + 3, y + 2, { width: pageWidth - 6, align: 'center' }
  );
  y += 12;

  // --- Goods table (left: article/goods/weight/rate/freight, right: charges box) ---
  const goodsTableH = 130;
  const ratePerTonStart = pageLeft + pageWidth * 0.62;
  const ratePerTonEnd = pageLeft + pageWidth * 0.7;
  const chargesX = ratePerTonEnd;
  doc.rect(pageLeft, y, pageWidth, goodsTableH).stroke();
  vLine(pageLeft + pageWidth * 0.08, goodsTableH);
  vLine(pageLeft + pageWidth * 0.5, goodsTableH);
  vLine(ratePerTonStart, goodsTableH);
  vLine(ratePerTonEnd, goodsTableH);
  vLine(chargesX + (pageRight - chargesX) * 0.6, goodsTableH);

  cell('No. of\nArticle', pageLeft, pageWidth * 0.08, { bold: true, size: 7 });
  cell('NATURE OF GOODS SAID TO CONTAIN', pageLeft + pageWidth * 0.08, pageWidth * 0.42, { bold: true, size: 7 });
  cell('Weight\n(in Ton)', pageLeft + pageWidth * 0.5, pageWidth * 0.12, { bold: true, size: 7 });
  cell('Rate Per\nTon', ratePerTonStart, ratePerTonEnd - ratePerTonStart, { bold: true, size: 7 });

  doc.fontSize(8).font('Helvetica').text('1', pageLeft + 3, y + 18);
  doc.text(order.goodsType || '—', pageLeft + pageWidth * 0.08 + 3, y + 18, { width: pageWidth * 0.42 - 6 });
  doc.text(order.weightKg ? (order.weightKg / 1000).toFixed(2) : '—', pageLeft + pageWidth * 0.5 + 3, y + 18, { width: pageWidth * 0.12 - 6 });
  doc.text(ratePerTon != null ? ratePerTon.toFixed(2) : '—', ratePerTonStart + 3, y + 18, { width: ratePerTonEnd - ratePerTonStart - 6 });

  const chargeLabelX = chargesX + 3;
  const chargeValueX = chargesX + (pageRight - chargesX) * 0.6 + 3;
  const chargeValueW = pageRight - chargeValueX - 3;
  const chargeRow = (label, value, offset, opts = {}) => {
    doc.fontSize(7.5).font(opts.bold ? 'Helvetica-Bold' : 'Helvetica').text(label, chargeLabelX, y + offset);
    if (value !== undefined) doc.text(value, chargeValueX, y + offset, { width: chargeValueW, align: 'right' });
  };
  // Static boilerplate labels matching the pre-printed paper LR form -
  // "Our Bank A/C"/"NEFT/RTGS CODE" are intentionally left blank (this
  // platform doesn't collect banking details this way).
  chargeRow('To Pay', undefined, 2);
  chargeRow('Total Freight', undefined, 12);
  chargeRow(`Please Freight : ${order.paymentMethod === 'cod' ? 'CASH' : 'ONLINE'}`, undefined, 22);
  chargeRow('Our Bank A/C :', undefined, 32);
  chargeRow('NEFT / RTGS CODE :', undefined, 42);
  chargeRow(`SGST @ ${sgstPercentLabel}`, `Rs ${sgst.toFixed(2)}`, 56);
  chargeRow(`CGST @ ${cgstPercentLabel}`, `Rs ${cgst.toFixed(2)}`, 68);
  chargeRow(`IGST @ ${igstPercentLabel}`, `Rs ${igst.toFixed(2)}`, 80);
  chargeRow('TOTAL', `Rs ${totalWithTax.toFixed(2)}`, 92, { bold: true });
  chargeRow('ADVANCE', `Rs ${order.advanceAmount.toFixed(2)}`, 104, { bold: true });
  chargeRow('Total Freight Rs.', `Rs ${balanceDue.toFixed(2)}`, 116, { bold: true });
  y += goodsTableH;

  // --- Value / Delivery At / Invoice No ---
  doc.rect(pageLeft, y, pageWidth, 16).stroke();
  cell('Value Rs', c1, c2 - c1, { bold: true });
  cell(declaredValue.toFixed(2), c2, c3 - c2);
  cell('Delivery At', c3, c4 - c3, { bold: true });
  cell(order.dropLocation?.address || '—', c4, c5 - c4, { singleLine: true });
  cell(`Invoice No. ${refNo}`, c5, pageRight - c5, { bold: true });
  vLine(c2, 16); vLine(c3, 16); vLine(c4, 16); vLine(c5, 16);
  y += 16;

  // --- GST Payable checkboxes ---
  doc.rect(pageLeft, y, pageWidth, 14).stroke();
  cell('GST Payble', pageLeft, pageWidth * 0.15, { bold: true });
  const gstCheckbox = (label, key, x) => {
    doc.fontSize(8).font('Helvetica-Bold').text(label, x, y + 3);
    const boxX = x + doc.widthOfString(label) + 4;
    const boxSize = 9;
    doc.rect(boxX, y + 2.5, boxSize, boxSize).stroke();
    if (wb.gstPayableBy === key) {
      doc.fontSize(8).text('X', boxX + 1.5, y + 2);
    }
  };
  gstCheckbox('CONSIGNOR', 'consignor', pageLeft + pageWidth * 0.18);
  gstCheckbox('CONSIGNEE', 'consignee', pageLeft + pageWidth * 0.45);
  gstCheckbox('TRANSPORTER', 'transporter', pageLeft + pageWidth * 0.72);
  y += 14;

  // --- Remark ---
  doc.rect(pageLeft, y, pageWidth, 16).stroke();
  cell(`Remark : ${wb.remark || '—'}`, pageLeft, pageWidth);
  y += 16;

  // --- Footer: driver / DL / RTO ---
  doc.rect(pageLeft, y, pageWidth, 16).stroke();
  cell(`Driver Name : ${driver?.userId?.name || '—'}`, c1, c3 - c1);
  cell(`D.L. No. : ${driver?.licenseNumber || '—'}`, c3, c5 - c3, { bold: true });
  cell(`Mo : ${driver?.userId?.phone || '—'}`, c5, pageRight - c5, { bold: true });
  y += 16;
  doc.rect(pageLeft, y, pageWidth, 14).stroke();
  cell(`R.T.O. : ${wb.rto || '—'}`, c3, pageRight - c3, { bold: true });
  y += 14;

  // --- Signature ---
  const termsH = 40;
  doc.rect(pageLeft, y, pageWidth, termsH).stroke();
  vLine(pageRight - pageWidth * 0.18, termsH);
  doc.fontSize(8).font('Helvetica-Bold').text(`FOR, ${companyInfo.brandName}`, pageRight - pageWidth * 0.18 + 3, y + 4, { width: pageWidth * 0.18 - 6, align: 'center' });
  y += termsH;

  doc.rect(pageLeft, docTop, pageWidth, y - docTop).stroke();

  doc.end();
});

// PUT /api/v1/booking/:id/waybill-details
// Fills in the compliance/paperwork fields the printed LR/waybill needs
// (see downloadInvoicePdf above) that a customer won't have at checkout -
// typically filled in by admin staff before handing over the physical LR.
// Whitelisted field-by-field so this can't be used to write arbitrary
// order fields.
const WAYBILL_DETAIL_FIELDS = [
  'consigneeName', 'consigneePhone', 'consignorGstin', 'consigneeGstin',
  'ewayBillNo', 'declaredValue', 'ratePerTon', 'rto', 'gstPayableBy', 'taxType', 'gstAmount', 'remark',
];
exports.updateWaybillDetails = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.id);
  if (!order) throw new AppError('Booking not found', 404);

  const isOwner = String(order.customerId) === String(req.user.id);
  const isDriver = !isOwner && req.user.role === 'driver' && (await isAssignedDriverForOrder(order, req.user.id));
  if (!isOwner && !isDriver && req.user.role !== 'admin') throw new AppError('Not authorized to edit this booking', 403);

  order.waybillDetails = order.waybillDetails || {};
  for (const field of WAYBILL_DETAIL_FIELDS) {
    if (req.body[field] !== undefined) order.waybillDetails[field] = req.body[field];
  }
  await order.save();

  return success(res, { order }, 'Waybill details updated');
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

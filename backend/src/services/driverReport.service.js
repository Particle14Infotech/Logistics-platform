const PDFDocument = require('pdfkit');
const Order = require('../models/order.model');
const WalletTransaction = require('../models/walletTransaction.model');
const companyInfo = require('../config/companyInfo');

// Aggregates everything for the driver "full report" view - complete trip
// history and complete wallet ledger, not the paginated/capped versions the
// normal driver detail page widgets use (10 recent transactions, a bare
// order count). Shared by admin.controller.js and enterprise.controller.js
// so both portals' report + PDF export are backed by identical data/logic -
// an enterprise's report naturally only ever contains that same enterprise's
// own orders, since a dedicated fleet driver can only ever accept orders
// belonging to their own enterprise (driver.controller.js's availableOrders).
async function buildDriverReport(driverId) {
  const [orders, walletTransactions] = await Promise.all([
    Order.find({ driverId })
      .populate('customerId', 'name phone')
      .populate('enterpriseId', 'companyName')
      .sort({ createdAt: -1 }),
    WalletTransaction.find({ driverId }).sort({ createdAt: -1 }),
  ]);

  const delivered = orders.filter((o) => o.status === 'delivered');
  const cancelled = orders.filter((o) => o.status === 'cancelled');
  const totalEarnings = walletTransactions.filter((t) => t.amount > 0).reduce((sum, t) => sum + t.amount, 0);
  const totalPayouts = walletTransactions.filter((t) => t.type === 'payout').reduce((sum, t) => sum + Math.abs(t.amount), 0);
  const totalDistanceKm = delivered.reduce((sum, o) => sum + (o.distanceKm || 0), 0);

  return {
    orders,
    walletTransactions,
    summary: {
      totalTrips: orders.length,
      deliveredTrips: delivered.length,
      cancelledTrips: cancelled.length,
      totalEarnings,
      totalPayouts,
      totalDistanceKm: Math.round(totalDistanceKm * 10) / 10,
    },
  };
}

const STATUS_LABELS = {
  pending: 'Pending',
  accepted: 'Accepted',
  picked_up: 'Picked up',
  in_transit: 'In transit',
  awaiting_payment: 'Awaiting payment',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
};

const WALLET_TYPE_LABELS = {
  trip_earning: 'Trip fare',
  cancellation_compensation: 'Cancellation compensation',
  payout: 'Payout',
  adjustment: 'Adjustment',
};

// Streams a PDF directly to an Express response - same PDFKit pattern as
// booking.controller.js's downloadInvoicePdf, but a simpler row-based
// layout (this is a statement/ledger, not a precisely-gridded LR form).
function renderDriverReportPdf(res, driver, report) {
  res.setHeader('Content-Type', 'application/pdf');
  const safeName = (driver.userId?.name || 'driver').replace(/[^a-z0-9]+/gi, '-').toLowerCase();
  res.setHeader('Content-Disposition', `attachment; filename="${safeName}-report.pdf"`);

  const doc = new PDFDocument({ margin: 40, size: 'A4' });
  doc.pipe(res);

  const pageLeft = doc.page.margins.left;
  const pageWidth = doc.page.width - pageLeft - doc.page.margins.right;
  const pageBottom = doc.page.height - doc.page.margins.bottom;

  // Adds a new page (re-drawing nothing but resetting doc.y) whenever the
  // next chunk of content wouldn't fit - simple flow-based pagination
  // rather than pre-computing exact page breaks up front.
  const ensureSpace = (needed) => {
    if (doc.y + needed > pageBottom) doc.addPage();
  };

  // --- Letterhead ---
  doc.fontSize(20).font('Helvetica-Bold').text(companyInfo.brandName, pageLeft, doc.y, { width: pageWidth, align: 'center' });
  doc.fontSize(9).font('Helvetica').fillColor('#555').text(companyInfo.legalName, { width: pageWidth, align: 'center' });
  doc.fillColor('#000').moveDown(1);

  doc.fontSize(15).font('Helvetica-Bold').text('Driver Report', pageLeft, doc.y, { width: pageWidth, align: 'center' });
  doc.fontSize(8).font('Helvetica').fillColor('#555').text(`Generated ${new Date().toLocaleString('en-IN')}`, { width: pageWidth, align: 'center' });
  doc.fillColor('#000').moveDown(1.2);

  // --- Driver info ---
  doc.fontSize(12).font('Helvetica-Bold').text('Driver');
  doc.fontSize(9).font('Helvetica');
  doc.text(`Name: ${driver.userId?.name || '—'}`);
  doc.text(`Phone: ${driver.userId?.phone || '—'}`);
  doc.text(`Email: ${driver.userId?.email || '—'}`);
  doc.text(`Vehicle: ${driver.vehicleNumber || '—'} (${(driver.vehicleType || '—').replace('_', ' ')})`);
  doc.text(`License no.: ${driver.licenseNumber || '—'}`);
  doc.text(`Status: ${driver.isApproved ? 'Approved' : 'Pending approval'}`);
  doc.moveDown(1);

  // --- Summary ---
  const s = report.summary;
  doc.fontSize(12).font('Helvetica-Bold').text('Summary');
  doc.fontSize(9).font('Helvetica');
  doc.text(`Total trips: ${s.totalTrips}   |   Delivered: ${s.deliveredTrips}   |   Cancelled: ${s.cancelledTrips}`);
  doc.text(`Total distance (delivered trips): ${s.totalDistanceKm} km`);
  doc.text(`Total earnings credited: Rs ${s.totalEarnings}   |   Total paid out: Rs ${s.totalPayouts}   |   Current wallet balance: Rs ${driver.walletBalance ?? 0}`);
  doc.moveDown(1);

  // --- Trips table ---
  doc.fontSize(12).font('Helvetica-Bold').text(`Trips (${report.orders.length})`);
  doc.moveDown(0.3);

  const tripCols = [
    { key: 'date', label: 'Date', w: 0.11 },
    { key: 'id', label: 'Order', w: 0.1 },
    { key: 'route', label: 'Route', w: 0.34 },
    { key: 'status', label: 'Status', w: 0.14 },
    { key: 'price', label: 'Price', w: 0.1 },
    { key: 'payment', label: 'Payment', w: 0.11 },
    { key: 'customer', label: 'Customer', w: 0.1 },
  ];
  // Draws one aligned row of column labels/values - the bug this fixes:
  // doc.text() advances doc.y after every call, so writing each column
  // with plain doc.y as its y-coordinate made every column start lower
  // than the last instead of forming a single row (they cascaded
  // diagonally down the page). Capturing y ONCE before the loop and
  // passing that fixed value to every column keeps them aligned.
  const drawRow = (cols, values, { bold = false, size = 7.5 } = {}) => {
    const y = doc.y;
    doc.fontSize(size).font(bold ? 'Helvetica-Bold' : 'Helvetica');
    let x = pageLeft;
    let rowHeight = 12;
    cols.forEach((col, i) => {
      const w = pageWidth * col.w;
      const opts = { width: w - 4 };
      if (!bold) Object.assign(opts, { height: 20, ellipsis: true });
      doc.text(String(values[i] ?? '—'), x, y, opts);
      x += w;
    });
    doc.x = pageLeft;
    doc.y = y + rowHeight;
  };

  if (report.orders.length === 0) {
    doc.fontSize(9).font('Helvetica').fillColor('#777').text('No trips yet.').fillColor('#000');
  } else {
    ensureSpace(30);
    drawRow(tripCols, tripCols.map((c) => c.label), { bold: true, size: 8 });
    doc.moveTo(pageLeft, doc.y).lineTo(pageLeft + pageWidth, doc.y).strokeColor('#ccc').stroke().strokeColor('#000');
    doc.y += 4;
    for (const o of report.orders) {
      ensureSpace(22);
      drawRow(tripCols, [
        new Date(o.createdAt).toLocaleDateString('en-IN'),
        o._id.toString().slice(-8).toUpperCase(),
        `${o.pickupLocation?.address || '—'} -> ${o.dropLocation?.address || '—'}`,
        STATUS_LABELS[o.status] || o.status,
        `Rs ${o.price}`,
        o.paymentMethod === 'cod' ? 'COD' : 'Online',
        o.enterpriseId?.companyName || o.customerId?.name || '—',
      ]);
    }
  }
  doc.x = pageLeft;
  doc.moveDown(1);

  // --- Wallet transactions table ---
  ensureSpace(60);
  doc.x = pageLeft;
  doc.fontSize(12).font('Helvetica-Bold').text(`Wallet transactions (${report.walletTransactions.length})`, pageLeft, doc.y, { width: pageWidth });
  doc.moveDown(0.3);
  doc.x = pageLeft;

  if (report.walletTransactions.length === 0) {
    doc.fontSize(9).font('Helvetica').fillColor('#777').text('No wallet activity yet.').fillColor('#000');
  } else {
    const wtCols = [
      { label: 'Date', w: 0.16 },
      { label: 'Type', w: 0.25 },
      { label: 'Amount', w: 0.14 },
      { label: 'Balance after', w: 0.15 },
      { label: 'Note', w: 0.3 },
    ];
    ensureSpace(30);
    drawRow(wtCols, wtCols.map((c) => c.label), { bold: true, size: 8 });
    doc.moveTo(pageLeft, doc.y).lineTo(pageLeft + pageWidth, doc.y).strokeColor('#ccc').stroke().strokeColor('#000');
    doc.y += 4;

    for (const t of report.walletTransactions) {
      ensureSpace(20);
      drawRow(wtCols, [
        new Date(t.createdAt).toLocaleDateString('en-IN'),
        WALLET_TYPE_LABELS[t.type] || t.type,
        `${t.amount >= 0 ? '+' : '-'}Rs ${Math.abs(t.amount)}`,
        `Rs ${t.balanceAfter}`,
        t.note || '—',
      ]);
    }
  }

  doc.end();
}

module.exports = { buildDriverReport, renderDriverReportPdf };

const mongoose = require('mongoose');

const invoiceSchema = new mongoose.Schema(
  {
    enterpriseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Enterprise', required: true },
    orderIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Order' }],
    periodStart: Date,
    periodEnd: Date,
    subtotal: Number,
    gstAmount: Number,
    totalAmount: Number,
    pdfUrl: String,
    status: { type: String, enum: ['draft', 'sent', 'paid', 'overdue'], default: 'draft' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Invoice', invoiceSchema);

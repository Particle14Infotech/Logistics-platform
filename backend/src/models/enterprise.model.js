const mongoose = require('mongoose');

const enterpriseSchema = new mongoose.Schema(
  {
    companyName: { type: String, required: true },
    gstin: String,
    adminUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    subUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    contractPricing: { type: mongoose.Schema.Types.Mixed, default: {} },
    billingCycle: { type: String, enum: ['monthly', 'fortnightly'], default: 'monthly' },
    billingEmail: String,
    creditLimit: { type: Number, default: 0 },
    apiKey: { type: String, select: false },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Enterprise', enterpriseSchema);

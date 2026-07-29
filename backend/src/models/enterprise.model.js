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
    // Approval gate: a brand-new enterprise (self-signup or self-promote via
    // /enterprise/create) starts inactive until an admin approves it via
    // PUT /admin/enterprises/:id/status - see resolveEnterprise() in
    // enterprise.controller.js, which blocks all enterprise routes while false.
    isActive: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Enterprise', enterpriseSchema);

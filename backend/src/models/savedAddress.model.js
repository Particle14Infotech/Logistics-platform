const mongoose = require('mongoose');

// A customer's saved pickup/drop addresses (e.g. "Home", "Office") for
// quick reuse during booking, instead of re-typing/re-searching every time.
const savedAddressSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    label: { type: String, required: true },
    address: { type: String, required: true },
    lat: Number,
    lng: Number,
  },
  { timestamps: true }
);

savedAddressSchema.index({ userId: 1 });

module.exports = mongoose.model('SavedAddress', savedAddressSchema);

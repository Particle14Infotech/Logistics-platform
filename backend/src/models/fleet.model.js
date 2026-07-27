const mongoose = require('mongoose');

const fleetSchema = new mongoose.Schema(
  {
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    companyName: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Fleet', fleetSchema);

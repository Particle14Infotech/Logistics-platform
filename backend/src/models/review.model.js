const mongoose = require('mongoose');

// One real review per delivered trip - submitted by the customer who
// actually took it (see booking.controller.js's submitReview). The unique
// index on orderId is what actually prevents a duplicate review, not
// application logic - a second POST for the same order fails at the DB
// with a duplicate-key error.
const reviewSchema = new mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true, unique: true },
    driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, trim: true },
  },
  { timestamps: true }
);

reviewSchema.index({ driverId: 1, createdAt: -1 });

module.exports = mongoose.model('Review', reviewSchema);

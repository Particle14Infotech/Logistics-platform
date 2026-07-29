const mongoose = require('mongoose');

const geoPointSchema = new mongoose.Schema(
  {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], required: true }, // [lng, lat]
    address: String,
  },
  { _id: false }
);

const statusEventSchema = new mongoose.Schema(
  {
    status: String,
    timestamp: { type: Date, default: Date.now },
    note: String,
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', default: null },
    enterpriseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Enterprise', default: null },
    // Drivers who tapped "Pass" on this order (driver.controller.js's
    // rejectOrder) - excluded from that same driver's available-orders list
    // going forward, so passing on a job actually removes it instead of it
    // reappearing on the next poll.
    rejectedDriverIds: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Driver' }],

    pickupLocation: { type: geoPointSchema, required: true },
    dropLocation: { type: geoPointSchema, required: true },
    waypoints: [geoPointSchema],

    vehicleType: {
      type: String,
      enum: ['bike', 'auto', 'mini_truck', 'medium_truck', 'large_truck'],
      required: true,
    },
    goodsType: String,
    weightKg: Number,
    isFragile: { type: Boolean, default: false },
    insuranceOpted: { type: Boolean, default: false },

    distanceKm: Number,
    price: { type: Number, required: true },

    status: {
      type: String,
      enum: ['pending', 'accepted', 'picked_up', 'in_transit', 'delivered', 'cancelled'],
      default: 'pending',
    },
    paymentStatus: { type: String, enum: ['unpaid', 'paid', 'refunded'], default: 'unpaid' },
    razorpayOrderId: String,

    deliveryOtp: String,
    podImageUrl: String,

    timeline: [statusEventSchema],
  },
  { timestamps: true }
);

orderSchema.index({ 'pickupLocation.coordinates': '2dsphere' });
orderSchema.index({ customerId: 1, status: 1 });

module.exports = mongoose.model('Order', orderSchema);

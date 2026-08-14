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
      enum: ['pending', 'accepted', 'picked_up', 'in_transit', 'awaiting_payment', 'delivered', 'cancelled'],
      default: 'pending',
    },
    paymentStatus: { type: String, enum: ['unpaid', 'paid', 'refunded'], default: 'unpaid' },
    razorpayOrderId: String,
    // Driver cancellation-compensation withheld from the customer's refund -
    // only ever set on cancellation, see booking.controller.js's cancel().
    cancellationFeeAmount: { type: Number, default: 0 },

    // For whichever vehicle types the admin has configured with
    // advanceRequired (see pricingConfig.model.js), both 'cod' and 'online'
    // only charge this advance online at booking time
    // (pricingRules.calculateAdvanceAmount) - fraud/no-show protection.
    // Ungated types: 'online' pays the full price in one shot, and 'cod'
    // has no advance at all (pure cash at delivery). For 'cod', the
    // remainder is always cash at delivery. For 'online' (gated only), the
    // remainder is a second Razorpay payment - see remainderPaid, and
    // driver.controller.js's uploadPod for how paying it completes the
    // delivery (order sits in 'awaiting_payment' until then). paymentStatus
    // 'paid' means whatever was due *at booking* was captured - the advance
    // for a gated order, or the full price otherwise.
    paymentMethod: { type: String, enum: ['online', 'cod'], default: 'online' },
    advanceAmount: { type: Number, default: 0 },
    // Driver-confirmed at delivery (see driver.controller.js's uploadPod) -
    // required before a cod order can be marked delivered.
    codCashCollected: { type: Boolean, default: false },
    // Set once the second Razorpay payment (the remaining 70%) is captured
    // for a gated 'online' order - see payment.controller.js's
    // createRemainderOrder/verify. Always false for 'cod' and for ungated
    // 'online' orders (nothing to track).
    remainderPaid: { type: Boolean, default: false },

    startOtp: String,
    deliveryOtp: String,
    podImageUrl: String,

    // Paperwork the consignor hands the driver at the pickup point (LR
    // copy, invoice, packing list, gate pass - whatever's physically
    // handed over, so no fixed set of types). Any file format, no cap on
    // count - see driver.controller.js's uploadPickupDocuments. Required
    // (at least one) before updateOrderStatus allows picked_up ->
    // in_transit, same spot the existing start-code check already gates.
    pickupDocuments: [
      {
        url: { type: String, required: true },
        originalName: String,
        uploadedAt: { type: Date, default: Date.now },
      },
    ],

    // Same idea at the other end of the trip - proof of delivery paperwork
    // (signed delivery receipt, POD photo, discharge certificate, etc.),
    // any file format, no cap on count. See driver.controller.js's
    // uploadDeliveryDocuments. Required (at least one) before uploadPod
    // allows in_transit -> awaiting_payment/delivered - mirrors the
    // pickupDocuments gate above, just at the opposite end of the trip.
    deliveryDocuments: [
      {
        url: { type: String, required: true },
        originalName: String,
        uploadedAt: { type: Date, default: Date.now },
      },
    ],

    // Compliance/paperwork fields for the printed Lorry Receipt (LR) /
    // waybill (see booking.controller.js's downloadInvoicePdf) - filled in
    // by admin staff after booking (PUT /booking/:id/waybill-details),
    // since a consumer booking via the app won't have GSTINs/e-way bill
    // numbers on hand at checkout. All optional - a waybill still renders
    // (with blank fields) for an order that has none of this set.
    waybillDetails: {
      consigneeName: String,
      consigneePhone: String,
      consignorGstin: String,
      consigneeGstin: String,
      ewayBillNo: String,
      declaredValue: Number,
      ratePerTon: Number,
      rto: String, // the truck's registering RTO location, e.g. "Morbi"
      gstPayableBy: { type: String, enum: ['consignor', 'consignee', 'transporter'] },
      taxType: { type: String, enum: ['none', 'intra_state', 'inter_state'], default: 'none' },
      gstAmount: { type: Number, default: 0 },
      remark: String,
    },

    timeline: [statusEventSchema],
  },
  { timestamps: true }
);

orderSchema.index({ 'pickupLocation.coordinates': '2dsphere' });
orderSchema.index({ customerId: 1, status: 1 });

module.exports = mongoose.model('Order', orderSchema);

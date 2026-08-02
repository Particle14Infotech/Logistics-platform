// Seeds a test Admin user and a test Enterprise account (with its admin user)
// so the web portal has real credentials to log in with during development.
//
// Usage: npm run seed   (from backend/)

require('dotenv').config();
const bcrypt = require('bcryptjs');
const connectDB = require('../src/config/db');
const User = require('../src/models/user.model');
const Enterprise = require('../src/models/enterprise.model');
const Driver = require('../src/models/driver.model');
const Order = require('../src/models/order.model');
const Payment = require('../src/models/payment.model');
const Review = require('../src/models/review.model');
const PricingConfig = require('../src/models/pricingConfig.model');
const Dispute = require('../src/models/dispute.model');
const Invoice = require('../src/models/invoice.model');
const Banner = require('../src/models/banner.model');
const Faq = require('../src/models/faq.model');

const ADMIN_EMAIL = 'admin@particle14.com';
const ADMIN_PASSWORD = 'Admin@12345';

const ENTERPRISE_EMAIL = 'priya@vertexpharma.com';
const ENTERPRISE_PASSWORD = 'Enterprise@12345';

async function seed() {
  await connectDB();

  // --- Platform Admin ---
  const existingAdmin = await User.findOne({ email: ADMIN_EMAIL });
  if (!existingAdmin) {
    const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 10);
    await User.create({
      name: 'Neeraj Kumar',
      email: ADMIN_EMAIL,
      passwordHash,
      role: 'admin',
      isVerified: true,
    });
    console.log(`✅ Admin created: ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
  } else {
    console.log(`ℹ️  Admin already exists: ${ADMIN_EMAIL}`);
  }

  // --- Enterprise Admin + Enterprise Account ---
  let enterpriseUser = await User.findOne({ email: ENTERPRISE_EMAIL });
  if (!enterpriseUser) {
    const passwordHash = await bcrypt.hash(ENTERPRISE_PASSWORD, 10);
    enterpriseUser = await User.create({
      name: 'Priya Sharma',
      email: ENTERPRISE_EMAIL,
      passwordHash,
      role: 'enterprise_admin',
      isVerified: true,
    });
    console.log(`✅ Enterprise admin created: ${ENTERPRISE_EMAIL} / ${ENTERPRISE_PASSWORD}`);
  } else {
    console.log(`ℹ️  Enterprise admin already exists: ${ENTERPRISE_EMAIL}`);
  }

  let enterprise = await Enterprise.findOne({ adminUserId: enterpriseUser._id });
  if (!enterprise) {
    enterprise = await Enterprise.create({
      companyName: 'Vertex Pharma',
      gstin: '27ABCDE1234F1Z5',
      adminUserId: enterpriseUser._id,
      billingEmail: ENTERPRISE_EMAIL,
      creditLimit: 500000,
    });
    enterpriseUser.enterpriseId = enterprise._id;
    await enterpriseUser.save();
    console.log(`✅ Enterprise account created: Vertex Pharma`);
  } else {
    console.log('ℹ️  Enterprise account already exists');
  }

  // --- Sample Drivers (for the admin Orders/Drivers pages to have real data) ---
  const SAMPLE_DRIVERS = [
    { name: 'Ramesh Yadav', phone: '9810000001', vehicleType: 'mini_truck', vehicleNumber: 'DL 01 AB 4521', isApproved: true, isAvailable: true, documents: { licenseUrl: 'https://example.com/docs/ramesh-license.pdf', rcUrl: 'https://example.com/docs/ramesh-rc.pdf', aadhaarUrl: 'https://example.com/docs/ramesh-aadhaar.pdf' } },
    { name: 'Suresh Patil', phone: '9810000002', vehicleType: 'medium_truck', vehicleNumber: 'MH 04 CD 7789', isApproved: true, isAvailable: false, documents: { licenseUrl: 'https://example.com/docs/suresh-license.pdf', rcUrl: 'https://example.com/docs/suresh-rc.pdf' } },
    { name: 'Arjun Reddy', phone: '9810000003', vehicleType: 'auto', vehicleNumber: 'KA 03 EF 1290', isApproved: true, isAvailable: true, documents: { licenseUrl: 'https://example.com/docs/arjun-license.pdf' } },
    { name: 'Vikram Singh', phone: '9810000004', vehicleType: 'large_truck', vehicleNumber: 'TN 09 GH 3345', isApproved: false, isAvailable: false, documents: { licenseUrl: 'https://example.com/docs/vikram-license.pdf', rcUrl: 'https://example.com/docs/vikram-rc.pdf', aadhaarUrl: 'https://example.com/docs/vikram-aadhaar.pdf', panCardUrl: 'https://example.com/docs/vikram-pan.pdf' } },
  ];

  const driverDocs = [];
  for (const d of SAMPLE_DRIVERS) {
    let driverUser = await User.findOne({ phone: d.phone });
    if (!driverUser) {
      driverUser = await User.create({ name: d.name, phone: d.phone, role: 'driver', isVerified: true });
    }
    let driver = await Driver.findOne({ userId: driverUser._id });
    if (!driver) {
      driver = await Driver.create({
        userId: driverUser._id,
        vehicleType: d.vehicleType,
        vehicleNumber: d.vehicleNumber,
        licenseNumber: `DL-${d.phone.slice(-6)}`,
        isApproved: d.isApproved,
        isAvailable: d.isAvailable,
        documents: d.documents ?? {},
        currentLocation: { type: 'Point', coordinates: [77.1 + Math.random(), 28.6 + Math.random()] },
      });
    }
    driverDocs.push(driver);
  }
  console.log(`✅ ${SAMPLE_DRIVERS.length} sample drivers ready`);

  // --- Sample Customer + Orders ---
  let sampleCustomer = await User.findOne({ phone: '9820000001' });
  if (!sampleCustomer) {
    sampleCustomer = await User.create({ name: 'Rohan Textiles', phone: '9820000001', role: 'customer', isVerified: true });
  }

  const existingOrderCount = await Order.countDocuments({ customerId: sampleCustomer._id });
  let seededOrders = [];
  if (existingOrderCount === 0) {
    const SAMPLE_ORDERS = [
      { pickup: 'Delhi', drop: 'Gurugram', vehicleType: 'mini_truck', status: 'in_transit', price: 1240, driver: driverDocs[0] },
      { pickup: 'Pune', drop: 'Mumbai', vehicleType: 'medium_truck', status: 'accepted', price: 6850, driver: driverDocs[1] },
      { pickup: 'Bengaluru', drop: 'Hosur', vehicleType: 'auto', status: 'delivered', price: 420, driver: driverDocs[2] },
      { pickup: 'Chennai', drop: 'Vellore', vehicleType: 'large_truck', status: 'in_transit', price: 12300, driver: driverDocs[3] },
      { pickup: 'Noida', drop: 'Agra', vehicleType: 'medium_truck', status: 'pending', price: 4100, driver: null },
      { pickup: 'Jaipur', drop: 'Kota', vehicleType: 'mini_truck', status: 'cancelled', price: 2050, driver: null },
    ];

    for (const o of SAMPLE_ORDERS) {
      const order = await Order.create({
        customerId: sampleCustomer._id,
        driverId: o.driver?._id ?? null,
        pickupLocation: { type: 'Point', coordinates: [77.1, 28.6], address: o.pickup },
        dropLocation: { type: 'Point', coordinates: [77.3, 28.4], address: o.drop },
        vehicleType: o.vehicleType,
        goodsType: 'General cargo',
        weightKg: 500,
        distanceKm: 45,
        price: o.price,
        status: o.status,
        paymentStatus: o.status === 'delivered' ? 'paid' : 'unpaid',
        timeline: [{ status: o.status, note: 'Seeded sample order' }],
      });
      seededOrders.push(order);
    }
    console.log(`✅ ${SAMPLE_ORDERS.length} sample orders created`);
  } else {
    console.log('ℹ️  Sample orders already exist');
    seededOrders = await Order.find({ customerId: sampleCustomer._id });
  }

  // --- Pricing Config (one rate card per vehicle type) ---
  const DEFAULT_PRICING = [
    { vehicleType: 'bike', baseFare: 25, perKmRate: 6 },
    { vehicleType: 'auto', baseFare: 40, perKmRate: 9 },
    { vehicleType: 'mini_truck', baseFare: 80, perKmRate: 15, perKgRate: 0.5, advanceRequired: true, advanceMode: 'percentage', advanceValue: 30 },
    { vehicleType: 'medium_truck', baseFare: 150, perKmRate: 22, perKgRate: 0.8, advanceRequired: true, advanceMode: 'percentage', advanceValue: 30 },
    { vehicleType: 'large_truck', baseFare: 300, perKmRate: 35, perKgRate: 1.2, advanceRequired: true, advanceMode: 'percentage', advanceValue: 30 },
  ];
  let pricingCreated = 0;
  for (const p of DEFAULT_PRICING) {
    const existing = await PricingConfig.findOne({ vehicleType: p.vehicleType });
    if (!existing) {
      await PricingConfig.create(p);
      pricingCreated++;
    }
  }
  console.log(pricingCreated > 0 ? `✅ ${pricingCreated} pricing configs created` : 'ℹ️  Pricing configs already exist');

  // --- Sample Payments (tied to the delivered order) ---
  const deliveredOrder = seededOrders.find((o) => o.status === 'delivered');
  if (deliveredOrder) {
    const existingPayment = await Payment.findOne({ orderId: deliveredOrder._id });
    if (!existingPayment) {
      await Payment.create({
        orderId: deliveredOrder._id,
        userId: sampleCustomer._id,
        razorpayOrderId: 'order_seeddata001',
        razorpayPaymentId: 'pay_seeddata001',
        razorpaySignature: 'seed_signature_not_real',
        amount: deliveredOrder.price * 100, // paise
        status: 'captured',
      });
      console.log('✅ 1 sample payment created (captured)');
    } else {
      console.log('ℹ️  Sample payment already exists');
    }
  }
  // A second, already-refunded payment for a cancelled order, for filter testing
  const cancelledOrder = seededOrders.find((o) => o.status === 'cancelled');
  if (cancelledOrder) {
    const existingRefund = await Payment.findOne({ orderId: cancelledOrder._id });
    if (!existingRefund) {
      await Payment.create({
        orderId: cancelledOrder._id,
        userId: sampleCustomer._id,
        razorpayOrderId: 'order_seeddata002',
        razorpayPaymentId: 'pay_seeddata002',
        razorpaySignature: 'seed_signature_not_real',
        amount: cancelledOrder.price * 100,
        status: 'refunded',
        refundId: 'rfnd_seeddata002',
      });
      console.log('✅ 1 sample refunded payment created');
    }
  }

  // --- Sample Review (tied to the delivered order, drives the driver's
  // real rating - not a fabricated number, see driver.model.js's rating
  // comment) ---
  if (deliveredOrder) {
    const existingReview = await Review.findOne({ orderId: deliveredOrder._id });
    if (!existingReview) {
      await Review.create({
        orderId: deliveredOrder._id,
        driverId: deliveredOrder.driverId,
        customerId: sampleCustomer._id,
        rating: 5,
        comment: 'On time and careful with the goods.',
      });
      const [agg] = await Review.aggregate([
        { $match: { driverId: deliveredOrder.driverId } },
        { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } },
      ]);
      await Driver.findByIdAndUpdate(deliveredOrder.driverId, { rating: agg.avg, ratingCount: agg.count });
      console.log('✅ 1 sample review created (drives the driver\'s real rating)');
    } else {
      console.log('ℹ️  Sample review already exists');
    }
  }

  // --- Sample Disputes ---
  const inTransitOrder = seededOrders.find((o) => o.status === 'in_transit');
  if (inTransitOrder) {
    const existingDispute = await Dispute.findOne({ orderId: inTransitOrder._id });
    if (!existingDispute) {
      await Dispute.create({
        orderId: inTransitOrder._id,
        raisedBy: sampleCustomer._id,
        raisedByRole: 'customer',
        category: 'delay',
        description: 'Shipment has been "in transit" for much longer than the original ETA suggested.',
        status: 'open',
      });
      console.log('✅ 1 sample dispute created (open)');
    } else {
      console.log('ℹ️  Sample dispute already exists');
    }
  }

  // --- Enterprise Orders + Invoices (for Vertex Pharma's portal pages) ---
  const existingEnterpriseOrders = await Order.countDocuments({ enterpriseId: enterprise._id });
  let enterpriseOrders = [];
  if (existingEnterpriseOrders === 0) {
    const ENTERPRISE_ORDERS = [
      { pickup: 'Vertex Pharma Warehouse, Mumbai', drop: 'Distribution Center, Pune', vehicleType: 'medium_truck', price: 6200, status: 'delivered' },
      { pickup: 'Vertex Pharma Warehouse, Mumbai', drop: 'Regional Hub, Ahmedabad', vehicleType: 'large_truck', price: 14500, status: 'in_transit' },
      { pickup: 'Vertex Pharma Warehouse, Mumbai', drop: 'Distribution Center, Pune', vehicleType: 'mini_truck', price: 2100, status: 'delivered' },
      { pickup: 'Vertex Pharma Warehouse, Mumbai', drop: 'Regional Hub, Surat', vehicleType: 'medium_truck', price: 5400, status: 'pending' },
    ];
    for (const o of ENTERPRISE_ORDERS) {
      const order = await Order.create({
        customerId: enterpriseUser._id,
        enterpriseId: enterprise._id,
        pickupLocation: { type: 'Point', coordinates: [72.8, 19.0], address: o.pickup },
        dropLocation: { type: 'Point', coordinates: [73.8, 18.5], address: o.drop },
        vehicleType: o.vehicleType,
        goodsType: 'Pharmaceutical supplies',
        weightKg: 800,
        distanceKm: 150,
        price: o.price,
        status: o.status,
        paymentStatus: o.status === 'delivered' ? 'paid' : 'unpaid',
        timeline: [{ status: o.status, note: 'Seeded enterprise order' }],
      });
      enterpriseOrders.push(order);
    }
    console.log(`✅ ${ENTERPRISE_ORDERS.length} enterprise orders created`);
  } else {
    console.log('ℹ️  Enterprise orders already exist');
    enterpriseOrders = await Order.find({ enterpriseId: enterprise._id });
  }

  const existingInvoiceCount = await Invoice.countDocuments({ enterpriseId: enterprise._id });
  if (existingInvoiceCount === 0 && enterpriseOrders.length > 0) {
    const deliveredEnterpriseOrders = enterpriseOrders.filter((o) => o.status === 'delivered');
    const subtotal = deliveredEnterpriseOrders.reduce((sum, o) => sum + o.price, 0);
    const gstAmount = Math.round(subtotal * 0.18);

    const lastMonthStart = new Date();
    lastMonthStart.setMonth(lastMonthStart.getMonth() - 1, 1);
    const lastMonthEnd = new Date();
    lastMonthEnd.setDate(0);

    await Invoice.create({
      enterpriseId: enterprise._id,
      orderIds: deliveredEnterpriseOrders.map((o) => o._id),
      periodStart: lastMonthStart,
      periodEnd: lastMonthEnd,
      subtotal,
      gstAmount,
      totalAmount: subtotal + gstAmount,
      status: 'paid',
    });

    await Invoice.create({
      enterpriseId: enterprise._id,
      orderIds: [],
      periodStart: new Date(new Date().setDate(1)),
      periodEnd: new Date(),
      subtotal: 0,
      gstAmount: 0,
      totalAmount: 0,
      status: 'draft',
    });

    console.log('✅ 2 sample invoices created (1 paid, 1 draft)');
  } else {
    console.log('ℹ️  Sample invoices already exist');
  }

  // --- Content: Banners + FAQs ---
  const bannerCount = await Banner.countDocuments();
  if (bannerCount === 0) {
    await Banner.insertMany([
      { title: 'Monsoon Special: 15% off intercity bookings', imageUrl: 'https://example.com/banners/monsoon-promo.jpg', linkUrl: '/promo/monsoon', sortOrder: 1 },
      { title: 'Refer a business, earn ₹500 wallet credit', imageUrl: 'https://example.com/banners/referral.jpg', linkUrl: '/promo/referral', sortOrder: 2 },
    ]);
    console.log('✅ 2 sample banners created');
  } else {
    console.log('ℹ️  Banners already exist');
  }

  const faqCount = await Faq.countDocuments();
  if (faqCount === 0) {
    await Faq.insertMany([
      { question: 'How is the fare calculated?', answer: 'Fare is based on a base fare plus a per-kilometer rate for your selected vehicle type, with an optional per-kg charge for heavier loads. Surge pricing may apply during high demand.', category: 'pricing', sortOrder: 1 },
      { question: 'Can I cancel a booking after a driver is assigned?', answer: 'Yes, you can cancel from the booking details screen. A cancellation fee may apply if the driver has already started toward pickup.', category: 'booking', sortOrder: 2 },
      { question: 'How do I track my shipment in real time?', answer: 'Once a driver is assigned, open the booking to see a live map with the vehicle position, updated every few seconds, along with an ETA.', category: 'tracking', sortOrder: 3 },
    ]);
    console.log('✅ 3 sample FAQs created');
  } else {
    console.log('ℹ️  FAQs already exist');
  }

  console.log('\nSeed complete. Log in at:');
  console.log(`  Admin portal      -> ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
  console.log(`  Enterprise portal -> ${ENTERPRISE_EMAIL} / ${ENTERPRISE_PASSWORD}`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});

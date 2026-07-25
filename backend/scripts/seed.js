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

  const existingEnterprise = await Enterprise.findOne({ adminUserId: enterpriseUser._id });
  if (!existingEnterprise) {
    const enterprise = await Enterprise.create({
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
    { name: 'Ramesh Yadav', phone: '9810000001', vehicleType: 'mini_truck', vehicleNumber: 'DL 01 AB 4521', isApproved: true, isAvailable: true },
    { name: 'Suresh Patil', phone: '9810000002', vehicleType: 'medium_truck', vehicleNumber: 'MH 04 CD 7789', isApproved: true, isAvailable: false },
    { name: 'Arjun Reddy', phone: '9810000003', vehicleType: 'auto', vehicleNumber: 'KA 03 EF 1290', isApproved: true, isAvailable: true },
    { name: 'Vikram Singh', phone: '9810000004', vehicleType: 'large_truck', vehicleNumber: 'TN 09 GH 3345', isApproved: false, isAvailable: false },
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
        rating: 4 + Math.random(),
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
      await Order.create({
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
    }
    console.log(`✅ ${SAMPLE_ORDERS.length} sample orders created`);
  } else {
    console.log('ℹ️  Sample orders already exist');
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

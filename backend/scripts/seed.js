// Seeds a test Admin user and a test Enterprise account (with its admin user)
// so the web portal has real credentials to log in with during development.
//
// Usage: npm run seed   (from backend/)

require('dotenv').config();
const bcrypt = require('bcryptjs');
const connectDB = require('../src/config/db');
const User = require('../src/models/user.model');
const Enterprise = require('../src/models/enterprise.model');

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

  console.log('\nSeed complete. Log in at:');
  console.log(`  Admin portal      -> ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
  console.log(`  Enterprise portal -> ${ENTERPRISE_EMAIL} / ${ENTERPRISE_PASSWORD}`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});

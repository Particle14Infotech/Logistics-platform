const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Fleet = require('../models/fleet.model');
const Driver = require('../models/driver.model');
const User = require('../models/user.model');
const Order = require('../models/order.model');
const { assertValidVehicleType } = require('../services/vehicleCategory.service');

// GET /api/v1/fleet/profile
exports.getProfile = catchAsync(async (req, res) => {
  const fleet = await Fleet.findOne({ ownerId: req.user.id });
  return success(res, { fleet: fleet || null });
});

// POST /api/v1/fleet/profile  { companyName }
exports.createProfile = catchAsync(async (req, res) => {
  const existing = await Fleet.findOne({ ownerId: req.user.id });
  if (existing) throw new AppError('A fleet profile already exists for this account', 400);

  const { companyName } = req.body;
  if (!companyName) throw new AppError('companyName is required', 400);

  const fleet = await Fleet.create({ ownerId: req.user.id, companyName });
  return success(res, { fleet }, 'Fleet created', 201);
});

async function getOwnFleet(userId) {
  const fleet = await Fleet.findOne({ ownerId: userId });
  if (!fleet) throw new AppError('Complete fleet setup first', 404);
  return fleet;
}

// GET /api/v1/fleet/vehicles
exports.listVehicles = catchAsync(async (req, res) => {
  const fleet = await getOwnFleet(req.user.id);
  const vehicles = await Driver.find({ fleetId: fleet._id }).populate('userId', 'name phone');
  return success(res, { vehicles });
});

// POST /api/v1/fleet/vehicles  { driverPhone, driverName, vehicleType, vehicleNumber, licenseNumber }
// Adds a vehicle+driver under this fleet. If a User with this phone already
// exists, reuses it (must not already be a different role); otherwise
// creates a new driver-role account for them. The resulting Driver record
// starts unapproved, same KYC review path as an independent driver - shows
// up in Admin > Drivers either way, with fleetId set so the admin can see
// it's part of a fleet.
exports.addVehicle = catchAsync(async (req, res) => {
  const fleet = await getOwnFleet(req.user.id);
  const { driverPhone, driverName, vehicleType, vehicleNumber, licenseNumber } = req.body;
  if (!driverPhone || !vehicleType || !vehicleNumber || !licenseNumber) {
    throw new AppError('driverPhone, vehicleType, vehicleNumber, and licenseNumber are required', 400);
  }
  await assertValidVehicleType(vehicleType);

  let driverUser = await User.findOne({ phone: driverPhone });
  if (!driverUser) {
    driverUser = await User.create({ phone: driverPhone, name: driverName, role: 'driver', isVerified: false });
  } else if (driverUser.role !== 'driver') {
    throw new AppError('This phone number is already registered under a different role', 400);
  }

  const existingDriverProfile = await Driver.findOne({ userId: driverUser._id });
  if (existingDriverProfile) throw new AppError('This driver already has a vehicle registered', 400);

  const driver = await Driver.create({
    userId: driverUser._id,
    fleetId: fleet._id,
    vehicleType,
    vehicleNumber,
    licenseNumber,
    isApproved: false,
    isAvailable: false,
  });

  return success(res, { driver }, 'Vehicle added - pending admin approval', 201);
});

// DELETE /api/v1/fleet/vehicles/:id
// Detaches this vehicle from the fleet rather than deleting the Driver
// document outright - fleetId: null is the schema's own existing meaning
// for "independent driver" (see driver.model.js), so this doesn't orphan
// that driver's trip/earnings/wallet history or any Order.driverId
// references to it. To hand the same vehicle to a different person,
// remove it here, then add it fresh for the new driver via addVehicle -
// deliberately not a single "transfer" operation, since that would raise
// a real question this app has no answer to (does the new driver inherit
// the old one's accumulated earnings/wallet balance? no - they start
// fresh, same as any newly added vehicle).
exports.removeVehicle = catchAsync(async (req, res) => {
  const fleet = await getOwnFleet(req.user.id);
  const driver = await Driver.findOne({ _id: req.params.id, fleetId: fleet._id });
  if (!driver) throw new AppError('Vehicle not found in your fleet', 404);

  driver.fleetId = null;
  driver.isAvailable = false;
  await driver.save();

  return success(res, {}, 'Vehicle removed from your fleet');
});

// GET /api/v1/fleet/dashboard - aggregate stats across every vehicle in the fleet
exports.dashboard = catchAsync(async (req, res) => {
  const fleet = await getOwnFleet(req.user.id);
  const vehicles = await Driver.find({ fleetId: fleet._id });
  const driverIds = vehicles.map((v) => v._id);

  const totalEarnings = vehicles.reduce((sum, v) => sum + (v.totalEarnings || 0), 0);
  const totalTrips = vehicles.reduce((sum, v) => sum + (v.totalTrips || 0), 0);
  const activeVehicles = vehicles.filter((v) => v.isAvailable).length;
  const approvedVehicles = vehicles.filter((v) => v.isApproved).length;

  const activeOrders = await Order.countDocuments({
    driverId: { $in: driverIds },
    status: { $in: ['accepted', 'picked_up', 'in_transit', 'awaiting_payment'] },
  });

  return success(res, {
    companyName: fleet.companyName,
    totalVehicles: vehicles.length,
    approvedVehicles,
    activeVehicles,
    totalEarnings,
    totalTrips,
    activeOrders,
  });
});

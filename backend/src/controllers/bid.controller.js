const { catchAsync, success, AppError } = require('../utils/apiResponse');
const Bid = require('../models/bid.model');
const Order = require('../models/order.model');
const Driver = require('../models/driver.model');
const { sendToUser } = require('../services/notification.service');

// POST /api/v1/bid/:orderId  { amount }  (driver)
// Upserts so a driver can revise their own bid by submitting again rather
// than being blocked by the unique orderId+driverId index.
exports.placeBid = catchAsync(async (req, res) => {
  const { amount } = req.body;
  if (!amount || amount <= 0) throw new AppError('A valid bid amount is required', 400);

  const driver = await Driver.findOne({ userId: req.user.id });
  if (!driver) throw new AppError('No driver profile found for this account', 404);
  if (!driver.isApproved) throw new AppError('Your account is pending KYC approval', 403);

  const order = await Order.findById(req.params.orderId);
  if (!order) throw new AppError('Booking not found', 404);
  if (order.pricingMode !== 'bidding') throw new AppError('This booking is not open for bidding', 400);
  if (order.status !== 'pending') throw new AppError('This booking is no longer open for bids', 409);
  if (order.vehicleType !== driver.vehicleType) throw new AppError('Vehicle type mismatch', 400);

  const bid = await Bid.findOneAndUpdate(
    { orderId: order._id, driverId: driver._id },
    { amount, status: 'pending' },
    { upsert: true, new: true }
  );

  sendToUser(order.customerId, {
    title: 'New bid received',
    body: `A driver bid ₹${amount} on your ${order.pickupLocation.address} → ${order.dropLocation.address} booking.`,
    data: { bookingId: String(order._id) },
  });

  return success(res, { bid }, 'Bid submitted');
});

// GET /api/v1/bid/order/:orderId  (customer, must own the order)
exports.listBidsForOrder = catchAsync(async (req, res) => {
  const order = await Order.findById(req.params.orderId);
  if (!order) throw new AppError('Booking not found', 404);
  if (String(order.customerId) !== String(req.user.id)) throw new AppError('Not authorized to view these bids', 403);

  const bids = await Bid.find({ orderId: order._id, status: 'pending' })
    .populate({ path: 'driverId', select: 'vehicleNumber vehicleType rating totalTrips', populate: { path: 'userId', select: 'name phone' } })
    .sort({ amount: 1 });

  return success(res, { bids });
});

// POST /api/v1/bid/:bidId/accept  (customer, must own the order)
exports.acceptBid = catchAsync(async (req, res) => {
  const bid = await Bid.findById(req.params.bidId);
  if (!bid) throw new AppError('Bid not found', 404);

  const order = await Order.findById(bid.orderId);
  if (!order) throw new AppError('Booking not found', 404);
  if (String(order.customerId) !== String(req.user.id)) throw new AppError('Not authorized to accept this bid', 403);
  if (order.status !== 'pending') throw new AppError('This booking is no longer pending', 409);

  order.driverId = bid.driverId;
  order.price = bid.amount;
  order.status = 'accepted';
  order.timeline.push({ status: 'accepted', note: `Bid of ₹${bid.amount} accepted` });
  await order.save();

  bid.status = 'accepted';
  await bid.save();
  await Bid.updateMany({ orderId: order._id, _id: { $ne: bid._id } }, { status: 'rejected' });

  const io = req.app.get('io');
  if (io) io.to(`booking:${order._id}`).emit('status_broadcast', { bookingId: order._id, status: 'accepted', timestamp: Date.now() });

  const winningDriver = await Driver.findById(bid.driverId).select('userId');
  if (winningDriver) {
    sendToUser(winningDriver.userId, {
      title: 'Your bid was accepted!',
      body: `₹${bid.amount} for ${order.pickupLocation.address} → ${order.dropLocation.address}`,
      data: { bookingId: String(order._id), status: 'accepted' },
    });
  }

  return success(res, { order }, 'Bid accepted');
});

// GET /api/v1/bid/available-orders  (driver) - bidding-mode orders open for
// this driver's vehicle type, each annotated with the driver's own current
// bid (if any) so the UI can show "Update bid" vs "Place bid".
exports.listBiddableOrders = catchAsync(async (req, res) => {
  const driver = await Driver.findOne({ userId: req.user.id });
  if (!driver) throw new AppError('No driver profile found for this account', 404);
  if (!driver.isApproved) throw new AppError('Your account is pending KYC approval', 403);

  const orders = await Order.find({ status: 'pending', pricingMode: 'bidding', vehicleType: driver.vehicleType })
    .populate('customerId', 'name')
    .sort({ createdAt: 1 })
    .limit(20);

  const myBids = await Bid.find({ orderId: { $in: orders.map((o) => o._id) }, driverId: driver._id });
  const myBidByOrder = Object.fromEntries(myBids.map((b) => [String(b.orderId), b.amount]));

  const withBids = orders.map((o) => ({ ...o.toObject(), myBidAmount: myBidByOrder[String(o._id)] ?? null }));

  return success(res, { orders: withBids });
});

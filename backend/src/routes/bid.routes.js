const router = require('express').Router();
const ctrl = require('../controllers/bid.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

// Driver-side: browse biddable orders, place/update a bid
router.get('/available-orders', protect, authorize('driver'), ctrl.listBiddableOrders);
router.post('/:orderId', protect, authorize('driver'), ctrl.placeBid);

// Customer-side: view bids on their own order, accept one
router.get('/order/:orderId', protect, authorize('customer'), ctrl.listBidsForOrder);
router.post('/:bidId/accept', protect, authorize('customer'), ctrl.acceptBid);

module.exports = router;

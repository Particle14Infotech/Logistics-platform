const router = require('express').Router();
const ctrl = require('../controllers/payment.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.post('/create-order', protect, ctrl.createOrder);
router.post('/create-remainder-order', protect, ctrl.createRemainderOrder);
router.post('/verify', ctrl.verify); // hit by the client callback
router.post('/webhook', ctrl.webhook); // hit by Razorpay's servers directly - signature-authenticated, not JWT
// Admin-only: a customer's own path to a refund is PUT /booking/:id/cancel,
// which correctly withholds the driver-compensation fee and credits the
// driver's wallet. This endpoint has none of that logic (a flat, full
// refund of every captured payment) - it used to also accept the order's
// own customer, which let anyone refund themselves in full on any order at
// any status, including an already-delivered one, with the driver never
// compensated.
router.post('/refund', protect, authorize('admin'), ctrl.refund);
router.get('/history', protect, ctrl.history);
router.get('/saved-cards', protect, ctrl.listSavedCards);
router.delete('/saved-cards/:tokenId', protect, ctrl.deleteSavedCard);

module.exports = router;

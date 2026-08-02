const router = require('express').Router();
const ctrl = require('../controllers/payment.controller');
const { protect } = require('../middlewares/auth.middleware');

router.post('/create-order', protect, ctrl.createOrder);
router.post('/create-remainder-order', protect, ctrl.createRemainderOrder);
router.post('/verify', ctrl.verify); // hit by the client callback
router.post('/webhook', ctrl.webhook); // hit by Razorpay's servers directly - signature-authenticated, not JWT
router.post('/refund', protect, ctrl.refund);
router.get('/history', protect, ctrl.history);
router.get('/saved-cards', protect, ctrl.listSavedCards);
router.delete('/saved-cards/:tokenId', protect, ctrl.deleteSavedCard);

module.exports = router;

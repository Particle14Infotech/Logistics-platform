const router = require('express').Router();
const ctrl = require('../controllers/payment.controller');
const { protect } = require('../middlewares/auth.middleware');

router.post('/create-order', protect, ctrl.createOrder);
router.post('/verify', ctrl.verify); // hit by Razorpay webhook too - verify signature inside
router.post('/refund', protect, ctrl.refund);
router.get('/history', protect, ctrl.history);

module.exports = router;

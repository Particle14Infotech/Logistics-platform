const router = require('express').Router();
const ctrl = require('../controllers/driver.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.use(protect, authorize('driver'));

router.get('/available-orders', ctrl.availableOrders);
router.post('/accept/:bookingId', ctrl.acceptOrder);
router.post('/reject/:bookingId', ctrl.rejectOrder);
router.put('/status', ctrl.updateStatus);
router.post('/pod/:bookingId', ctrl.uploadPod);
router.get('/earnings', ctrl.earnings);

module.exports = router;

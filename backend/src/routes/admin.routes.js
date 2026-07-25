const router = require('express').Router();
const ctrl = require('../controllers/admin.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.use(protect, authorize('admin'));

router.get('/orders', ctrl.listOrders);
router.put('/orders/:id/assign', ctrl.assignDriver);
router.get('/drivers', ctrl.listDrivers);
router.put('/drivers/:id', ctrl.updateDriverStatus);
router.get('/analytics', ctrl.analytics);
router.put('/pricing', ctrl.updatePricing);

module.exports = router;

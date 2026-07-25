const router = require('express').Router();
const ctrl = require('../controllers/admin.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.use(protect, authorize('admin'));

router.get('/orders', ctrl.listOrders);
router.get('/orders/:id', ctrl.getOrderById);
router.put('/orders/:id/assign', ctrl.assignDriver);

router.get('/drivers', ctrl.listDrivers);
router.get('/drivers/:id', ctrl.getDriverById);
router.put('/drivers/:id', ctrl.updateDriverStatus);

router.get('/vehicles', ctrl.listVehicles);

router.get('/pricing', ctrl.getPricing);
router.put('/pricing', ctrl.updatePricing);

router.get('/payments', ctrl.listPayments);
router.put('/payments/:id/refund', ctrl.refundPayment);

router.get('/disputes', ctrl.listDisputes);
router.put('/disputes/:id/resolve', ctrl.resolveDispute);

router.get('/analytics', ctrl.analytics);

module.exports = router;

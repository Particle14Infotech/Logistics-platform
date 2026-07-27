const router = require('express').Router();
const ctrl = require('../controllers/fleet.controller');
const { protect, authorize } = require('../middlewares/auth.middleware');

router.use(protect, authorize('fleet_owner'));

router.get('/profile', ctrl.getProfile);
router.post('/profile', ctrl.createProfile);
router.get('/vehicles', ctrl.listVehicles);
router.post('/vehicles', ctrl.addVehicle);
router.get('/dashboard', ctrl.dashboard);

module.exports = router;

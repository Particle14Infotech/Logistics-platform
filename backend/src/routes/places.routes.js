const router = require('express').Router();
const ctrl = require('../controllers/places.controller');
const { protect } = require('../middlewares/auth.middleware');

router.get('/autocomplete', protect, ctrl.autocomplete);
router.get('/details', protect, ctrl.details);
router.get('/geocode', protect, ctrl.geocode);
router.get('/reverse-geocode', protect, ctrl.reverseGeocode);

module.exports = router;

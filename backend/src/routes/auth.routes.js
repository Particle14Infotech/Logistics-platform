const router = require('express').Router();
const ctrl = require('../controllers/auth.controller');
const { protect } = require('../middlewares/auth.middleware');

router.post('/firebase-session', ctrl.firebaseSession);
router.post('/login', ctrl.login);
router.get('/profile', protect, ctrl.getProfile);
router.put('/profile', protect, ctrl.updateProfile);
router.post('/refresh-token', ctrl.refreshToken);
router.post('/logout', protect, ctrl.logout);
router.post('/fcm-token', protect, ctrl.registerFcmToken);

module.exports = router;

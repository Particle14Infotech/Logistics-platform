const router = require('express').Router();
const ctrl = require('../controllers/auth.controller');
const { protect } = require('../middlewares/auth.middleware');

router.post('/send-otp', ctrl.sendOtp);
router.post('/verify-otp', ctrl.verifyOtp);
router.post('/firebase-session', ctrl.firebaseSession);
router.post('/register', protect, ctrl.register);
router.post('/login', ctrl.login);
router.get('/profile', protect, ctrl.getProfile);
router.put('/profile', protect, ctrl.updateProfile);
router.post('/refresh-token', ctrl.refreshToken);
router.post('/logout', protect, ctrl.logout);
router.post('/fcm-token', protect, ctrl.registerFcmToken);

module.exports = router;

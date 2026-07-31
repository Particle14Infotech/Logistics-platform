const router = require('express').Router();
const ctrl = require('../controllers/content.controller');

router.get('/faqs', ctrl.listFaqs);

module.exports = router;

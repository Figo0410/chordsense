const express = require('express');
const router = express.Router();
const { syncToCloud } = require('../controllers/syncController');

router.post('/push', syncToCloud);

module.exports = router;
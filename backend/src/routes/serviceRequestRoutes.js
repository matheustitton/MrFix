const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/auth');
const {
  createRequest, listRequests, getRequest, updateStatus, createRequestValidation,
} = require('../controllers/serviceRequestController');

router.use(authenticate);

router.post('/', createRequestValidation, createRequest);
router.get('/', listRequests);
router.get('/:id', getRequest);
router.patch('/:id/status', updateStatus);

module.exports = router;

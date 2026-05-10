const express = require('express');
const router = express.Router();
const { authenticate, requireRole } = require('../middlewares/auth');
const { listProviders, getProvider, addSpecialty, mySpecialties, specialtyValidation } = require('../controllers/providerController');

// Public
router.get('/', listProviders);
router.get('/me/specialties', authenticate, requireRole('provider'), mySpecialties);
router.get('/:id', getProvider);
router.post('/specialties', authenticate, requireRole('provider'), specialtyValidation, addSpecialty);

module.exports = router;

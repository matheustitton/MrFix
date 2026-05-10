const express = require('express');
const router = express.Router();
const { register, login, me, registerValidation, loginValidation } = require('../controllers/authController');
const { authenticate } = require('../middlewares/auth');

router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);
router.get('/me', authenticate, me);

module.exports = router;

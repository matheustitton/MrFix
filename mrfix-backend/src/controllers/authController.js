const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { User } = require('../models');

// ─── Validation Rules ────────────────────────────────────────────────────────

const registerValidation = [
  body('name').trim().notEmpty().withMessage('Nome é obrigatório.'),
  body('email').isEmail().normalizeEmail().withMessage('E-mail inválido.'),
  body('password').isLength({ min: 6 }).withMessage('Senha deve ter no mínimo 6 caracteres.'),
  body('role').isIn(['client', 'provider']).withMessage('Role deve ser client ou provider.'),
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other', 'prefer_not_to_say'])
    .withMessage('Gênero inválido.'),
];

const loginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
];

// ─── Helpers ─────────────────────────────────────────────────────────────────

const generateToken = (user) =>
  jwt.sign(
    { id: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

const sanitizeUser = (user) => {
  const { password_hash, ...safe } = user.toJSON();
  return safe;
};

// ─── Controllers ─────────────────────────────────────────────────────────────

/**
 * POST /auth/register
 * Register a new user (client or provider)
 */
const register = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }

  const { name, email, password, role, gender, phone } = req.body;

  try {
    const existing = await User.findOne({ where: { email } });
    if (existing) {
      return res.status(409).json({ error: 'E-mail já cadastrado.' });
    }

    const password_hash = await bcrypt.hash(password, 12);
    const user = await User.create({ name, email, password_hash, role, gender, phone });

    return res.status(201).json({
      message: 'Usuário criado com sucesso.',
      user: sanitizeUser(user),
      token: generateToken(user),
    });
  } catch (err) {
    console.error('[register]', err);
    return res.status(500).json({ error: 'Erro interno ao criar usuário.' });
  }
};

/**
 * POST /auth/login
 * Authenticate and receive a JWT token
 */
const login = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  try {
    const user = await User.findOne({ where: { email } });
    if (!user || !user.is_active) {
      return res.status(401).json({ error: 'Credenciais inválidas.' });
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Credenciais inválidas.' });
    }

    return res.json({
      message: 'Login realizado com sucesso.',
      user: sanitizeUser(user),
      token: generateToken(user),
    });
  } catch (err) {
    console.error('[login]', err);
    return res.status(500).json({ error: 'Erro interno ao autenticar.' });
  }
};

/**
 * GET /auth/me
 * Return current authenticated user
 */
const me = async (req, res) => {
  return res.json({ user: sanitizeUser(req.user) });
};

module.exports = { register, login, me, registerValidation, loginValidation };

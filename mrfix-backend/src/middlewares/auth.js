const jwt = require('jsonwebtoken');
const { User } = require('../models');

/**
 * Middleware: authenticate
 * Validates JWT token and attaches the user to req.user
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Token de autenticação não fornecido.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findByPk(decoded.id);
    if (!user || !user.is_active) {
      return res.status(401).json({ error: 'Usuário não encontrado ou inativo.' });
    }

    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido ou expirado.' });
  }
};

/**
 * Middleware: requireRole
 * Restricts access to specific roles: 'client' | 'provider'
 */
const requireRole = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({
      error: `Acesso negado. Apenas ${roles.join(' ou ')} pode executar esta ação.`,
    });
  }
  next();
};

module.exports = { authenticate, requireRole };

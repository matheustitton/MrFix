const { body, validationResult } = require('express-validator');
const { User, ProviderSpecialty, ServiceCategory, Rating } = require('../models');
const { Op } = require('sequelize');

// Validações
const specialtyValidation = [
  body('category_id').isUUID().withMessage('category_id inválido.'),
  body('average_price').optional().isFloat({ min: 0 }).withMessage('Preço médio inválido.'),
  body('experience_years').optional().isInt({ min: 0 }),
];

// Controllers
/**
 * GET /providers
 */
const listProviders = async (req, res) => {
  const { category_id, gender, page = 1, limit = 10 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  const userWhere = { role: 'provider', is_active: true };
  if (gender && gender !== 'any') userWhere.gender = gender;

  const specialtyWhere = { is_available: true };
  if (category_id) specialtyWhere.category_id = category_id;

  try {
    const { count, rows } = await User.findAndCountAll({
      where: userWhere,
      attributes: ['id', 'name', 'email', 'phone', 'gender', 'average_rating', 'rating_count', 'avatar_url'],
      include: [
        {
          model: ProviderSpecialty,
          as: 'specialties',
          where: category_id ? specialtyWhere : undefined,
          required: !!category_id,
          include: [{ model: ServiceCategory, as: 'category', attributes: ['id', 'name', 'icon'] }],
        },
      ],
      order: [['average_rating', 'DESC']],
      limit: parseInt(limit),
      offset,
      distinct: true,
    });

    return res.json({
      data: rows,
      pagination: { total: count, page: parseInt(page), limit: parseInt(limit), pages: Math.ceil(count / limit) },
    });
  } catch (err) {
    console.error('[listProviders]', err);
    return res.status(500).json({ error: 'Erro ao listar prestadores.' });
  }
};

/**
 * GET /providers/:id
 */
const getProvider = async (req, res) => {
  try {
    const provider = await User.findOne({
      where: { id: req.params.id, role: 'provider', is_active: true },
      attributes: ['id', 'name', 'email', 'phone', 'gender', 'average_rating', 'rating_count', 'avatar_url', 'created_at'],
      include: [
        {
          model: ProviderSpecialty,
          as: 'specialties',
          include: [{ model: ServiceCategory, as: 'category' }],
        },
      ],
    });

    if (!provider) return res.status(404).json({ error: 'Prestador não encontrado.' });

    return res.json({ data: provider });
  } catch (err) {
    console.error('[getProvider]', err);
    return res.status(500).json({ error: 'Erro ao buscar prestador.' });
  }
};

/**
 * POST /providers/specialties
 */
const addSpecialty = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

  const { category_id, average_price, experience_years, bio } = req.body;

  try {
    const category = await ServiceCategory.findByPk(category_id);
    if (!category) return res.status(404).json({ error: 'Categoria não encontrada.' });

    const existing = await ProviderSpecialty.findOne({
      where: { provider_id: req.user.id, category_id },
    });
    if (existing) return res.status(409).json({ error: 'Você já possui esta especialidade cadastrada.' });

    const specialty = await ProviderSpecialty.create({
      provider_id: req.user.id,
      category_id,
      average_price,
      experience_years,
      bio,
    });

    const full = await ProviderSpecialty.findByPk(specialty.id, {
      include: [{ model: ServiceCategory, as: 'category' }],
    });

    return res.status(201).json({ message: 'Especialidade adicionada.', data: full });
  } catch (err) {
    console.error('[addSpecialty]', err);
    return res.status(500).json({ error: 'Erro ao adicionar especialidade.' });
  }
};

/**
 * GET /providers/me/specialties
 */
const mySpecialties = async (req, res) => {
  try {
    const specialties = await ProviderSpecialty.findAll({
      where: { provider_id: req.user.id },
      include: [{ model: ServiceCategory, as: 'category' }],
    });
    return res.json({ data: specialties });
  } catch (err) {
    console.error('[mySpecialties]', err);
    return res.status(500).json({ error: 'Erro ao buscar especialidades.' });
  }
};

module.exports = { listProviders, getProvider, addSpecialty, mySpecialties, specialtyValidation };

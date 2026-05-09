const { body, query, validationResult } = require('express-validator');
const { Op } = require('sequelize');
const { ServiceRequest, User, ServiceCategory, Rating } = require('../models');

// ─── Validation ───────────────────────────────────────────────────────────────

const createRequestValidation = [
  body('category_id').isUUID().withMessage('category_id inválido.'),
  body('title').trim().notEmpty().withMessage('Título é obrigatório.'),
  body('address').trim().notEmpty().withMessage('Endereço é obrigatório.'),
  body('preferred_gender')
    .optional()
    .isIn(['male', 'female', 'any'])
    .withMessage('preferred_gender deve ser male, female ou any.'),
  body('scheduled_at')
    .optional()
    .isISO8601()
    .withMessage('Data de agendamento inválida.'),
];

// ─── Helpers ─────────────────────────────────────────────────────────────────

const requestIncludes = [
  { model: User, as: 'client', attributes: ['id', 'name', 'email', 'phone', 'gender', 'average_rating', 'avatar_url'] },
  { model: User, as: 'provider', attributes: ['id', 'name', 'email', 'phone', 'gender', 'average_rating', 'avatar_url'] },
  { model: ServiceCategory, as: 'category', attributes: ['id', 'name', 'icon'] },
];

// ─── Controllers ─────────────────────────────────────────────────────────────

/**
 * POST /service-requests
 * Client creates a new service request
 */
const createRequest = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

  if (req.user.role !== 'client') {
    return res.status(403).json({ error: 'Apenas clientes podem criar solicitações.' });
  }

  const { category_id, title, description, address, latitude, longitude, preferred_gender, scheduled_at } = req.body;

  try {
    const category = await ServiceCategory.findByPk(category_id);
    if (!category) return res.status(404).json({ error: 'Categoria não encontrada.' });

    const request = await ServiceRequest.create({
      client_id: req.user.id,
      category_id,
      title,
      description,
      address,
      latitude,
      longitude,
      preferred_gender: preferred_gender || 'any',
      scheduled_at,
      status: 'pending',
    });

    const full = await ServiceRequest.findByPk(request.id, { include: requestIncludes });

    // ── Sprint 2 hook: publish event to MOM ──────────────────────────────────
    // eventEmitter.emit('service_request.created', { requestId: request.id, clientId: req.user.id });

    return res.status(201).json({
      message: 'Solicitação criada com sucesso.',
      data: full,
    });
  } catch (err) {
    console.error('[createRequest]', err);
    return res.status(500).json({ error: 'Erro ao criar solicitação.' });
  }
};

/**
 * GET /service-requests
 * List requests (filtered by user role and query params)
 */
const listRequests = async (req, res) => {
  const { status, category_id, page = 1, limit = 10 } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(limit);

  const where = {};

  if (req.user.role === 'client') {
    where.client_id = req.user.id;
  } else if (req.user.role === 'provider') {
    // Provider sees: their own accepted requests + pending requests matching their gender filter
    where[Op.or] = [
      { provider_id: req.user.id },
      { status: 'pending', preferred_gender: { [Op.in]: ['any', req.user.gender || 'any'] } },
    ];
  }

  if (status) where.status = status;
  if (category_id) where.category_id = category_id;

  try {
    const { count, rows } = await ServiceRequest.findAndCountAll({
      where,
      include: requestIncludes,
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset,
    });

    return res.json({
      data: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(count / limit),
      },
    });
  } catch (err) {
    console.error('[listRequests]', err);
    return res.status(500).json({ error: 'Erro ao listar solicitações.' });
  }
};

/**
 * GET /service-requests/:id
 * Get single request by ID
 */
const getRequest = async (req, res) => {
  try {
    const request = await ServiceRequest.findByPk(req.params.id, { include: requestIncludes });
    if (!request) return res.status(404).json({ error: 'Solicitação não encontrada.' });

    // Only client owner or assigned provider can view details
    const isClient = request.client_id === req.user.id;
    const isProvider = request.provider_id === req.user.id;
    const isPendingVisible = req.user.role === 'provider' && request.status === 'pending';

    if (!isClient && !isProvider && !isPendingVisible) {
      return res.status(403).json({ error: 'Acesso negado.' });
    }

    return res.json({ data: request });
  } catch (err) {
    console.error('[getRequest]', err);
    return res.status(500).json({ error: 'Erro ao buscar solicitação.' });
  }
};

/**
 * PATCH /service-requests/:id/status
 * Update request status
 * - provider: pending → accepted | cancelled
 * - provider: accepted → in_progress
 * - provider: in_progress → completed
 * - client: pending → cancelled
 */
const updateStatus = async (req, res) => {
  const { status, cancellation_reason } = req.body;
  const allowedStatuses = ['accepted', 'in_progress', 'completed', 'cancelled'];

  if (!allowedStatuses.includes(status)) {
    return res.status(422).json({ error: `Status inválido. Permitidos: ${allowedStatuses.join(', ')}` });
  }

  try {
    const request = await ServiceRequest.findByPk(req.params.id);
    if (!request) return res.status(404).json({ error: 'Solicitação não encontrada.' });

    const isClient = request.client_id === req.user.id;
    const isProvider = request.provider_id === req.user.id || req.user.role === 'provider';

    // Business rules
    if (status === 'accepted') {
      if (req.user.role !== 'provider') return res.status(403).json({ error: 'Apenas prestadores podem aceitar solicitações.' });
      if (request.status !== 'pending') return res.status(409).json({ error: 'Solicitação não está mais disponível.' });
      request.provider_id = req.user.id;
    }

    if (status === 'in_progress') {
      if (!isProvider) return res.status(403).json({ error: 'Apenas o prestador designado pode iniciar o serviço.' });
      if (request.status !== 'accepted') return res.status(409).json({ error: 'Solicitação precisa estar aceita para iniciar.' });
    }

    if (status === 'completed') {
      if (!isProvider) return res.status(403).json({ error: 'Apenas o prestador pode concluir o serviço.' });
      if (request.status !== 'in_progress') return res.status(409).json({ error: 'Serviço precisa estar em andamento para ser concluído.' });
      request.completed_at = new Date();
    }

    if (status === 'cancelled') {
      if (!isClient && !isProvider) return res.status(403).json({ error: 'Acesso negado.' });
      if (['completed', 'cancelled'].includes(request.status)) {
        return res.status(409).json({ error: 'Não é possível cancelar este serviço.' });
      }
      request.cancelled_at = new Date();
      request.cancellation_reason = cancellation_reason || null;
    }

    request.status = status;
    await request.save();

    const updated = await ServiceRequest.findByPk(request.id, { include: requestIncludes });

    // ── Sprint 2 hook: publish event to MOM ──────────────────────────────────
    // eventEmitter.emit('service_request.status_changed', { requestId: request.id, status, actorId: req.user.id });

    return res.json({
      message: `Status atualizado para "${status}".`,
      data: updated,
    });
  } catch (err) {
    console.error('[updateStatus]', err);
    return res.status(500).json({ error: 'Erro ao atualizar status.' });
  }
};

module.exports = { createRequest, listRequests, getRequest, updateStatus, createRequestValidation };

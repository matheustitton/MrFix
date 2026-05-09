const { body, validationResult } = require('express-validator');
const { Rating, ServiceRequest, User } = require('../models');
const { Op } = require('sequelize');

const ratingValidation = [
  body('score').isInt({ min: 1, max: 5 }).withMessage('Nota deve ser entre 1 e 5.'),
  body('comment').optional().trim().isLength({ max: 500 }),
];

/**
 * POST /ratings
 * Submit a rating for a completed service
 * Both client and provider can rate each other
 */
const createRating = async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(422).json({ errors: errors.array() });

  const { service_request_id, score, comment } = req.body;

  try {
    const request = await ServiceRequest.findByPk(service_request_id);
    if (!request) return res.status(404).json({ error: 'Solicitação não encontrada.' });
    if (request.status !== 'completed') return res.status(409).json({ error: 'Avaliação só pode ser feita após a conclusão do serviço.' });

    const isClient = request.client_id === req.user.id;
    const isProvider = request.provider_id === req.user.id;
    if (!isClient && !isProvider) return res.status(403).json({ error: 'Você não faz parte desta solicitação.' });

    const rated_id = isClient ? request.provider_id : request.client_id;

    // Prevent duplicate rating
    const existing = await Rating.findOne({
      where: { service_request_id, rater_id: req.user.id },
    });
    if (existing) return res.status(409).json({ error: 'Você já avaliou este serviço.' });

    const rating = await Rating.create({
      service_request_id,
      rater_id: req.user.id,
      rated_id,
      score,
      comment,
    });

    // Update average rating on the rated user
    const allRatings = await Rating.findAll({ where: { rated_id } });
    const avg = allRatings.reduce((sum, r) => sum + r.score, 0) / allRatings.length;
    await User.update(
      { average_rating: parseFloat(avg.toFixed(2)), rating_count: allRatings.length },
      { where: { id: rated_id } }
    );

    return res.status(201).json({ message: 'Avaliação registrada com sucesso.', data: rating });
  } catch (err) {
    console.error('[createRating]', err);
    return res.status(500).json({ error: 'Erro ao registrar avaliação.' });
  }
};

/**
 * GET /ratings/user/:userId
 * Get all ratings received by a user
 */
const getUserRatings = async (req, res) => {
  try {
    const ratings = await Rating.findAll({
      where: { rated_id: req.params.userId },
      include: [{ model: User, as: 'rater', attributes: ['id', 'name', 'avatar_url'] }],
      order: [['created_at', 'DESC']],
    });
    return res.json({ data: ratings });
  } catch (err) {
    console.error('[getUserRatings]', err);
    return res.status(500).json({ error: 'Erro ao buscar avaliações.' });
  }
};

module.exports = { createRating, getUserRatings, ratingValidation };

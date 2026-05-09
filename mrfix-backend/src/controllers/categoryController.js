const { ServiceCategory } = require('../models');

/**
 * GET /categories
 * List all service categories (eletricista, bombeiro, hidráulica, etc.)
 */
const listCategories = async (req, res) => {
  try {
    const categories = await ServiceCategory.findAll({ order: [['name', 'ASC']] });
    return res.json({ data: categories });
  } catch (err) {
    console.error('[listCategories]', err);
    return res.status(500).json({ error: 'Erro ao listar categorias.' });
  }
};

/**
 * GET /categories/:id
 * Get single category
 */
const getCategory = async (req, res) => {
  try {
    const category = await ServiceCategory.findByPk(req.params.id);
    if (!category) return res.status(404).json({ error: 'Categoria não encontrada.' });
    return res.json({ data: category });
  } catch (err) {
    console.error('[getCategory]', err);
    return res.status(500).json({ error: 'Erro ao buscar categoria.' });
  }
};

module.exports = { listCategories, getCategory };

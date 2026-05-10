const express = require('express');
const ratingRouter = express.Router();
const categoryRouter = express.Router();

const { authenticate } = require('../middlewares/auth');
const { createRating, getUserRatings, ratingValidation } = require('../controllers/ratingController');
const { listCategories, getCategory } = require('../controllers/categoryController');

// Ratings
ratingRouter.post('/', authenticate, ratingValidation, createRating);
ratingRouter.get('/user/:userId', getUserRatings);

// Categories (public)
categoryRouter.get('/', listCategories);
categoryRouter.get('/:id', getCategory);

module.exports = { ratingRouter, categoryRouter };

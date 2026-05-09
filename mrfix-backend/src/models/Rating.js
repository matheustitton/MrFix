const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Model: Rating
 * Mutual rating system:
 * - client rates provider after service completion
 * - provider rates client after service completion
 */

const Rating = sequelize.define('Rating', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  service_request_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'service_requests', key: 'id' },
  },
  rater_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'User who gave the rating',
    references: { model: 'users', key: 'id' },
  },
  rated_id: {
    type: DataTypes.UUID,
    allowNull: false,
    comment: 'User who received the rating',
    references: { model: 'users', key: 'id' },
  },
  score: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: { min: 1, max: 5 },
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'ratings',
});

module.exports = Rating;

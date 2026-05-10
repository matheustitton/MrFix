const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Model: ServiceRequest
 */
const ServiceRequest = sequelize.define('ServiceRequest', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  client_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: true,
    comment: 'Set when provider accepts the request',
    references: { model: 'users', key: 'id' },
  },
  category_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'service_categories', key: 'id' },
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  address: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  latitude: {
    type: DataTypes.FLOAT,
    allowNull: true,
  },
  longitude: {
    type: DataTypes.FLOAT,
    allowNull: true,
  },
  status: {
    type: DataTypes.ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  preferred_gender: {
    type: DataTypes.ENUM('male', 'female', 'any'),
    defaultValue: 'any',
    comment: 'Client preference for provider gender — safety feature',
  },
  scheduled_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  agreed_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
  },
  verification_token: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'OTP token sent to client upon service start',
  },
  token_validated_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  payment_method: {
    type: DataTypes.ENUM('credit_card', 'debit_card', 'pix'),
    allowNull: true,
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'failed', 'refunded'),
    defaultValue: 'pending',
  },
  completed_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  cancelled_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  cancellation_reason: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'service_requests',
});

module.exports = ServiceRequest;

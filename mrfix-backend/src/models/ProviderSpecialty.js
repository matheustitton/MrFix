const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Model: ProviderSpecialty
 * Links a provider to one or more service categories with pricing info.
 * Prepared for: Sprint 2+ (MOM events on specialty updates)
 */
const ProviderSpecialty = sequelize.define('ProviderSpecialty', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  provider_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  category_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: { model: 'service_categories', key: 'id' },
  },
  average_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    comment: 'Average price per service in BRL',
  },
  experience_years: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  is_available: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  tableName: 'provider_specialties',
});

module.exports = ProviderSpecialty;

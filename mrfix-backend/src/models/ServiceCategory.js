const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

/**
 * Model: ServiceCategory
 * Represents service types: electrician, plumber, mason, etc.
 */
const ServiceCategory = sequelize.define('ServiceCategory', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  icon: {
    type: DataTypes.STRING,
    allowNull: true,
    comment: 'Icon name or URL for the mobile app',
  },
}, {
  tableName: 'service_categories',
});

module.exports = ServiceCategory;

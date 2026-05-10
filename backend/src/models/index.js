const sequelize = require('../config/database');
const User = require('./User');
const ServiceCategory = require('./ServiceCategory');
const ProviderSpecialty = require('./ProviderSpecialty');
const ServiceRequest = require('./ServiceRequest');
const Rating = require('./Rating');

// Associações
// User ↔ ProviderSpecialty
User.hasMany(ProviderSpecialty, { foreignKey: 'provider_id', as: 'specialties' });
ProviderSpecialty.belongsTo(User, { foreignKey: 'provider_id', as: 'provider' });

// ServiceCategory ↔ ProviderSpecialty
ServiceCategory.hasMany(ProviderSpecialty, { foreignKey: 'category_id', as: 'providerSpecialties' });
ProviderSpecialty.belongsTo(ServiceCategory, { foreignKey: 'category_id', as: 'category' });

// ServiceRequest associations
ServiceRequest.belongsTo(User, { foreignKey: 'client_id', as: 'client' });
ServiceRequest.belongsTo(User, { foreignKey: 'provider_id', as: 'provider' });
ServiceRequest.belongsTo(ServiceCategory, { foreignKey: 'category_id', as: 'category' });
User.hasMany(ServiceRequest, { foreignKey: 'client_id', as: 'clientRequests' });
User.hasMany(ServiceRequest, { foreignKey: 'provider_id', as: 'providerRequests' });

// Rating associations
Rating.belongsTo(ServiceRequest, { foreignKey: 'service_request_id', as: 'serviceRequest' });
Rating.belongsTo(User, { foreignKey: 'rater_id', as: 'rater' });
Rating.belongsTo(User, { foreignKey: 'rated_id', as: 'rated' });

module.exports = {
  sequelize,
  User,
  ServiceCategory,
  ProviderSpecialty,
  ServiceRequest,
  Rating,
};

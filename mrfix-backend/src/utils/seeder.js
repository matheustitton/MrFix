const bcrypt = require('bcryptjs');
const { sequelize, User, ServiceCategory, ProviderSpecialty, ServiceRequest } = require('../models');

const seed = async () => {
  console.log('Starting database seed...');

  // ── Categories ────────────────────────────────────────────────────────────
  const categories = await ServiceCategory.bulkCreate([
    { name: 'Eletricista', description: 'Instalações e reparos elétricos', icon: 'bolt' },
    { name: 'Encanador', description: 'Serviços hidráulicos e encanamento', icon: 'water_drop' },
    { name: 'Pedreiro', description: 'Obras, reformas e alvenaria', icon: 'construction' },
    { name: 'Pintor', description: 'Pintura interna e externa', icon: 'format_paint' },
    { name: 'Marceneiro', description: 'Móveis sob medida e reparos em madeira', icon: 'chair' },
    { name: 'Técnico de Ar Condicionado', description: 'Instalação e manutenção de ar condicionado', icon: 'ac_unit' },
    { name: 'Serralheiro', description: 'Grades, portões e estruturas metálicas', icon: 'fence' },
    { name: 'Jardineiro', description: 'Jardins, poda e paisagismo', icon: 'yard' },
  ], { ignoreDuplicates: true });

  console.log(`${categories.length} categories seeded`);

  // ── Users ──────────────────────────────────────────────────────────────────
  const passwordHash = await bcrypt.hash('senha123', 12);

  const [clientFemale] = await User.findOrCreate({
    where: { email: 'ana@mrfix.com' },
    defaults: {
      name: 'Ana Oliveira',
      email: 'ana@mrfix.com',
      password_hash: passwordHash,
      role: 'client',
      gender: 'female',
      phone: '31999990001',
    },
  });

  const [clientMale] = await User.findOrCreate({
    where: { email: 'carlos@mrfix.com' },
    defaults: {
      name: 'Carlos Mendes',
      email: 'carlos@mrfix.com',
      password_hash: passwordHash,
      role: 'client',
      gender: 'male',
      phone: '31999990002',
    },
  });

  const [providerFemale] = await User.findOrCreate({
    where: { email: 'julia@mrfix.com' },
    defaults: {
      name: 'Julia Santos',
      email: 'julia@mrfix.com',
      password_hash: passwordHash,
      role: 'provider',
      gender: 'female',
      phone: '31999990003',
      average_rating: 4.8,
      rating_count: 25,
    },
  });

  const [providerMale] = await User.findOrCreate({
    where: { email: 'marcos@mrfix.com' },
    defaults: {
      name: 'Marcos Lima',
      email: 'marcos@mrfix.com',
      password_hash: passwordHash,
      role: 'provider',
      gender: 'male',
      phone: '31999990004',
      average_rating: 4.5,
      rating_count: 40,
    },
  });

  console.log('Users seeded');

  // ── Specialties ────────────────────────────────────────────────────────────
  const allCategories = await ServiceCategory.findAll();
  const catMap = Object.fromEntries(allCategories.map(c => [c.name, c.id]));

  await ProviderSpecialty.findOrCreate({
    where: { provider_id: providerFemale.id, category_id: catMap['Eletricista'] },
    defaults: {
      average_price: 150.00,
      experience_years: 5,
      bio: 'Eletricista certificada com experiência em instalações residenciais e comerciais.',
    },
  });

  await ProviderSpecialty.findOrCreate({
    where: { provider_id: providerFemale.id, category_id: catMap['Pintor'] },
    defaults: {
      average_price: 200.00,
      experience_years: 3,
      bio: 'Pintura interna e externa com acabamento premium.',
    },
  });

  await ProviderSpecialty.findOrCreate({
    where: { provider_id: providerMale.id, category_id: catMap['Encanador'] },
    defaults: {
      average_price: 180.00,
      experience_years: 10,
      bio: 'Especialista em hidráulica, vazamentos e instalações.',
    },
  });

  await ProviderSpecialty.findOrCreate({
    where: { provider_id: providerMale.id, category_id: catMap['Pedreiro'] },
    defaults: {
      average_price: 250.00,
      experience_years: 15,
      bio: 'Reformas completas, alvenaria e acabamentos.',
    },
  });

  console.log('Specialties seeded');

  // ── Sample Request ─────────────────────────────────────────────────────────
  await ServiceRequest.findOrCreate({
    where: { client_id: clientFemale.id, status: 'pending', title: 'Instalação de tomadas' },
    defaults: {
      category_id: catMap['Eletricista'],
      title: 'Instalação de tomadas',
      description: 'Preciso instalar 3 tomadas novas na sala e quarto.',
      address: 'Rua das Flores, 123 - Belo Horizonte, MG',
      preferred_gender: 'female',
      status: 'pending',
    },
  });

  console.log('Sample request seeded');
  console.log('\n Seed complete!');
  console.log('\nTest credentials (password: senha123):');
  console.log('  Client (female): ana@mrfix.com');
  console.log('  Client (male):   carlos@mrfix.com');
  console.log('  Provider (female): julia@mrfix.com');
  console.log('  Provider (male):   marcos@mrfix.com');
};

module.exports = seed;

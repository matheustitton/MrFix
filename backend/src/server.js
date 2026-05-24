require('dotenv').config();
const express = require('express');
const cors = require('cors');

const { sequelize } = require('./models');
const seed = require('./utils/seeder');
const { connect: connectRabbitMQ, disconnect: disconnectRabbitMQ } = require('./config/rabbitmq');
const { startAllConsumers } = require('./messaging');

const authRoutes = require('./routes/authRoutes');
const serviceRequestRoutes = require('./routes/serviceRequestRoutes');
const providerRoutes = require('./routes/providerRoutes');
const { ratingRouter, categoryRouter } = require('./routes/otherRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares 
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => res.json({
  status: 'ok',
  app: 'MrFix API',
  version: '1.0.0',
  timestamp: new Date().toISOString(),
}));

// Routes 
app.use('/api/auth', authRoutes);
app.use('/api/service-requests', serviceRequestRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/ratings', ratingRouter);
app.use('/api/categories', categoryRouter);

// 404 
app.use((req, res) => res.status(404).json({ error: 'Rota não encontrada.' }));

// Global error handler
app.use((err, req, res, next) => {
  console.error('[Global Error]', err);
  res.status(500).json({ error: 'Erro interno do servidor.' });
});

// Start do servidor, bd e rabbit
const start = async () => {
  try {
    // Bd
    await sequelize.authenticate();
    console.log('✅ Database connected.');
    await sequelize.sync({ force: false });
    console.log('✅ Models synchronized.');

    if (process.env.NODE_ENV !== 'test') {
      await seed();
    }

    // Rabbit — conexão e consumers
    try {
      await connectRabbitMQ();
      await startAllConsumers();
    } catch (momErr) {
      console.warn('[MOM] ⚠️  RabbitMQ indisponível no startup — API REST funcionando sem MOM.');
      console.warn('[MOM] Inicie o RabbitMQ e o servidor reconectará automaticamente.');
    }

    const server = app.listen(PORT, () => {
      console.log(`\n🚀 MrFix API rodando em http://localhost:${PORT}`);
      console.log(`📋 Health: http://localhost:${PORT}/health\n`);
    });

    // Desligamento
    const shutdown = async (signal) => {
      console.log(`\n[Server] ${signal} recebido. Encerrando...`);
      server.close(async () => {
        await disconnectRabbitMQ();
        await sequelize.close();
        console.log('[Server] Encerrado.');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

  } catch (err) {
    console.error('❌ Falha ao iniciar servidor:', err);
    process.exit(1);
  }
};

start();

module.exports = app;

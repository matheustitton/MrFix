const { startRequestCreatedConsumer } = require('./consumers/requestCreatedConsumer');
const { startRequestAcceptedConsumer } = require('./consumers/requestAcceptedConsumer');
const { startStatusChangedConsumer } = require('./consumers/statusChangedConsumer');

/**
 * Adicionar um novo consumidor: basta importar e chamar aqui.
 */
const startAllConsumers = async () => {
  console.log('\n[Messaging] Iniciando consumidor...');
  await startRequestCreatedConsumer();
  await startRequestAcceptedConsumer();
  await startStatusChangedConsumer();
  console.log('[Messaging] ✅ Todos os consumidores ativos.\n');
};

module.exports = { startAllConsumers };

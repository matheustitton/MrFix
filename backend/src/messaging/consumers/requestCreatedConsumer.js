const { getChannel } = require('../../config/rabbitmq');
const { QUEUES, QUEUE_OPTIONS } = require('../queues');
const { User, ProviderSpecialty } = require('../../models');
const { Op } = require('sequelize');

/**
 * Consumer: service_request.created
 */
const startRequestCreatedConsumer = async () => {
  try {
    const ch = await getChannel();
    await ch.assertQueue(QUEUES.SERVICE_REQUEST_CREATED, QUEUE_OPTIONS);

    console.log(`[Consumidor] 👂 Escutando fila: ${QUEUES.SERVICE_REQUEST_CREATED}`);

    ch.consume(QUEUES.SERVICE_REQUEST_CREATED, async (msg) => {
      if (!msg) return;

      let payload;
      try {
        payload = JSON.parse(msg.content.toString());
      } catch {
        console.error('[Consumidor:request_created] Payload inválido — descartando mensagem');
        ch.nack(msg, false, false); // dead-letter: não reencaminha
        return;
      }

      console.log('\n[Consumidor:request_created] 📨 Nova solicitação recebida:', payload);

      try {
        const { categoryId, preferredGender } = payload;
        const genderFilter = preferredGender && preferredGender !== 'any'
          ? { gender: preferredGender }
          : {};

        const eligibleProviders = await User.findAll({
          where: { role: 'provider', is_active: true, ...genderFilter },
          attributes: ['id', 'name', 'email', 'gender'],
          include: [{
            model: ProviderSpecialty,
            as: 'specialties',
            where: { category_id: categoryId, is_available: true },
            required: true,
          }],
        });

        if (eligibleProviders.length === 0) {
          console.log('[Consumidor:request_created] ⚠️  Nenhum prestador elegível encontrado para esta solicitação.');
        } else {
          console.log(`[Consumidor:request_created] 🔔 ${eligibleProviders.length} prestador(es) seriam notificados:`);
          eligibleProviders.forEach(p => {
            console.log(`   → ${p.name} (${p.gender}) | ID: ${p.id}`);
            // await sendPushNotification(p.id, { title: 'Nova solicitação!', body: payload.title });
          });
        }

        ch.ack(msg);
        console.log('[Consumidor:request_created] ✅ Mensagem processada com sucesso.\n');

      } catch (err) {
        console.error('[Consumidor:request_created] ❌ Erro ao processar:', err.message);
        ch.nack(msg, false, true);
      }
    });
  } catch (err) {
    console.error('[Consumidor:request_created] Falha ao iniciar consumidor:', err.message);
  }
};

module.exports = { startRequestCreatedConsumer };

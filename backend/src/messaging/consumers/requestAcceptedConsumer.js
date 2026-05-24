const { getChannel } = require('../../config/rabbitmq');
const { QUEUES, QUEUE_OPTIONS } = require('../queues');
const { User } = require('../../models');

/**
 * Consumer: service_request.accepted
 */
const startRequestAcceptedConsumer = async () => {
  try {
    const ch = await getChannel();
    await ch.assertQueue(QUEUES.SERVICE_REQUEST_ACCEPTED, QUEUE_OPTIONS);

    console.log(`[Consumidor] 👂 Escutando fila: ${QUEUES.SERVICE_REQUEST_ACCEPTED}`);

    ch.consume(QUEUES.SERVICE_REQUEST_ACCEPTED, async (msg) => {
      if (!msg) return;

      let payload;
      try {
        payload = JSON.parse(msg.content.toString());
      } catch {
        ch.nack(msg, false, false);
        return;
      }

      console.log('\n[Consumidor:request_accepted] 📨 Solicitação aceita:', payload);

      try {
        const { clientId, providerId, providerName, requestId } = payload;

        const client = await User.findByPk(clientId, {
          attributes: ['id', 'name', 'email'],
        });

        if (client) {
          console.log(`[Consumidor:request_accepted] 🔔 Notificando cliente ${client.name}:`);
          console.log(`   → ${providerName} aceitou sua solicitação (ID: ${requestId})`);

          // await sendPushNotification(clientId, {
          //   title: 'Solicitação aceita!',
          //   body: `${providerName} está a caminho.`,
          //   data: { requestId, providerId }
          // });
        }

        ch.ack(msg);
        console.log('[Consumidor:request_accepted] ✅ Mensagem processada.\n');

      } catch (err) {
        console.error('[Consumidor:request_accepted] ❌ Erro:', err.message);
        ch.nack(msg, false, true);
      }
    });
  } catch (err) {
    console.error('[Consumidor:request_accepted] Falha ao iniciar consumidor:', err.message);
  }
};

module.exports = { startRequestAcceptedConsumer };

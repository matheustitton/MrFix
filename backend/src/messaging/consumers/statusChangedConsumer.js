const { getChannel } = require('../../config/rabbitmq');
const { QUEUES, QUEUE_OPTIONS } = require('../queues');
const { User } = require('../../models');

/**
 * Consumer: service_request.status_changed
 *
 * Fluxo coberto:
 *   pending    → accepted    : notifica o cliente
 *   accepted   → in_progress : notifica o cliente
 *   in_progress→ completed   : notifica o cliente (evento separado tb publica)
 *   qualquer   → cancelled   : notifica o outro lado
 *
 */
const startStatusChangedConsumer = async () => {
  try {
    const ch = await getChannel();
    await ch.assertQueue(QUEUES.SERVICE_REQUEST_STATUS_CHANGED, QUEUE_OPTIONS);

    console.log(`[Consumidor:status_changed] 👂 Escutando fila: ${QUEUES.SERVICE_REQUEST_STATUS_CHANGED}`);

    ch.consume(QUEUES.SERVICE_REQUEST_STATUS_CHANGED, async (msg) => {
      if (!msg) return;

      let payload;
      try {
        payload = JSON.parse(msg.content.toString());
      } catch {
        console.error('[Consumidor:status_changed] Payload inválido — descartando mensagem');
        ch.nack(msg, false, false);
        return;
      }

      console.log('\n[Consumidor:status_changed] 📨 Mudança de status recebida:', payload);

      try {
        const { requestId, clientId, providerId, oldStatus, newStatus, actorId, actorRole } = payload;

        // Determina quem notificar: sempre o lado oposto de quem agiu
        const notifyUserId = actorRole === 'provider' ? clientId : providerId;

        if (!notifyUserId) {
          console.log('[Consumidor:status_changed] ℹ️  Sem destinatário para notificar (prestador ainda não designado).');
          ch.ack(msg);
          return;
        }

        const notifyUser = await User.findByPk(notifyUserId, {
          attributes: ['id', 'name', 'email'],
        });

        if (!notifyUser) {
          console.warn('[Consumidor:status_changed] ⚠️  Usuário destinatário não encontrado.');
          ch.ack(msg);
          return;
        }

        // Monta mensagem legível para o usuário
        const statusMessages = {
          accepted: '✅ Sua solicitação foi aceita por um prestador!',
          in_progress: '🔧 O prestador chegou e o serviço está em andamento.',
          completed: '🎉 Serviço concluído! Deixe sua avaliação.',
          cancelled: '❌ A solicitação foi cancelada.',
        };

        const userMessage = statusMessages[newStatus] || `Status atualizado: ${newStatus}`;

        console.log(`[Consumidor:status_changed] 🔔 Notificando ${notifyUser.name} (${notifyUser.email}):`);
        console.log(`   Solicitação: ${requestId}`);
        console.log(`   ${oldStatus} → ${newStatus}`);
        console.log(`   Mensagem: ${userMessage}`);

        // Sprint 4: Firebase push notification
        // await sendPushNotification(notifyUserId, {
        //   title: 'MrFix',
        //   body: userMessage,
        //   data: { requestId, newStatus }
        // });

        ch.ack(msg);
        console.log('[Consumidor:status_changed] ✅ Mensagem processada com sucesso.\n');

      } catch (err) {
        console.error('[Consumidor:status_changed] ❌ Erro ao processar:', err.message);
        ch.nack(msg, false, true);
      }
    });
  } catch (err) {
    console.error('[Consumidor:status_changed] Falha ao iniciar consumidor:', err.message);
  }
};

module.exports = { startStatusChangedConsumer };

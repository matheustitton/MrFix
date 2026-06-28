const { getChannel } = require('../config/rabbitmq');
const { QUEUES, QUEUE_OPTIONS, PUBLISH_OPTIONS } = require('./queues');

/**
 * Publisher de Eventos — MrFix
 *
 * Responsável por publicar eventos de domínio nas filas do RabbitMQ.
 * Cada método corresponde a um evento de negócio.
 *
 * Padrão: Work Queue (fila ponto-a-ponto com persistência)

/**
 * Publica uma mensagem em uma fila.
 * Declara a fila antes de publicar para garantir que ela existe.
 *
 * @param {string} queue  - Nome da fila (use QUEUES.*)
 * @param {object} payload - Dados do evento (será serializado como JSON)
 */
const publish = async (queue, payload) => {
  try {
    const ch = await getChannel();
    await ch.assertQueue(queue, QUEUE_OPTIONS);

    const message = Buffer.from(JSON.stringify({
      ...payload,
      timestamp: new Date().toISOString(),
    }));

    ch.sendToQueue(queue, message, PUBLISH_OPTIONS);

    console.log(`[Publisher] ✅ Evento publicado → ${queue}`, payload);
  } catch (err) {
    // Falha no MOM não deve derrubar a API REST
    console.error(`[Publisher] ❌ Falha ao publicar em ${queue}:`, err.message);
  }
};

// ─── Eventos de Domínio ────────────────────────────────────────────────────

/**
 * Evento: service_request.created
 * Disparado quando: cliente cria uma nova solicitação
 * Consumido por:    consumer de notificação ao prestador
 *
 * Payload:
 * {
 *   requestId:        UUID da solicitação
 *   clientId:         UUID do cliente
 *   categoryId:       UUID da categoria
 *   categoryName:     Nome da categoria (ex: "Eletricista")
 *   title:            Título da solicitação
 *   address:          Endereço do serviço
 *   preferredGender:  'male' | 'female' | 'any'
 *   scheduledAt:      ISO date string ou null
 * }
 */
const publishRequestCreated = (request, category) => publish(
  QUEUES.SERVICE_REQUEST_CREATED,
  {
    requestId: request.id,
    clientId: request.client_id,
    categoryId: request.category_id,
    categoryName: category?.name || 'Não informado',
    title: request.title,
    address: request.address,
    preferredGender: request.preferred_gender,
    scheduledAt: request.scheduled_at || null,
  }
);

/**
 * Evento: service_request.accepted
 * Disparado quando: prestador aceita uma solicitação pendente
 * Consumido por:    consumer de notificação ao cliente
 *
 * Payload:
 * {
 *   requestId:    UUID da solicitação
 *   clientId:     UUID do cliente (destinatário da notificação)
 *   providerId:   UUID do prestador que aceitou
 *   providerName: Nome do prestador
 * }
 */
const publishRequestAccepted = (request, provider) => publish(
  QUEUES.SERVICE_REQUEST_ACCEPTED,
  {
    requestId: request.id,
    clientId: request.client_id,
    providerId: provider.id,
    providerName: provider.name,
  }
);

/**
 * Evento: service_request.status_changed
 * Disparado quando: qualquer transição de status ocorre
 * Consumido por:    ambos os apps para atualizar a UI em tempo real
 *
 * Payload:
 * {
 *   requestId: UUID da solicitação
 *   clientId:  UUID do cliente
 *   providerId: UUID do prestador (pode ser null se ainda não aceito)
 *   oldStatus: status anterior
 *   newStatus: novo status
 *   actorId:   UUID de quem fez a mudança
 *   actorRole: 'client' | 'provider'
 * }
 */
const publishStatusChanged = (request, oldStatus, actor) => publish(
  QUEUES.SERVICE_REQUEST_STATUS_CHANGED,
  {
    requestId: request.id,
    clientId: request.client_id,
    providerId: request.provider_id || null,
    oldStatus,
    newStatus: request.status,
    actorId: actor.id,
    actorRole: actor.role,
  }
);

/**
 * Evento: service_request.completed
 * Disparado quando: prestador marca o serviço como concluído
 * Consumido por:    consumer que notifica o cliente para avaliar
 *
 * Payload:
 * {
 *   requestId:    UUID da solicitação
 *   clientId:     UUID do cliente
 *   providerId:   UUID do prestador
 *   completedAt:  ISO date string
 * }
 */
const publishRequestCompleted = (request) => publish(
  QUEUES.SERVICE_REQUEST_COMPLETED,
  {
    requestId: request.id,
    clientId: request.client_id,
    providerId: request.provider_id,
    completedAt: request.completed_at,
  }
);

module.exports = {
  publishRequestCreated,
  publishRequestAccepted,
  publishStatusChanged,
  publishRequestCompleted,
};

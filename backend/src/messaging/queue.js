const QUEUES = {
  // Publicado quando: cliente cria uma nova solicitação de serviço
  // Consumido por:    app do prestador (notificação de nova demanda)
    SERVICE_REQUEST_CREATED: 'service_request.created',

  // Publicado quando: prestador aceita uma solicitação pendente
  // Consumido por:    app do cliente (notificação de aceite)
    SERVICE_REQUEST_ACCEPTED: 'service_request.accepted',

  // Publicado quando: qualquer mudança de status ocorre
  // Consumido por:    ambos os apps (atualização de estado em tempo real)
    SERVICE_REQUEST_STATUS_CHANGED: 'service_request.status_changed',

  // Publicado quando: serviço é concluído pelo prestador
  // Consumido por:    app do cliente (convite para avaliar)
    SERVICE_REQUEST_COMPLETED: 'service_request.completed',
};

/**
 * Opções padrão para todas as filas.
 * durable: true → fila persiste no disco, mensagens não se perdem com restart
 */
const QUEUE_OPTIONS = { durable: true };

/**
 * Opções padrão para publicação de mensagens.
 * persistent: true → mensagem é gravada em disco pelo RabbitMQ
 * content_type: application/json → autodocumenta o formato do payload
 */
const PUBLISH_OPTIONS = {
    persistent: true,
    contentType: 'application/json',
};

module.exports = { QUEUES, QUEUE_OPTIONS, PUBLISH_OPTIONS };

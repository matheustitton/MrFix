const QUEUES = {
  SERVICE_REQUEST_CREATED: 'service_request.created',
  SERVICE_REQUEST_ACCEPTED: 'service_request.accepted',
  SERVICE_REQUEST_STATUS_CHANGED: 'service_request.status_changed',
  SERVICE_REQUEST_COMPLETED: 'service_request.completed',
};

const QUEUE_OPTIONS = { durable: true };

const PUBLISH_OPTIONS = {
  persistent: true,
  contentType: 'application/json',
};

module.exports = { QUEUES, QUEUE_OPTIONS, PUBLISH_OPTIONS };
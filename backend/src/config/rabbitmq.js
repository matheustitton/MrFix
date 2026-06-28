const amqp = require('amqplib');
const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://guest:guest@127.0.0.1:5672';
const RECONNECT_DELAY = parseInt(process.env.RABBITMQ_RECONNECT_DELAY_MS) || 5000;

let connection = null;
let channel = null;
let isConnecting = false;

/**
 * Retorna o canal ativo. Se não existir, cria a conexão.
 * Usado por producers e consumers para obter o canal de forma centralizada.
 */
const getChannel = async () => {
  if (channel) return channel;
  await connect();
  return channel;
};

/**
 * Estabelece conexão e cria o canal principal.
 * Registra handlers para reconexão automática em caso de erro ou fechamento.
 */
const connect = async () => {
  if (isConnecting) return;
  isConnecting = true;

  try {
    console.log('[RabbitMQ] Conectando em', RABBITMQ_URL);
    connection = await amqp.connect({
      protocol: 'amqp',
      hostname: '127.0.0.1',
      port: 5672,
      username: 'guest',
      password: 'guest',
      vhost: '/',
    });
    channel = await connection.createChannel();

    // Prefetch 1: o consumer processa uma mensagem por vez
    await channel.prefetch(1);

    console.log('[RabbitMQ] ✅ Conexão estabelecida.');
    isConnecting = false;

    // Reconecta se a conexão cair inesperadamente
    connection.on('error', (err) => {
      console.error('[RabbitMQ] Erro na conexão:', err.message);
      scheduleReconnect();
    });

    connection.on('close', () => {
      console.warn('[RabbitMQ] Conexão encerrada. Reconectando...');
      channel = null;
      connection = null;
      scheduleReconnect();
    });
  } catch (err) {
    isConnecting = false;
    console.error('[RabbitMQ] ❌ Falha ao conectar:', err.message);
    scheduleReconnect();
  }
};

const scheduleReconnect = () => {
  console.log(`[RabbitMQ] Tentando reconectar em ${RECONNECT_DELAY}ms...`);
  setTimeout(connect, RECONNECT_DELAY);
};

/**
 * Fecha a conexão graciosamente.
 * Chamado no shutdown do servidor para não deixar conexões abertas.
 */
const disconnect = async () => {
  try {
    if (channel) await channel.close();
    if (connection) await connection.close();
    channel = null;
    connection = null;
    console.log('[RabbitMQ] Conexão encerrada graciosamente.');
  } catch (err) {
    console.error('[RabbitMQ] Erro ao encerrar conexão:', err.message);
  }
};

module.exports = { connect, getChannel, disconnect };

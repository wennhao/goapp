import express from 'express';
import cors from 'cors';
import mqtt from 'mqtt';
import { WebSocketServer } from 'ws';
import { createServer } from 'http';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Create HTTP server
const server = createServer(app);

// WebSocket server for real-time updates to clients
const wss = new WebSocketServer({ server });

// MQTT Configuration
const MQTT_BROKER = process.env.MQTT_BROKER || 'mqtt://broker.hivemq.com';
const MQTT_TOPIC = process.env.MQTT_TOPIC || 'goapp/messages';

// Connect to MQTT broker
const mqttClient = mqtt.connect(MQTT_BROKER);

mqttClient.on('connect', () => {
  console.log('✓ Connected to MQTT broker:', MQTT_BROKER);
  mqttClient.subscribe(MQTT_TOPIC, (err) => {
    if (!err) {
      console.log('✓ Subscribed to topic:', MQTT_TOPIC);
    } else {
      console.error('✗ Subscription error:', err);
    }
  });
});

mqttClient.on('error', (error) => {
  console.error('MQTT Error:', error);
});

// Handle incoming MQTT messages
mqttClient.on('message', (topic, message) => {
  const payload = message.toString();
  console.log(`Received MQTT message on ${topic}:`, payload);
  
  // Broadcast to all connected WebSocket clients
  wss.clients.forEach((client) => {
    if (client.readyState === 1) { // WebSocket.OPEN
      client.send(JSON.stringify({
        type: 'mqtt-message',
        topic,
        payload
      }));
    }
  });
});

// WebSocket connection handling
wss.on('connection', (ws) => {
  console.log('New WebSocket client connected');
  
  ws.on('message', (message) => {
    console.log('Received from WebSocket client:', message.toString());
  });
  
  ws.on('close', () => {
    console.log('WebSocket client disconnected');
  });
  
  // Send welcome message
  ws.send(JSON.stringify({ type: 'connected', message: 'Connected to server' }));
});

// REST API Endpoints

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok',
    mqtt: mqttClient.connected ? 'connected' : 'disconnected'
  });
});

// Publish MQTT message
app.post('/api/mqtt/publish', (req, res) => {
  const { topic, message } = req.body;
  
  if (!topic || !message) {
    return res.status(400).json({ error: 'Topic and message are required' });
  }
  
  mqttClient.publish(topic, message, (err) => {
    if (err) {
      console.error('Publish error:', err);
      return res.status(500).json({ error: 'Failed to publish message' });
    }
    
    console.log(`Published to ${topic}:`, message);
    res.json({ success: true, topic, message });
  });
});

// Handle button actions
app.post('/api/action/melden', (req, res) => {
  const message = JSON.stringify({
    action: 'melden',
    timestamp: new Date().toISOString(),
    data: req.body
  });
  
  mqttClient.publish(MQTT_TOPIC, message, (err) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to send message' });
    }
    res.json({ success: true, action: 'melden' });
  });
});

app.post('/api/action/compass', (req, res) => {
  const message = JSON.stringify({
    action: 'compass',
    timestamp: new Date().toISOString(),
    data: req.body
  });
  
  mqttClient.publish(MQTT_TOPIC, message, (err) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to send message' });
    }
    res.json({ success: true, action: 'compass' });
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`✓ Server running on http://localhost:${PORT}`);
});

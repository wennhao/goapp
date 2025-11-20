import express from 'express';
import cors from 'cors';
import mqtt from 'mqtt';
import { WebSocketServer } from 'ws';
import { createServer } from 'http';
import dotenv from 'dotenv';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Create uploads directory if it doesn't exist
const uploadsDir = './uploads';
if (!fs.existsSync(uploadsDir)){
    fs.mkdirSync(uploadsDir);
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads')); // Serve uploaded files

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
app.post('/api/action/melden', upload.single('photo'), (req, res) => {
  const data = {
    ...req.body
  };
  
  // Add photo URL if file was uploaded
  if (req.file) {
    data.photoUrl = `/uploads/${req.file.filename}`;
    data.photoFilename = req.file.filename;
  }
  
  const message = JSON.stringify({
    action: 'melden',
    timestamp: new Date().toISOString(),
    data: data
  });
  
  mqttClient.publish(MQTT_TOPIC, message, (err) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to send message' });
    }
    res.json({ success: true, action: 'melden', photoUrl: data.photoUrl });
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
server.listen(PORT, '0.0.0.0', () => {
  console.log(`✓ Server running on http://0.0.0.0:${PORT}`);
  console.log(`✓ Server accessible at http://localhost:${PORT}`);
  console.log(`✓ Also accessible via network IP (check ipconfig/ifconfig)`);
});

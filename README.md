# GoApp - PWA with MQTT Communication

Een app voor geen ongevallen!

A Progressive Web App (PWA) built with React and Node.js backend featuring real-time MQTT communication.

## Project Structure

```
goapp/
├── frontend/          # React PWA application (mobiele app)
│   ├── src/
│   │   ├── App.jsx
│   │   ├── App.css
│   │   ├── main.jsx
│   │   └── index.css
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
├── dashboard/         # React Dashboard (real-time monitoring)
│   ├── src/
│   │   ├── App.jsx
│   │   ├── App.css
│   │   ├── main.jsx
│   │   └── index.css
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
└── backend/           # Node.js Express server met MQTT
    ├── server.js
    ├── .env.example
    └── package.json
```

## Features

- ✅ PWA met offline support
- ✅ Twee knoppen: **Melden** en **Compass**
- ✅ **Real-time Dashboard** - zie meldingen direct verschijnen
- ✅ MQTT communicatie via Node.js backend
- ✅ WebSocket voor real-time updates tussen apparaten
- ✅ Responsive design voor mobiel en desktop
- ✅ Docker ondersteuning voor eenvoudige deployment

## Tech Stack

### Frontend
- **React** - UI framework
- **Vite** - Build tool
- **Vite PWA Plugin** - PWA functionality

### Backend
- **Node.js + Express** - Web server
- **mqtt.js** - MQTT client
- **WebSocket (ws)** - Real-time communication

## Getting Started

### Prerequisites
- **Option 1 (Docker - aanbevolen):** Docker Desktop
- **Option 2 (Development):** Node.js (v18 or higher) + npm

### Installation met Docker

**Start alles in één keer:**
```powershell
docker-compose up -d
```

**Toegang tot de applicaties:**
- 📱 **App**: http://localhost:6789
- 📊 **Dashboard**: http://localhost:6790
- 🔧 **Backend API**: http://localhost:3001

**Test het:**
1. Open de app op http://localhost:6789
2. Open het dashboard op http://localhost:6790 (op een ander apparaat of tabblad)
3. Klik op "Melden" of "Compass" in de app
4. Zie de melding direct verschijnen op het dashboard! 🎯

### Installation zonder Docker (Development)

1. **Install frontend dependencies:**
```powershell
cd frontend
npm install
```

2. **Install dashboard dependencies:**
```powershell
cd dashboard
npm install
```

3. **Install backend dependencies:**
```powershell
cd backend
npm install
```

4. **Configure backend environment:**
```powershell
cd backend
cp .env.example .env
```

Edit `.env` to configure your MQTT broker (default uses public HiveMQ broker).

### Running the Application

#### Option 1: Docker (Gemakkelijkste manier!)

**Alles starten met één commando:**
```powershell
docker-compose up
```

De app draait nu op http://localhost

**Stoppen:**
```powershell
docker-compose down
```

**Rebuild na wijzigingen:**
```powershell
docker-compose up --build
```

#### Option 2: Development mode (voor development)

1. **Start the backend server:**
```powershell
cd backend
npm run dev
```
The backend will run on http://localhost:3001

2. **Start the frontend (in a new terminal):**
```powershell
cd frontend
npm run dev
```
The frontend will run on http://localhost:3000

3. **Start the dashboard (in a new terminal):**
```powershell
cd dashboard
npm run dev
```
The dashboard will run on http://localhost:3002

### Building for Production

**Frontend:**
```powershell
cd frontend
npm run build
```

The build output will be in `frontend/dist/`

## Hoe werkt het?

### Communicatie Flow
1. **App** (mobiel/tablet) → Gebruiker klikt "Melden" of "Compass"
2. **Backend** → Ontvangt actie en publiceert via MQTT
3. **Dashboard** → Luistert via WebSocket en toont melding real-time

### Twee Apparaten Setup
- **Apparaat 1 (mobiel)**: Open http://localhost:6789 - De app
- **Apparaat 2 (desktop)**: Open http://localhost:6790 - Het dashboard
- Klik op een knop in de app → Zie het direct op het dashboard! ✨

## MQTT Configuration

The backend connects to an MQTT broker (default: `mqtt://broker.hivemq.com`).

Configure in `backend/.env`:
- `MQTT_BROKER` - MQTT broker URL
- `MQTT_TOPIC` - Default topic for messages
- `PORT` - Backend server port

## API Endpoints

- `GET /api/health` - Health check
- `POST /api/action/melden` - Trigger Melden action
- `POST /api/action/compass` - Trigger Compass action
- `POST /api/mqtt/publish` - Publish custom MQTT message

## Next Steps

- ✅ WebSocket verbinding voor real-time updates
- ✅ Dashboard voor monitoring
- ✅ Twee apparaten communicatie
- 🔲 Geluid/notificaties op dashboard bij nieuwe meldingen
- 🔲 GPS locatie toevoegen aan meldingen
- 🔲 Authenticatie voor beveiligde toegang
- 🔲 Eigen MQTT broker opzetten
- 🔲 PWA icons aanpassen

## License

MIT

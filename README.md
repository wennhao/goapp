# Geen Ongevallen! APP

App voor veiligheidsmeldingen met real-time dashboard.

## Architectuur

```
┌─────────────────────────────────────────────┐
│  Server (1x)                                │
│  ├── Backend (MQTT + API) - Port 3001      │
│  └── Dashboard - Port 6790                  │
└─────────────────────────────────────────────┘
              ↕ MQTT + WebSocket
┌─────────────────────────────────────────────┐
│  Clients (meerdere apparaten)               │
│  └── Frontend PWA - Port 6789               │
└─────────────────────────────────────────────┘
```

**Hoe werkt het?**
1. Spelers kunnen situaties melden
2. Frontend stuurt HTTP POST naar Backend
3. Backend publiceert MQTT message naar `goapp/messages` topic
4. Backend broadcast via WebSocket naar Dashboard
5. Dashboard toont melding real-time + opslaat in localStorage

**Message Format:**
```json
{
  "action": "melden",
  "timestamp": "2025-11-20T10:00:00.000Z",
  "data": {
    "situatie": "Onveilige situatie",
    "naam": "Jan",
    "projectnaam": "Escape Room",
    "omschrijving": "...",
    "photoUrl": "/uploads/photo.jpg",
    "device": "mobile-app"
  }
}
```

## Snelstart

### Docker (Aanbevolen)

1. **Vind je server IP** (Windows PowerShell):
```powershell
ipconfig
# Zoek "IPv4 Address" bijv. 192.168.1.67
```

2. **Configureer .env** (in root folder):
```bash
# Kopieer .env.example naar .env
cp .env.example .env

# Bewerk .env met je server IP:
BACKEND_URL=http://[server-ip]:3001
BACKEND_WS_URL=ws://[server-ip]:3001
```

3. **Start containers**:
```bash
docker compose up -d --build
```

4. **Open apps**:
- Frontend: `http://[server-ip]:6789` (op telefoon/tablet)
- Dashboard: `http://[server-ip]:6790` (op server)

### Development Mode (npm)

**Backend:**
```bash
cd backend
npm install
npm run dev
```

**Dashboard:**
```bash
cd dashboard
npm install
# Maak dashboard/.env: VITE_BACKEND_WS_URL=ws://[server-ip]:3001
npm run dev
```

**Frontend:**
```bash
cd frontend
npm install
# Maak frontend/.env: VITE_BACKEND_URL=http://[server-ip]:3001
npm run dev
```

## Project Structuur

```
goapp/
├── frontend/          # React App
├── dashboard/         # React Dashboard
├── backend/          # Node.js + Express + MQTT
│   └── uploads/      # Foto uploads
├── docker-compose.yml
├── .env              # Docker environment vars
└── README.md
```

## Features

- 📱 **Touch-optimized PWA** with smooth scrolling for touchscreens
- ⌨️ **Virtual keyboard support** for Raspberry Pi touchscreen kiosks
- 🔄 **Real-time dashboard** with persistent messages
- 📡 **MQTT communication** via HiveMQ broker
- 🌐 **WebSocket** for live updates
- 📸 **Photo upload** with camera support
- 🔌 **Offline support** via service worker
- 📱 **Multi-device support** (multiple clients)
- 🐳 **Docker deployment** with volume mounts
- 📐 **Responsive design** (2 cols mobile, 4 cols desktop)

### 🆕 Touch & Keyboard Enhancements

**For Raspberry Pi 5 with touchscreen:**
- Smooth momentum scrolling with swipe gestures
- Auto-showing virtual keyboard on input focus
- Optimized touch interactions and gestures
- Kiosk mode support with auto-launch
- See `RASPBERRY_PI_SETUP.md` for full setup guide

**Quick Setup on Raspberry Pi:**
```bash
chmod +x setup-rpi.sh
./setup-rpi.sh
```

**View Quick Reference:**
```bash
chmod +x QUICKSTART.sh
./QUICKSTART.sh
```

## Tech Stack

**Frontend:** React 18 + Vite + PWA Plugin  
**Dashboard:** React 18 + WebSocket  
**Backend:** Node.js + Express + MQTT.js + Multer + WebSocket  
**Deployment:** Docker + Docker Compose  
**MQTT Broker:** HiveMQ (public: `mqtt://broker.hivemq.com`)

## Buttons Aanpassen

Buttons toevoegen of verwijderen is eenvoudig. Bewerk `frontend/src/data/buttons.js`:

```javascript
export const buttons = [
  {
    id: 'melden',
    label: 'Melden',
    icon: '/buttonicons/icon_melden.png',
    hasAction: true,
    backgroundColor: '#e6ecf8',  // Optioneel
    textColor: '#333'             // Optioneel
  },
  {
    id: 'instructies',
    label: 'Instructies',
    icon: '/buttonicons/icon_instructies.png',
    hasAction: false
  }
  // Voeg meer buttons toe of verwijder regels...
];
```

**Stappen:**
1. Voeg een button object toe aan de array of verwijder een bestaande
2. Plaats het icoon in `frontend/public/buttonicons/`
3. `hasAction: true` = button opent een pagina (zoals Melden met formulier)
4. `hasAction: false` = button heeft (nog) geen functionaliteit
5. Rebuild: `docker compose up -d --build frontend`

**Voorbeeld nieuwe button toevoegen:**
```javascript
{ id: 'noodknop', label: 'Noodknop', icon: '/buttonicons/icon_nood.png', hasAction: true }
```

## Troubleshooting

**Kan niet verbinden vanaf ander apparaat:**
- Check firewall: sta poorten 3001, 6789, 6790 toe
- Controleer `.env` heeft correcte server IP (niet localhost)
- Zelfde WiFi netwerk?

**Dashboard toont geen messages:**
- Check browser console voor WebSocket errors
- Controleer backend logs: `docker logs goapp-backend`
- Clear localStorage: Dev Tools → Application → Local Storage

**Foto upload werkt niet:**
- Controleer backend logs voor Multer errors
- Check uploads volume: `docker exec goapp-backend ls /app/uploads`
- Max bestandsgrootte: 10MB

## Environment Variables

| Variable | Locatie | Beschrijving |
|----------|---------|--------------|
| `BACKEND_URL` | `.env` (root) | Backend URL voor frontend (Docker) |
| `BACKEND_WS_URL` | `.env` (root) | WebSocket URL voor dashboard (Docker) |
| `VITE_BACKEND_URL` | `frontend/.env` | Backend URL (development) |
| `VITE_BACKEND_WS_URL` | `dashboard/.env` | WebSocket URL (development) |
| `MQTT_BROKER` | Backend | MQTT broker URL |
| `MQTT_TOPIC` | Backend | MQTT topic naam |

**Docker:** Gebruik alleen `.env` in root folder  
**Development:** Maak `.env` files in `frontend/` en `dashboard/` folders

## Docker Commando's

```bash
# Start alles
docker compose up -d --build

# Stop alles
docker compose down

# Rebuild 1 service
docker compose up -d --build frontend

# Logs bekijken
docker logs goapp-backend -f
docker logs goapp-dashboard -f
docker logs goapp-frontend -f

# Restart
docker compose restart
```

## IP Adres Vinden

**Windows (PowerShell):**
```powershell
ipconfig
# Zoek "IPv4 Address" onder je WiFi adapter
```

**macOS/Linux:**
```bash
ifconfig
# Of: ip addr show
```

## 📱 Touch & Raspberry Pi Support

This app is optimized for **Raspberry Pi 5 touchscreen kiosks**. 

### Touch Features:
- ✅ Smooth swipe scrolling (up/down)
- ✅ Auto-showing virtual keyboard on input focus
- ✅ Optimized touch gestures
- ✅ Pinch-to-zoom support (up to 5x)
- ✅ Kiosk mode with auto-launch

### Setup on Raspberry Pi:
```bash
# Run the automated setup script
chmod +x setup-rpi.sh
./setup-rpi.sh

# Or view quick reference
chmod +x QUICKSTART.sh
./QUICKSTART.sh
```

### Documentation:
- **`RASPBERRY_PI_SETUP.md`** - Complete setup guide
- **`TOUCH_ENHANCEMENTS.md`** - Technical details
- **`QUICKSTART.sh`** - Quick reference commands

### Browser Launch (Kiosk Mode):
```bash
chromium-browser --kiosk --app=http://localhost:6789 \
  --touch-events=enabled --disable-pinch
```

---

**Gemaakt voor veilige werkplekken** 🏗️

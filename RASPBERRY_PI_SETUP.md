# Raspberry Pi 5 Touchscreen Kiosk Setup

## 📁 Organized Documentation

All Raspberry Pi setup files and documentation have been organized into the `raspberry-pi/` folder.

**→ [Go to Raspberry Pi Documentation](raspberry-pi/INDEX.md)**

## Quick Links

- **[Setup Guide](raspberry-pi/README.md)** - Complete step-by-step setup
- **[Quick Start](raspberry-pi/QUICKSTART.md)** - Commands and quick reference
- **[Summary](raspberry-pi/SUMMARY.md)** - Overview of what you're getting
- **[Checklist](raspberry-pi/CHECKLIST.md)** - Validation checklist
- **[Architecture](raspberry-pi/ARCHITECTURE.md)** - Technical documentation
- **[Configuration](raspberry-pi/CONFIGURATION.md)** - Advanced settings
- **[Visual Guide](raspberry-pi/VISUAL_GUIDE.md)** - Visual diagrams

## 🚀 Super Quick Setup

```bash
# On your Raspberry Pi:
cd ~/goapp/raspberry-pi
chmod +x setup.sh
./setup.sh

# Enable auto-login
sudo raspi-config
# System Options → Boot / Auto Login → Desktop Autologin

# Configure backend
cd ~/goapp
nano .env
# Set: BACKEND_URL=http://YOUR-BACKEND-IP:3001

# Start and reboot
docker-compose up -d frontend
sudo reboot
```

Done! Your kiosk will start automatically.

---

**For detailed instructions, see [raspberry-pi/README.md](raspberry-pi/README.md)**

---

# Original Detailed Guide (Reference)

Deze handleiding helpt je om de GoApp frontend in kiosk mode te draaien op een Raspberry Pi 5 met touchscreen.

## Vereisten

- Raspberry Pi 5
- Touchscreen (officiële Raspberry Pi touchscreen of compatibel)
- Raspberry Pi OS (64-bit) geïnstalleerd
- Internetverbinding

## Stap 1: Raspberry Pi OS Configuratie

### 1.1 Installeer benodigde software

```bash
# Update systeem
sudo apt update
sudo apt upgrade -y

# Installeer Docker en Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installeer Docker Compose
sudo apt install -y docker-compose

# Installeer Chromium en unclutter (verbergt cursor)
sudo apt install -y chromium-browser unclutter xdotool

# Installeer on-screen keyboard
sudo apt install -y matchbox-keyboard
```

### 1.2 Enable auto-login

```bash
sudo raspi-config
```

Navigeer naar: `System Options` → `Boot / Auto Login` → `Desktop Autologin`

## Stap 2: Touchscreen Kalibratie & Optimalisatie

### 2.1 Test touchscreen

```bash
# Test of touchscreen werkt
sudo apt install -y xinput evtest
xinput list
```

### 2.2 Enable virtual keyboard (optioneel, als matchbox niet voldoet)

Matchbox keyboard is al geïnstalleerd. Voor een modernere optie:

```bash
# Onboard - moderne on-screen keyboard
sudo apt install -y onboard
```

## Stap 3: Project Setup op Raspberry Pi

### 3.1 Clone/kopieer project

```bash
cd ~
# Als je git gebruikt:
git clone https://github.com/jouw-username/goapp.git
# OF kopieer bestanden via USB/netwerk naar ~/goapp

cd ~/goapp
```

### 3.2 Configureer backend URL

Maak een `.env` bestand aan:

```bash
nano .env
```

Voeg toe (vervang IP met het IP van je backend server):

```
BACKEND_URL=http://192.168.1.67:3001
BACKEND_WS_URL=ws://192.168.1.67:3001
```

### 3.3 Start Docker containers

```bash
# Als alleen frontend op Pi draait en backend elders:
docker-compose up -d frontend

# OF als alles op de Pi draait:
docker-compose up -d
```

## Stap 4: Kiosk Mode Setup

### 4.1 Maak autostart directory

```bash
mkdir -p ~/.config/autostart
mkdir -p ~/.config/lxsession/LXDE-pi
```

### 4.2 Configureer LXDE autostart

```bash
nano ~/.config/lxsession/LXDE-pi/autostart
```

Voeg toe:

```
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash

# Verberg cursor na inactiviteit
@unclutter -idle 0.1 -root

# Disable screensaver en power management
@xset s off
@xset -dpms
@xset s noblank

# Start on-screen keyboard (matchbox)
@matchbox-keyboard -d

# Start Chromium in kiosk mode
@chromium-browser --kiosk --noerrdialogs --disable-infobars --no-first-run --enable-features=OverlayScrollbar --check-for-update-interval=31536000 --app=http://localhost:6789
```

### 4.3 Chromium Kiosk Script (Alternative, meer controle)

Maak een kiosk script:

```bash
nano ~/kiosk.sh
```

Voeg toe:

```bash
#!/bin/bash

# Disable screensaver
xset s off
xset -dpms
xset s noblank

# Verberg cursor
unclutter -idle 0.1 -root &

# Start on-screen keyboard
matchbox-keyboard -d &

# Wacht tot Docker container draait
sleep 10

# Start Chromium in kiosk mode
chromium-browser \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  --no-first-run \
  --check-for-update-interval=31536000 \
  --disable-translate \
  --disable-features=TranslateUI \
  --disk-cache-dir=/dev/null \
  --overscroll-history-navigation=0 \
  --disable-pinch \
  --enable-features=OverlayScrollbar \
  --touch-events=enabled \
  --disable-session-crashed-bubble \
  --disable-features=IsolateOrigins,site-per-process \
  http://localhost:6789
```

Maak executable:

```bash
chmod +x ~/kiosk.sh
```

Update autostart:

```bash
nano ~/.config/lxsession/LXDE-pi/autostart
```

Vervang de chromium regel met:

```
@/home/pi/kiosk.sh
```

## Stap 5: Touch & Keyboard Optimalisatie

### 5.1 Matchbox Keyboard configuratie

De keyboard verschijnt automatisch bij focus op input velden. Om de grootte aan te passen:

```bash
nano ~/.matchbox/keyboard.xml
```

Of gebruik Onboard voor betere touch integratie:

```bash
# In autostart, vervang matchbox met:
@onboard
```

### 5.2 CSS aanpassingen voor touch

Zorg dat je frontend touch-friendly is. Voeg toe aan je CSS:

```css
* {
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  user-select: none;
  touch-action: manipulation;
}

input, textarea {
  -webkit-user-select: text;
  user-select: text;
  font-size: 16px; /* Voorkomt zoom op iOS/mobile */
}

/* Grotere touch targets */
button, a, input {
  min-height: 44px;
  min-width: 44px;
}
```

### 5.3 Auto-show keyboard bij input focus

Voor matchbox keyboard:

```bash
# Maak helper script
nano ~/show-keyboard.sh
```

```bash
#!/bin/bash
export DISPLAY=:0
matchbox-keyboard &
```

## Stap 6: Docker Auto-start bij boot

```bash
# Enable Docker service
sudo systemctl enable docker

# Zorg dat containers automatisch starten
# Dit is al ingesteld met "restart: unless-stopped" in docker-compose.yml
```

## Stap 7: Prevent Closing/Navigation

De `--kiosk` flag voorkomt al het sluiten, maar voor extra zekerheid:

### 7.1 Disable Alt+F4 en andere shortcuts

```bash
nano ~/.config/openbox/lxde-pi-rc.xml
```

Zoek de `<keyboard>` sectie en voeg toe:

```xml
<keybind key="A-F4">
  <action name="Execute">
    <command>true</command>
  </action>
</keybind>
```

### 7.2 Full-screen lock script

```bash
nano ~/keep-fullscreen.sh
```

```bash
#!/bin/bash
while true; do
    sleep 2
    wmctrl -r "Chromium" -b add,fullscreen
done
```

```bash
chmod +x ~/keep-fullscreen.sh
```

Voeg toe aan autostart:

```
@/home/pi/keep-fullscreen.sh
```

## Stap 8: Testing & Troubleshooting

### Test setup:

1. **Reboot**:
   ```bash
   sudo reboot
   ```

2. **Check Docker**:
   ```bash
   docker ps
   ```

3. **Check logs**:
   ```bash
   docker logs goapp-frontend
   ```

### Troubleshooting:

**Touchscreen werkt niet:**
```bash
xinput list
# Zoek je touchscreen en enable:
xinput enable <device-id>
```

**Keyboard verschijnt niet:**
```bash
# Test matchbox manually:
matchbox-keyboard
# Of switch naar onboard:
onboard
```

**App laadt niet:**
```bash
# Check of container draait:
docker ps
# Check netwerk:
curl http://localhost:6789
# Check backend connectie:
curl http://192.168.1.67:3001/health
```

**Chromium crasht:**
```bash
# Verwijder cache:
rm -rf ~/.cache/chromium
rm -rf ~/.config/chromium
```

## Stap 9: Production Tips

### 9.1 Watchdog voor auto-restart

```bash
sudo apt install -y watchdog
```

### 9.2 Monitor script

```bash
nano ~/monitor-app.sh
```

```bash
#!/bin/bash
while true; do
    if ! pgrep -f "chromium-browser" > /dev/null; then
        ~/kiosk.sh &
    fi
    sleep 30
done
```

### 9.3 Scheduled reboot (optioneel)

```bash
sudo crontab -e
```

Voeg toe voor dagelijkse reboot om 4:00:

```
0 4 * * * /sbin/shutdown -r now
```

## Stap 10: Remote Management (optioneel)

### SSH toegang behouden

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

### VNC voor remote desktop

```bash
sudo raspi-config
# Interface Options → VNC → Enable
```

## Samenvatting Kiosk Features

✅ **Auto-start bij boot** - Chromium opent automatisch  
✅ **Touch support** - Volledige touchscreen ondersteuning  
✅ **On-screen keyboard** - Verschijnt bij input velden  
✅ **No closing** - Kiosk mode voorkomt sluiten  
✅ **No navigation** - Geen URL bar of browser controls  
✅ **Touch scrolling** - Native swipe ondersteuning  
✅ **Full screen** - Geen desktop zichtbaar  

## Quick Start Checklist

- [ ] Raspberry Pi OS geïnstalleerd
- [ ] Auto-login enabled
- [ ] Docker & Docker Compose geïnstalleerd
- [ ] Project gekopieerd naar ~/goapp
- [ ] .env bestand geconfigureerd
- [ ] Docker containers draaien
- [ ] Matchbox keyboard geïnstalleerd
- [ ] Autostart geconfigureerd
- [ ] Kiosk script executable gemaakt
- [ ] Systeem gereboot en getest

## Support

Bij problemen, check:
1. `docker ps` - Draaien containers?
2. `docker logs goapp-frontend` - Errors in frontend?
3. `sudo systemctl status docker` - Draait Docker service?
4. Test in normale browser: `http://localhost:6789`

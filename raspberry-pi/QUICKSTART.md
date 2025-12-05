# Raspberry Pi Kiosk Mode - Quick Reference

## One-Time Setup

### 1. Install Prerequisites
```bash
cd ~/goapp/raspberry-pi
chmod +x setup.sh
./setup.sh
```

### 2. Configure Auto-Login
```bash
sudo raspi-config
```
Navigate to: **System Options** → **Boot / Auto Login** → **Desktop Autologin**

### 3. Setup GoApp
```bash
# Copy project to home directory
cd ~
# ... copy your goapp folder here ...

# Configure backend URL
cd ~/goapp
cp raspberry-pi/.env.example .env
nano .env  # Edit backend URL

# Start containers
docker-compose up -d frontend
```

### 4. Reboot
```bash
sudo reboot
```

## Manual Testing

### Test Frontend
```bash
# Check if container is running
docker ps

# Test in browser
chromium-browser http://localhost:6789
```

### Test Touchscreen
```bash
# List input devices
xinput list

# Test touch events
xinput test <device-id>
```

### Test On-Screen Keyboard
```bash
# Matchbox keyboard
matchbox-keyboard

# Or Onboard
onboard
```

## Troubleshooting

### Container not starting
```bash
docker logs goapp-frontend
docker-compose down
docker-compose up -d
```

### Chromium crashes on boot
```bash
# Clear cache
rm -rf ~/.cache/chromium
rm -rf ~/.config/chromium

# Restart kiosk
~/kiosk.sh
```

### Touchscreen not responding
```bash
# List devices
xinput list

# Enable device if disabled
xinput enable <device-id>
```

### Keyboard doesn't appear
```bash
# Kill existing instance
pkill matchbox-keyboard

# Restart
matchbox-keyboard -d &
```

## Useful Commands

```bash
# Restart frontend container
docker restart goapp-frontend

# View frontend logs
docker logs -f goapp-frontend

# Stop kiosk mode
pkill chromium-browser

# Restart kiosk mode
~/kiosk.sh &

# Check autostart configuration
cat ~/.config/lxsession/LXDE-pi/autostart
```

## Remote Access

### SSH
```bash
# From another computer
ssh pi@<raspberry-pi-ip>
```

### VNC
```bash
# Enable in raspi-config
sudo raspi-config
# Interface Options → VNC → Enable
```

## Tips

- **Performance**: Close unnecessary apps, use lite Raspberry Pi OS
- **Touch calibration**: If touch is off, run `xinput_calibrator`
- **Screen rotation**: Add `display_rotate=1` to `/boot/config.txt` for 90°
- **Prevent screen blanking**: Already configured in kiosk.sh
- **Update app**: `docker-compose pull && docker-compose up -d`

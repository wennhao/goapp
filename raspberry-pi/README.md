# Raspberry Pi Kiosk Mode Files

This folder contains everything needed to run your GoApp frontend on a Raspberry Pi 5 with touchscreen in kiosk mode.

## 📁 Files Overview

| File | Description |
|------|-------------|
| `setup.sh` | Automated setup script - installs all dependencies |
| `kiosk.sh` | Kiosk launcher script - starts Chromium in kiosk mode |
| `autostart` | LXDE autostart configuration |
| `monitor.sh` | Monitors and restarts Chromium if it crashes |
| `goapp-kiosk.service` | Systemd service file (alternative to autostart) |
| `install-service.sh` | Installs the systemd service |
| `.env.example` | Environment configuration template |
| `QUICKSTART.md` | Quick reference guide |
| `CONFIGURATION.md` | Advanced configuration and optimization tips |

## 🚀 Quick Setup (3 Steps)

### 1️⃣ Run Setup Script on Raspberry Pi

```bash
# Copy this entire raspberry-pi folder to your Raspberry Pi
cd ~/goapp/raspberry-pi

# Make setup script executable and run it
chmod +x setup.sh
./setup.sh
```

### 2️⃣ Configure Backend URL

```bash
# Go to your goapp directory
cd ~/goapp

# Create .env file
cp raspberry-pi/.env.example .env

# Edit with your backend server IP
nano .env
# Change: BACKEND_URL=http://YOUR-SERVER-IP:3001
```

### 3️⃣ Enable Auto-Login and Reboot

```bash
# Enable auto-login
sudo raspi-config
# Navigate: System Options → Boot / Auto Login → Desktop Autologin

# Start Docker containers
docker-compose up -d frontend

# Reboot
sudo reboot
```

## ✅ What This Setup Provides

✅ **Auto-start on boot** - Opens frontend automatically when Pi boots  
✅ **Touch screen support** - Full touch and swipe functionality  
✅ **On-screen keyboard** - Appears automatically when focusing input fields  
✅ **Kiosk mode** - No way to close the app or access browser controls  
✅ **No accidental exits** - Disabled keyboard shortcuts and window controls  
✅ **Touch scrolling** - Smooth swipe up/down scrolling  
✅ **Optimized UI** - Touch-friendly button sizes and input fields  
✅ **Auto-restart** - Chromium restarts if it crashes  

## 🎯 Two Installation Methods

### Method A: Autostart (Recommended - Simple)

This method uses LXDE's autostart feature:

```bash
# Already done by setup.sh
# Files are in ~/.config/lxsession/LXDE-pi/autostart
```

**Pros:** Simple, works immediately  
**Cons:** Less control over service management

### Method B: Systemd Service (Advanced)

This method uses a systemd service for better control:

```bash
cd ~/goapp/raspberry-pi
chmod +x install-service.sh
./install-service.sh
```

**Pros:** Better logging, easier to start/stop/restart  
**Cons:** Slightly more complex

## 🔧 Common Tasks

### View Logs (if using systemd service)
```bash
sudo journalctl -u goapp-kiosk -f
```

### Restart Kiosk
```bash
# Method A (autostart): Kill and it restarts automatically
pkill chromium-browser

# Method B (systemd):
sudo systemctl restart goapp-kiosk
```

### Stop Kiosk
```bash
# Method A (autostart):
pkill chromium-browser
# Remove from autostart to prevent restart on reboot

# Method B (systemd):
sudo systemctl stop goapp-kiosk
```

### Update Frontend
```bash
cd ~/goapp
docker-compose pull frontend
docker-compose up -d frontend
# Chromium will reload automatically
```

## 🎮 Using the Touchscreen

### Scroll
- Swipe up/down anywhere on the page

### Click/Tap
- Tap any button or link

### Text Input
1. Tap an input field
2. On-screen keyboard appears automatically
3. Type your text
4. Tap outside the keyboard to hide it

### Keyboard Options

**Matchbox** (default - lightweight):
- Simple, minimal design
- Lower resource usage
- Auto-shows on input focus

**Onboard** (optional - feature-rich):
- Modern design with predictions
- More customizable
- Slightly higher resource usage

To switch to Onboard, edit `~/kiosk.sh`:
```bash
nano ~/kiosk.sh
# Comment out: matchbox-keyboard -d &
# Uncomment: onboard &
```

## 🐛 Troubleshooting

### Screen is Black After Boot

**Cause:** Docker containers not started or network not ready

**Fix:**
```bash
# SSH into the Pi
ssh pi@<raspberry-pi-ip>

# Check if containers are running
docker ps

# If not running, start them
cd ~/goapp
docker-compose up -d frontend

# Restart kiosk
~/kiosk.sh &
```

### Touch Not Working

**Cause:** Touchscreen driver not loaded or device disabled

**Fix:**
```bash
# List input devices
xinput list

# Find your touchscreen and note the ID
# If disabled, enable it:
xinput enable <device-id>
```

### Keyboard Doesn't Appear

**Cause:** Keyboard process not running

**Fix:**
```bash
# Kill any existing instance
pkill matchbox-keyboard

# Restart it
matchbox-keyboard -d &

# Or if using Onboard:
pkill onboard
onboard &
```

### App Not Loading

**Cause:** Backend not reachable or wrong URL

**Fix:**
```bash
# Test backend connection
curl http://YOUR-BACKEND-IP:3001/health

# Check .env file
cat ~/goapp/.env

# Update if needed
nano ~/goapp/.env

# Rebuild frontend with new URL
cd ~/goapp
docker-compose build frontend
docker-compose up -d frontend
```

### Chromium Keeps Crashing

**Cause:** Corrupted cache or insufficient resources

**Fix:**
```bash
# Clear Chromium cache
rm -rf ~/.cache/chromium
rm -rf ~/.config/chromium

# Increase GPU memory in /boot/config.txt
sudo nano /boot/config.txt
# Add: gpu_mem=256

# Reboot
sudo reboot
```

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick reference commands
- **[CONFIGURATION.md](CONFIGURATION.md)** - Advanced settings and optimization
- **[../RASPBERRY_PI_SETUP.md](../RASPBERRY_PI_SETUP.md)** - Detailed setup guide

## 🔒 Security Notes

For a public-facing kiosk, consider:

1. **Disable SSH** (after setup complete):
   ```bash
   sudo systemctl disable ssh
   ```

2. **Change default password**:
   ```bash
   passwd
   ```

3. **Use firewall** (if needed):
   ```bash
   sudo apt install -y ufw
   sudo ufw enable
   ```

## 🎯 Next Steps

After successful setup:

1. ✅ Test all touchscreen functionality
2. ✅ Verify on-screen keyboard works
3. ✅ Test the complete user flow
4. ✅ Calibrate touchscreen if needed (see CONFIGURATION.md)
5. ✅ Set up monitoring (optional)
6. ✅ Configure backup strategy (optional)

## 💡 Tips

- **Use official Raspberry Pi touchscreen** for best compatibility
- **Keep the Pi cool** - use a fan or heatsink for better performance
- **Use a quality power supply** - 5V 3A minimum for Pi 5
- **Regular updates** - Monthly system and Docker image updates
- **Monitor temperature** - Run `vcgencmd measure_temp` occasionally

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review logs: `docker logs goapp-frontend`
3. Test manually: Open Chromium and visit `http://localhost:6789`
4. Check this project's main README.md

## 🔄 Updates

To update this setup in the future:

```bash
cd ~/goapp
git pull  # If using git
docker-compose pull
docker-compose up -d
```

---

**Made with ❤️ for Raspberry Pi touchscreen kiosks**

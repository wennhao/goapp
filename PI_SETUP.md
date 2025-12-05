# Raspberry Pi Kiosk Setup - SIMPLE GUIDE

## Step 1: Install Everything

```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose

# Install Chromium and tools (updated package names for newer Raspberry Pi OS)
sudo apt install -y chromium unclutter matchbox-keyboard xinput x11-xserver-utils

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Check if Docker is running
sudo systemctl status docker

# Add user to docker group
sudo usermod -aG docker $USER

# IMPORTANT: You must reboot or logout/login for group changes to work
# OR apply immediately with:
newgrp docker
```

## Step 2: Clone/Copy Your Project

```bash
cd ~
# If you have git:
git clone https://github.com/YOUR-USERNAME/goapp.git

# OR copy files from USB/network to ~/goapp
```

## Step 3: Configure Backend URL

```bash
cd ~/goapp
nano .env
```

Add this line (replace with your backend IP):
```
BACKEND_URL=http://192.168.1.67:3001
```

Save: `Ctrl+X`, then `Y`, then `Enter`

## Step 4: Start Containers

```bash
cd ~/goapp
docker compose up -d --build
```

Wait a few minutes for build to complete.

Check if running:
```bash
docker ps
```

## Step 5: Setup Kiosk Auto-Start

```bash
# Copy kiosk script
cp ~/goapp/raspberry-pi/kiosk.sh ~/kiosk.sh
chmod +x ~/kiosk.sh

# Create autostart directory
mkdir -p ~/.config/lxsession/LXDE-pi

# Copy autostart config
cp ~/goapp/raspberry-pi/autostart ~/.config/lxsession/LXDE-pi/autostart
```

## Step 6: Enable Auto-Login

```bash
sudo raspi-config
```

Navigate: **System Options** → **Boot / Auto Login** → **Desktop Autologin**

Press `Esc` to exit.

## Step 7: Reboot

```bash
sudo reboot
```

Your kiosk should start automatically!

---

## Testing Before Reboot

```bash
# Test if frontend is accessible
curl http://localhost:6789

# Test kiosk manually
DISPLAY=:0 ~/kiosk.sh
```

---

## Troubleshooting

**Docker won't start:**
```bash
sudo systemctl status docker
sudo systemctl start docker
```

**Container not running:**
```bash
docker ps
docker logs goapp-frontend
```

**Chromium won't start:**
```bash
which chromium
# If not found, install:
sudo apt install -y chromium
```

**After reboot, nothing happens:**
```bash
# Check if kiosk.sh exists
ls -l ~/kiosk.sh

# Check autostart
cat ~/.config/lxsession/LXDE-pi/autostart

# Run manually to see errors
~/kiosk.sh
```

---

## That's It!

Once rebooted, your Pi will:
- ✅ Boot to desktop automatically
- ✅ Start Docker containers
- ✅ Launch Chromium in fullscreen kiosk mode
- ✅ Load your app at http://localhost:6789
- ✅ Show on-screen keyboard when you tap inputs
- ✅ Support touch scrolling

**Can't close it:** That's the point! It's locked in kiosk mode.

**Need to exit:** Press `Ctrl+Alt+F2`, login, then `pkill chromium-browser`

# Raspberry Pi Setup Guide

This guide will help you deploy the GoApp on a Raspberry Pi with automatic kiosk mode.

## Prerequisites

- Raspberry Pi (3 or newer recommended)
- Raspberry Pi OS (64-bit recommended)
- Internet connection
- Touchscreen (optional, but recommended for touch interaction)

## Quick Start (Automated)

1. Clone this repository to your Raspberry Pi:
```bash
git clone <your-repo-url> ~/goapp
cd ~/goapp
```

2. Make the setup script executable and run it:
```bash
chmod +x setup-raspberry.sh
./setup-raspberry.sh
```

The script will:
- Install Docker and Docker Compose
- Configure the system for kiosk mode
- Build and start the Docker containers
- Launch Chromium in kiosk mode pointing to the frontend
- Set up auto-start on boot

## Manual Setup

If you prefer to set up manually, follow these steps:

### 1. Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 2. Install Docker Compose

```bash
sudo apt-get update
sudo apt-get install -y docker-compose
```

### 3. Build and Start Services

```bash
cd ~/goapp
docker-compose up -d
```

### 4. Install Chromium

```bash
sudo apt-get install -y chromium unclutter
```

### 5. Configure Kiosk Mode

Create autostart file:
```bash
mkdir -p ~/.config/lxsession/LXDE-pi
nano ~/.config/lxsession/LXDE-pi/autostart
```

Add these lines:
```
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@point-blank

@unclutter -idle 0.1 -root
@xset s off
@xset -dpms
@xset s noblank

@chromium --kiosk --incognito --disable-infobars --noerrdialogs --disable-session-crashed-bubble --disable-restore-session-state --start-maximized http://localhost:6789
```

### 6. Disable Screen Blanking

Edit lightdm config:
```bash
sudo nano /etc/lightdm/lightdm.conf
```

Add under `[Seat:*]`:
```
xserver-command=X -s 0 -dpms
```

### 7. Reboot

```bash
sudo reboot
```

## Network Configuration

If you need to access the app from other devices on the network:

1. Find your Raspberry Pi's IP address:
```bash
hostname -I
```

2. Update the `BACKEND_URL` in docker-compose.yml:
```bash
BACKEND_URL=http://<raspberry-pi-ip>:3001
```

3. Restart containers:
```bash
docker-compose down
docker-compose up -d
```

## Touchscreen Support

The app is configured with:
- Touch scrolling and swipe gestures
- Prevention of text/element selection on touch
- Smooth scrolling behavior

## Troubleshooting

### App not loading
- Check if containers are running: `docker ps`
- Check container logs: `docker-compose logs`
- Verify network connectivity

### Kiosk mode not starting
- Check autostart file: `cat ~/.config/lxsession/LXDE-pi/autostart`
- Verify Chromium is installed: `which chromium`
- Check if app is accessible: `curl http://localhost:6789`

### Touch not working
- Ensure touchscreen drivers are installed
- Check `/boot/config.txt` for display configuration
- Test touch with: `evtest`

### Screen blanking
- Verify lightdm.conf settings
- Check xset settings: `xset q`

## Updating the App

```bash
cd ~/goapp
git pull
docker-compose down
docker-compose up -d --build
```

## Stopping the App

```bash
cd ~/goapp
docker-compose down
```

## Accessing Dashboard

The dashboard is available at `http://localhost:6790` (or `http://<raspberry-pi-ip>:6790` from other devices).

## Performance Tips

- Use Raspberry Pi 4 with 4GB+ RAM for best performance
- Enable GPU memory split: `sudo raspi-config` → Performance Options → GPU Memory → Set to 256
- Use a good quality SD card (Class 10 or better)
- Ensure adequate cooling

## Security Notes

- Change default passwords
- Configure firewall if exposing ports to network
- Keep system updated: `sudo apt-get update && sudo apt-get upgrade`

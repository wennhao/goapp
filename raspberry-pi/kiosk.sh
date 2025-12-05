#!/bin/bash
# GoApp Kiosk Mode Launcher for Raspberry Pi
# Place this file in /home/pi/kiosk.sh

echo "Starting GoApp Kiosk Mode..."

# Wait for network to be ready
echo "Waiting for network..."
while ! ping -c 1 -W 1 8.8.8.8 &> /dev/null; do
    sleep 1
done
echo "Network ready!"

# Disable screensaver and power management
echo "Disabling screensaver..."
xset s off
xset -dpms
xset s noblank

# Hide mouse cursor after 0.1 seconds of inactivity
echo "Hiding cursor..."
unclutter -idle 0.1 -root &

# Start on-screen keyboard (matchbox)
# Uncomment ONE of the following based on your preference:

# Option 1: Matchbox (lightweight, simple)
matchbox-keyboard -d &

# Option 2: Onboard (modern, feature-rich) - uncomment if you prefer this
# onboard &

# Wait for Docker containers to be ready
echo "Waiting for Docker containers..."
sleep 10

# Check if frontend container is running
if ! docker ps | grep -q "goapp-frontend"; then
    echo "Warning: Frontend container not running. Starting Docker Compose..."
    cd /home/pi/goapp
    docker-compose up -d frontend
    sleep 5
fi

# Get the frontend URL (adjust if needed)
FRONTEND_URL="http://localhost:6789"

echo "Starting Chromium in kiosk mode..."
echo "URL: $FRONTEND_URL"

# Launch Chromium in kiosk mode with touch optimizations
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
  --simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT' \
  --disable-component-update \
  --app="$FRONTEND_URL"

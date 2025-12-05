#!/bin/bash
# Monitor and restart Chromium if it crashes
# Run this in the background to ensure kiosk mode stays active

KIOSK_SCRIPT="/home/pi/kiosk.sh"
CHECK_INTERVAL=30

echo "Starting GoApp monitoring service..."

while true; do
    # Check if Chromium is running
    if ! pgrep -f "chromium-browser" > /dev/null; then
        echo "$(date): Chromium not running. Restarting..."
        $KIOSK_SCRIPT &
    fi
    
    sleep $CHECK_INTERVAL
done

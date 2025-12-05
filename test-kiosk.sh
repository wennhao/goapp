#!/bin/bash

# Test Kiosk Mode Script
# This script tests the kiosk setup and launches the browser manually

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "=========================================="
echo "GoApp Kiosk Mode Test"
echo "=========================================="
echo ""

# Test 1: Check DISPLAY
echo "1. Checking DISPLAY environment..."
if [ -z "$DISPLAY" ]; then
    print_warning "DISPLAY not set, using :0"
    export DISPLAY=:0
else
    print_status "DISPLAY is set to: $DISPLAY"
fi

# Test 2: Check X server
echo ""
echo "2. Checking X server..."
if xset q &>/dev/null; then
    print_status "X server is running"
else
    print_error "X server is not accessible"
    echo "   Make sure you're running this from a graphical session"
    exit 1
fi

# Test 3: Check Docker
echo ""
echo "3. Checking Docker..."
if docker ps &>/dev/null; then
    print_status "Docker is running (no sudo needed)"
elif sudo docker ps &>/dev/null; then
    print_status "Docker is running (requires sudo)"
else
    print_error "Docker is not running"
    echo "   Try: sudo systemctl start docker"
    exit 1
fi

# Test 4: Check Docker containers
echo ""
echo "4. Checking Docker containers..."
if docker ps | grep -q goapp-frontend || sudo docker ps | grep -q goapp-frontend; then
    print_status "GoApp containers are running"
else
    print_warning "GoApp containers are not running"
    echo "   Starting containers..."
    cd "$(dirname "$0")"
    if docker compose up -d 2>/dev/null; then
        print_status "Containers started successfully"
    elif sudo docker compose up -d 2>/dev/null; then
        print_status "Containers started successfully (with sudo)"
    else
        print_error "Failed to start containers"
        exit 1
    fi
    echo "   Waiting 10 seconds for services to initialize..."
    sleep 10
fi

# Test 5: Check frontend accessibility
echo ""
echo "5. Checking frontend accessibility..."
MAX_RETRIES=30
for i in $(seq 1 $MAX_RETRIES); do
    if curl -s http://localhost:6789 > /dev/null 2>&1; then
        print_status "Frontend is accessible at http://localhost:6789"
        break
    else
        if [ $i -eq $MAX_RETRIES ]; then
            print_error "Frontend is not accessible after $MAX_RETRIES seconds"
            echo "   Check container logs: docker compose logs frontend"
            exit 1
        fi
        echo "   Waiting for frontend... ($i/$MAX_RETRIES)"
        sleep 1
    fi
done

# Test 6: Check Chromium
echo ""
echo "6. Checking Chromium installation..."
if command -v chromium &> /dev/null; then
    print_status "Chromium is installed"
elif command -v chromium-browser &> /dev/null; then
    print_status "Chromium (chromium-browser) is installed"
    # Create alias for consistency
    shopt -s expand_aliases
    alias chromium='chromium-browser'
else
    print_error "Chromium is not installed"
    echo "   Install with: sudo apt-get install chromium"
    exit 1
fi

# Test 7: Kill any existing Chromium instances
echo ""
echo "7. Checking for existing Chromium instances..."
if pgrep -x chromium > /dev/null || pgrep -x chromium-browser > /dev/null; then
    print_warning "Chromium is already running, killing existing instances..."
    pkill chromium 2>/dev/null
    pkill chromium-browser 2>/dev/null
    sleep 2
    print_status "Existing instances closed"
else
    print_status "No existing Chromium instances found"
fi

# Test 8: Launch Chromium
echo ""
echo "8. Launching Chromium in kiosk mode..."
echo "   URL: http://localhost:6789"
echo "   Press Ctrl+C to exit this script (Chromium will keep running)"
echo "   Press Alt+F4 or Ctrl+W in Chromium to close the browser"
echo ""
sleep 2

DISPLAY=:0 chromium --kiosk --incognito --disable-infobars --noerrdialogs \
    --disable-session-crashed-bubble --disable-restore-session-state \
    --disable-translate --start-maximized --disable-pinch \
    --overscroll-history-navigation=0 --disable-features=TranslateUI \
    --check-for-update-interval=31536000 --no-first-run \
    --disable-sync --disable-background-networking \
    http://localhost:6789 &

CHROMIUM_PID=$!

echo ""
print_status "Chromium launched with PID: $CHROMIUM_PID"
echo ""
echo "=========================================="
echo "Test completed successfully!"
echo "=========================================="
echo ""
echo "The browser should now be open in kiosk mode."
echo "To close: Press Alt+F4 or Ctrl+W"
echo "To kill from terminal: kill $CHROMIUM_PID"
echo ""

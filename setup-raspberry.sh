#!/bin/bash

# GoApp Raspberry Pi Automatic Setup Script
# This script sets up the entire environment for running GoApp in kiosk mode

set -e  # Exit on any error

echo "=========================================="
echo "GoApp Raspberry Pi Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    print_warning "This script is designed for Raspberry Pi. Continuing anyway..."
fi

# Update system
print_status "Updating system packages..."
sudo apt-get update

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_status "Docker installed successfully"
else
    print_status "Docker already installed"
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
    print_status "Docker Compose installed successfully"
else
    print_status "Docker Compose already installed"
fi

# Install Chromium and utilities
print_status "Installing Chromium and utilities..."
sudo apt-get install -y chromium-browser unclutter x11-xserver-utils

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build and start Docker containers
print_status "Building and starting Docker containers..."
docker-compose down 2>/dev/null || true
docker-compose up -d --build

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 10

# Check if frontend is accessible
if curl -s http://localhost:6789 > /dev/null; then
    print_status "Frontend is accessible"
else
    print_warning "Frontend may not be ready yet. It should be available shortly."
fi

# Configure autostart for kiosk mode
print_status "Configuring kiosk mode autostart..."
AUTOSTART_DIR="$HOME/.config/lxsession/LXDE-pi"
AUTOSTART_FILE="$AUTOSTART_DIR/autostart"

mkdir -p "$AUTOSTART_DIR"

# Create autostart configuration
cat > "$AUTOSTART_FILE" << 'EOF'
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash

# Hide cursor after 0.1s of inactivity
@unclutter -idle 0.1 -root

# Disable screen blanking and power management
@xset s off
@xset -dpms
@xset s noblank

# Start Chromium in kiosk mode
@chromium-browser --kiosk --incognito --disable-infobars --noerrdialogs --disable-session-crashed-bubble --disable-restore-session-state --disable-translate --start-maximized --disable-pinch --overscroll-history-navigation=0 http://localhost:6789
EOF

print_status "Autostart configuration created"

# Configure lightdm to prevent screen blanking
print_status "Configuring display settings..."
LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

if [ -f "$LIGHTDM_CONF" ]; then
    # Backup original config
    sudo cp "$LIGHTDM_CONF" "$LIGHTDM_CONF.backup"
    
    # Check if xserver-command already exists
    if sudo grep -q "^xserver-command" "$LIGHTDM_CONF"; then
        print_status "xserver-command already configured"
    else
        # Add xserver-command under [Seat:*]
        sudo sed -i '/^\[Seat:\*\]/a xserver-command=X -s 0 -dpms' "$LIGHTDM_CONF"
        print_status "Display settings configured"
    fi
else
    print_warning "lightdm.conf not found. Screen blanking settings may need manual configuration."
fi

# Create a helper script to restart the app
print_status "Creating helper scripts..."
cat > "$SCRIPT_DIR/restart-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker-compose restart
echo "App restarted successfully"
EOF
chmod +x "$SCRIPT_DIR/restart-app.sh"

cat > "$SCRIPT_DIR/stop-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker-compose down
echo "App stopped successfully"
EOF
chmod +x "$SCRIPT_DIR/stop-app.sh"

cat > "$SCRIPT_DIR/start-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker-compose up -d
echo "App started successfully"
EOF
chmod +x "$SCRIPT_DIR/start-app.sh"

cat > "$SCRIPT_DIR/update-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
git pull
docker-compose down
docker-compose up -d --build
echo "App updated successfully"
EOF
chmod +x "$SCRIPT_DIR/update-app.sh"

# Enable Docker to start on boot
print_status "Enabling Docker to start on boot..."
sudo systemctl enable docker

# Create a systemd service to ensure Docker Compose starts on boot
print_status "Creating systemd service for GoApp..."
sudo tee /etc/systemd/system/goapp.service > /dev/null << EOF
[Unit]
Description=GoApp Docker Compose Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable goapp.service
sudo systemctl start goapp.service

print_status "Systemd service created and enabled"

echo ""
echo "=========================================="
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reboot your Raspberry Pi to start kiosk mode: sudo reboot"
echo "2. After reboot, the app will automatically start in fullscreen"
echo ""
echo "Helper scripts created:"
echo "  - ./restart-app.sh  : Restart the application"
echo "  - ./stop-app.sh     : Stop the application"
echo "  - ./start-app.sh    : Start the application"
echo "  - ./update-app.sh   : Update from git and rebuild"
echo ""
echo "Access points:"
echo "  - Frontend (kiosk): http://localhost:6789"
echo "  - Dashboard:        http://localhost:6790"
echo "  - Backend API:      http://localhost:3001"
echo ""
echo "To exit kiosk mode after reboot: Alt+F4 or Ctrl+W"
echo ""

# Ask user if they want to reboot now
read -p "Would you like to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Rebooting..."
    sudo reboot
else
    print_status "Please reboot manually when ready: sudo reboot"
fi

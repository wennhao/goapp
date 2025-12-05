#!/bin/bash

# GoApp Raspberry Pi Automatic Setup Script
# This script sets up the entire environment for running GoApp in kiosk mode

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
    print_warning "Docker group membership added. You may need to log out and back in, or the script will use sudo for docker commands."
else
    print_status "Docker already installed"
fi

# Ensure user is in docker group
if ! groups $USER | grep -q docker 2>/dev/null; then
    print_status "Adding user to docker group..."
    sudo usermod -aG docker $USER
    print_warning "User added to docker group. Using sudo for docker commands in this session."
fi

# Ensure Docker daemon is running
print_status "Checking Docker daemon status..."
if ! sudo systemctl is-active --quiet docker; then
    print_status "Starting Docker daemon..."
    sudo systemctl start docker
    sleep 2
fi

# Check for docker-compose or docker compose
if ! command -v docker-compose &> /dev/null && ! sudo docker compose version &> /dev/null 2>&1; then
    print_status "Docker Compose plugin not found, using docker compose (plugin version)..."
    # The docker install script already installed docker-compose-plugin
    # Create a symlink or alias for compatibility
    if sudo docker compose version &> /dev/null 2>&1; then
        print_status "Docker Compose (plugin) is available via 'docker compose'"
    else
        print_error "Docker Compose installation failed. Please install manually."
        exit 1
    fi
else
    print_status "Docker Compose already installed"
fi

# Install Chromium and utilities
print_status "Installing Chromium and utilities..."
sudo apt-get install -y chromium unclutter x11-xserver-utils

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Determine if we need sudo for docker commands
USE_SUDO=""
if ! docker ps >/dev/null 2>&1; then
    print_warning "Docker requires sudo for this session. Using sudo for docker commands."
    USE_SUDO="sudo"
fi

# Build and start Docker containers
print_status "Building and starting Docker containers..."
$USE_SUDO docker compose down 2>/dev/null || true
$USE_SUDO docker compose up -d --build

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

# Detect desktop environment and set appropriate autostart directory
if [ -d "$HOME/.config/lxsession/LXDE-pi" ]; then
    AUTOSTART_DIR="$HOME/.config/lxsession/LXDE-pi"
    DE_PROFILE="LXDE-pi"
elif [ -d "$HOME/.config/lxsession/LXDE" ]; then
    AUTOSTART_DIR="$HOME/.config/lxsession/LXDE"
    DE_PROFILE="LXDE"
else
    # Create LXDE-pi directory as default
    AUTOSTART_DIR="$HOME/.config/lxsession/LXDE-pi"
    DE_PROFILE="LXDE-pi"
    print_warning "Desktop environment not detected, using LXDE-pi as default"
fi

AUTOSTART_FILE="$AUTOSTART_DIR/autostart"
mkdir -p "$AUTOSTART_DIR"

# Create a startup script that waits for services
STARTUP_SCRIPT="$SCRIPT_DIR/start-kiosk.sh"
cat > "$STARTUP_SCRIPT" << 'STARTUP_EOF'
#!/bin/bash

# Wait for X server to be ready
echo "Waiting for X server..."
while [ -z "$DISPLAY" ]; do
    export DISPLAY=:0
    sleep 1
done

# Wait a bit more for X to fully initialize
sleep 5

# Ensure Docker containers are running
if ! docker ps | grep -q goapp-frontend 2>/dev/null; then
    cd "$(dirname "$0")"
    sudo docker compose up -d 2>/dev/null || docker compose up -d 2>/dev/null
    sleep 10
fi

# Wait for frontend to be accessible
echo "Waiting for frontend to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:6789 > /dev/null 2>&1; then
        echo "Frontend is ready!"
        break
    fi
    sleep 1
done

# Final wait to ensure everything is stable
sleep 2

# Launch Chromium in kiosk mode with DISPLAY set
DISPLAY=:0 chromium --kiosk --app=http://localhost:6789 \
    --touch-events=enabled --disable-pinch --noerrdialogs \
    --disable-infobars --no-first-run --disable-sync \
    --disable-session-crashed-bubble --disable-restore-session-state \
    --disable-translate --disable-features=TranslateUI \
    --check-for-update-interval=31536000 \
    --disable-background-networking &
STARTUP_EOF

chmod +x "$STARTUP_SCRIPT"

# Create autostart configuration
cat > "$AUTOSTART_FILE" << EOF
@lxpanel --profile $DE_PROFILE
@pcmanfm --desktop --profile $DE_PROFILE
@xscreensaver -no-splash

# Hide cursor after 0.1s of inactivity
@unclutter -idle 0.1 -root

# Disable screen blanking and power management
@xset s off
@xset -dpms
@xset s noblank

# Start GoApp in kiosk mode
@bash $STARTUP_SCRIPT
EOF

print_status "Autostart configuration created at: $AUTOSTART_FILE"
print_status "Kiosk startup script created at: $STARTUP_SCRIPT"

# Also create a .desktop file for XDG autostart (fallback method)
XDG_AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$XDG_AUTOSTART_DIR"
cat > "$XDG_AUTOSTART_DIR/goapp-kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Name=GoApp PWA
Exec=chromium --kiosk --app=http://localhost:6789 --touch-events=enabled --disable-pinch --noerrdialogs --disable-infobars --no-first-run --disable-sync --disable-session-crashed-bubble --disable-restore-session-state
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
print_status "XDG autostart .desktop file created as fallback"

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
docker compose restart
echo "App restarted successfully"
EOF
chmod +x "$SCRIPT_DIR/restart-app.sh"

cat > "$SCRIPT_DIR/stop-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker compose down
echo "App stopped successfully"
EOF
chmod +x "$SCRIPT_DIR/stop-app.sh"

cat > "$SCRIPT_DIR/start-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker compose up -d
echo "App started successfully"
EOF
chmod +x "$SCRIPT_DIR/start-app.sh"

cat > "$SCRIPT_DIR/update-app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
git pull
docker compose down
docker compose up -d --build
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
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable goapp.service
sudo systemctl start goapp.service 2>/dev/null || print_warning "Service start may require reboot"

print_status "Systemd service created and enabled"

echo ""
echo "=========================================="
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "=========================================="
echo ""
echo "IMPORTANT: If this is a fresh Docker install, you MUST log out and back in"
echo "           (or reboot) for docker group permissions to take effect."
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

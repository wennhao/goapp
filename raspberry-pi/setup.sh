#!/bin/bash
# Quick setup script for Raspberry Pi
# Run this script on your Raspberry Pi to install everything

echo "======================================"
echo "GoApp Raspberry Pi Setup"
echo "======================================"
echo ""

# Update system
echo "Step 1/6: Updating system..."
sudo apt update
sudo apt upgrade -y

# Install Docker
echo ""
echo "Step 2/6: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
else
    echo "Docker already installed"
fi

# Install Docker Compose
echo ""
echo "Step 3/6: Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo apt install -y docker-compose
else
    echo "Docker Compose already installed"
fi

# Install required packages
echo ""
echo "Step 4/6: Installing required packages..."
sudo apt install -y \
    chromium-browser \
    unclutter \
    xdotool \
    matchbox-keyboard \
    xinput \
    wmctrl

# Optional: Install Onboard keyboard (more modern)
read -p "Install Onboard keyboard? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt install -y onboard
fi

# Create directories
echo ""
echo "Step 5/6: Creating directories..."
mkdir -p ~/.config/lxsession/LXDE-pi
mkdir -p ~/.config/autostart

# Copy scripts
echo ""
echo "Step 6/6: Setting up scripts..."

# Copy kiosk script
cp kiosk.sh ~/kiosk.sh
chmod +x ~/kiosk.sh

# Copy monitor script
cp monitor.sh ~/monitor.sh
chmod +x ~/monitor.sh

# Copy autostart configuration
cp autostart ~/.config/lxsession/LXDE-pi/autostart

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Copy your GoApp project to ~/goapp"
echo "2. Create .env file in ~/goapp with backend URL"
echo "3. Start Docker containers: cd ~/goapp && docker-compose up -d"
echo "4. Enable auto-login in raspi-config"
echo "5. Reboot: sudo reboot"
echo ""
echo "Optional: Edit ~/kiosk.sh to change keyboard (matchbox/onboard)"
echo ""

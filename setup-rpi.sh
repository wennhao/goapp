#!/bin/bash
# Raspberry Pi 5 Setup Script for GoApp PWA
# Run this script on your Raspberry Pi to configure touch support and virtual keyboard

set -e

echo "================================================"
echo "GoApp PWA - Raspberry Pi 5 Setup"
echo "================================================"
echo ""

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null && ! grep -q "BCM" /proc/cpuinfo 2>/dev/null; then
    echo "Warning: This doesn't appear to be a Raspberry Pi"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

echo ""
echo "Step 2: Installing virtual keyboard..."
echo "Choose your preferred virtual keyboard:"
echo "1) Onboard (Recommended - feature-rich)"
echo "2) Florence (Simple and lightweight)"
echo "3) Matchbox (Minimal)"
read -p "Enter choice (1-3): " keyboard_choice

case $keyboard_choice in
    1)
        echo "Installing Onboard..."
        sudo apt-get install onboard -y
        KEYBOARD_CMD="onboard"
        KEYBOARD_NAME="Onboard"
        ;;
    2)
        echo "Installing Florence..."
        sudo apt-get install florence -y
        KEYBOARD_CMD="florence --no-gnome"
        KEYBOARD_NAME="Florence"
        ;;
    3)
        echo "Installing Matchbox..."
        sudo apt-get install matchbox-keyboard -y
        KEYBOARD_CMD="matchbox-keyboard"
        KEYBOARD_NAME="Matchbox"
        ;;
    *)
        echo "Invalid choice. Installing Onboard by default..."
        sudo apt-get install onboard -y
        KEYBOARD_CMD="onboard"
        KEYBOARD_NAME="Onboard"
        ;;
esac

echo ""
echo "Step 3: Configuring auto-start for virtual keyboard..."
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/virtual-keyboard.desktop << EOF
[Desktop Entry]
Type=Application
Name=$KEYBOARD_NAME Virtual Keyboard
Exec=$KEYBOARD_CMD
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo ""
echo "Step 4: Installing Docker (if not already installed)..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "Docker installed successfully"
else
    echo "Docker already installed"
fi

echo ""
echo "Step 5: Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo apt-get install docker-compose -y
    echo "Docker Compose installed successfully"
else
    echo "Docker Compose already installed"
fi

echo ""
echo "Step 6: Disabling screen blanking..."
# Disable screen blanking in LXDE
if [ -f /etc/xdg/lxsession/LXDE-pi/autostart ]; then
    sudo bash -c 'cat >> /etc/xdg/lxsession/LXDE-pi/autostart' << 'EOF'
@xset s off
@xset -dpms
@xset s noblank
EOF
    echo "Screen blanking disabled"
fi

# Also disable in lightdm if it exists
if [ -f /etc/lightdm/lightdm.conf ]; then
    if ! grep -q "xserver-command=X -s 0 -dpms" /etc/lightdm/lightdm.conf; then
        sudo bash -c 'echo "xserver-command=X -s 0 -dpms" >> /etc/lightdm/lightdm.conf'
        echo "Display timeout disabled in lightdm"
    fi
fi

echo ""
echo "Step 7: Installing touchscreen calibration tool..."
sudo apt-get install xinput-calibrator -y

echo ""
echo "Step 8: Configuring Chromium for kiosk mode..."
read -p "Do you want to auto-start the GoApp in kiosk mode? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter the URL for your GoApp (default: http://localhost:6789): " APP_URL
    APP_URL=${APP_URL:-http://localhost:6789}
    
    cat > ~/.config/autostart/goapp.desktop << EOF
[Desktop Entry]
Type=Application
Name=GoApp PWA
Exec=chromium-browser --kiosk --app=$APP_URL --touch-events=enabled --disable-pinch --noerrdialogs --disable-infobars
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
    echo "Kiosk mode configured for $APP_URL"
fi

echo ""
echo "Step 9: Enabling hardware acceleration in Chromium..."
mkdir -p ~/.config/chromium/Default
cat > ~/.config/chromium/Default/Preferences << 'EOF'
{
   "browser": {
      "enable_spellchecking": false
   },
   "hardware_acceleration_mode": {
      "enabled": true
   }
}
EOF

echo ""
echo "Step 10: Creating desktop shortcut..."
cat > ~/Desktop/GoApp.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=chromium-browser --app=http://localhost:6789 --touch-events=enabled
Name=GoApp
Comment=GoApp PWA
Icon=web-browser
Categories=Network;WebBrowser;
EOF
chmod +x ~/Desktop/GoApp.desktop

echo ""
echo "Step 11: Optimizing GPU memory..."
if [ -f /boot/config.txt ]; then
    if ! grep -q "gpu_mem=" /boot/config.txt; then
        sudo bash -c 'echo "gpu_mem=128" >> /boot/config.txt'
        echo "GPU memory set to 128MB"
    fi
fi

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Reboot your Raspberry Pi: sudo reboot"
echo "2. After reboot, navigate to your goapp directory"
echo "3. Start the application: docker-compose up -d"
echo "4. The virtual keyboard should appear automatically"
echo "5. Open Chromium and navigate to http://localhost:6789"
echo ""
echo "Additional commands:"
echo "- Calibrate touchscreen: xinput_calibrator"
echo "- Stop keyboard: killall $KEYBOARD_CMD"
echo "- Start keyboard: $KEYBOARD_CMD &"
echo ""
read -p "Would you like to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi

# Raspberry Pi Virtual Keyboard Setup Guide

## For Raspberry Pi 5 with 64-bit OS and Touchscreen

### Option 1: Florence Virtual Keyboard (Recommended)

1. Install Florence:
```bash
sudo apt-get update
sudo apt-get install florence
```

2. Configure Florence to auto-start:
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/florence.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Florence Virtual Keyboard
Exec=florence --no-gnome
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

3. Start Florence manually (or reboot):
```bash
florence --no-gnome &
```

### Option 2: Onboard Virtual Keyboard

1. Install Onboard:
```bash
sudo apt-get update
sudo apt-get install onboard
```

2. Configure auto-start:
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/onboard.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Onboard Virtual Keyboard
Exec=onboard
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

3. Configure Onboard for web usage:
- Open Onboard settings
- Enable "Auto-show when editing text"
- Set appearance to your preference

### Option 3: Matchbox Keyboard (Lightweight)

1. Install Matchbox:
```bash
sudo apt-get update
sudo apt-get install matchbox-keyboard
```

2. Create a toggle script:
```bash
cat > ~/toggle-keyboard.sh << 'EOF'
#!/bin/bash
PID=$(pidof matchbox-keyboard)
if [ -z "$PID" ]; then
    matchbox-keyboard &
else
    kill $PID
fi
EOF
chmod +x ~/toggle-keyboard.sh
```

3. Add keyboard shortcut in Raspberry Pi Configuration

### Browser Configuration for PWA

1. **Use Chromium in Kiosk Mode** (Full-screen PWA):
```bash
chromium-browser --kiosk --app=http://localhost:3000 --touch-events=enabled --disable-pinch
```

2. **Create Desktop Shortcut**:
```bash
cat > ~/Desktop/goapp.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=chromium-browser --kiosk --app=http://localhost:3000 --touch-events=enabled --disable-pinch
Name=GoApp
Icon=/home/pi/goapp-icon.png
EOF
chmod +x ~/Desktop/goapp.desktop
```

3. **Auto-start PWA on Boot**:
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/goapp.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=GoApp PWA
Exec=chromium-browser --kiosk --app=http://localhost:3000 --touch-events=enabled --disable-pinch
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

### Testing Touch Events

1. Test if touch events are working:
```bash
# Open browser console and run:
# document.addEventListener('touchstart', () => console.log('Touch detected'));
```

2. Enable touch debugging in Chrome:
- Open DevTools (F12)
- Settings > Devices > Add custom device
- Enable touch simulation

### Troubleshooting

**Keyboard doesn't appear:**
- Check if keyboard daemon is running: `ps aux | grep -E 'onboard|florence|matchbox'`
- Restart the keyboard service
- Ensure input fields have proper focus

**Scrolling not smooth:**
- Ensure CSS touch properties are applied
- Check Chrome flags: `chrome://flags`
- Enable "Touch Events API"
- Enable "Smooth Scrolling"

**Browser not full screen:**
```bash
# Disable screen blanking
sudo nano /etc/lightdm/lightdm.conf
# Add under [Seat:*]:
# xserver-command=X -s 0 -dpms
```

### System Optimizations for Touch

1. **Calibrate Touchscreen:**
```bash
sudo apt-get install xinput-calibrator
xinput_calibrator
```

2. **Disable Screen Timeout:**
```bash
sudo nano /etc/xdg/lxsession/LXDE-pi/autostart
# Add:
# @xset s off
# @xset -dpms
# @xset s noblank
```

3. **Increase Touch Sensitivity:**
```bash
xinput list  # Find your touch device ID
xinput list-props <device-id>
# Adjust properties as needed
```

### Performance Tips

1. **Reduce Memory Usage:**
```bash
# Edit /boot/config.txt
sudo nano /boot/config.txt
# Reduce GPU memory if not using heavy graphics
gpu_mem=128
```

2. **Enable Hardware Acceleration:**
```bash
# For Chromium, ensure hardware acceleration is enabled
# chrome://flags
# Search for "Hardware-accelerated video decode"
```

### Integration with Your App

The virtual keyboard handler in `src/utils/virtualKeyboard.js` will:
- Auto-detect Raspberry Pi environment
- Listen for input focus events
- Scroll inputs into view when focused
- Emit custom events for system-level keyboard triggers

For advanced integration with system keyboard:
- Use browser extensions or custom Chromium builds
- Implement WebExtension API calls
- Use Electron wrapper for deeper system integration

### Complete Setup Script

```bash
#!/bin/bash
# Run this script to set up everything

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install virtual keyboard
sudo apt-get install onboard -y

# Install Docker if needed
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install docker-compose -y

# Configure auto-start
mkdir -p ~/.config/autostart

cat > ~/.config/autostart/onboard.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Onboard
Exec=onboard
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Disable screen blanking
sudo sh -c 'echo "xserver-command=X -s 0 -dpms" >> /etc/lightdm/lightdm.conf'

echo "Setup complete! Please reboot your Raspberry Pi."
echo "After reboot, navigate to your project and run: docker-compose up -d"
```

Save this as `setup-rpi.sh`, make it executable with `chmod +x setup-rpi.sh`, and run it.

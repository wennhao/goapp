#!/bin/bash
# Quick Start Guide for Touch-Enabled PWA on Raspberry Pi

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║         GoApp PWA - Touch & Keyboard Quick Reference           ║
╚════════════════════════════════════════════════════════════════╝

📱 RASPBERRY PI SETUP (ONE-TIME)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Run setup script:
   chmod +x setup-rpi.sh && ./setup-rpi.sh

2. Reboot:
   sudo reboot

🚀 STARTING THE APPLICATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Navigate to project:
   cd ~/goapp

2. Start with Docker:
   docker-compose up -d

3. Access:
   Frontend:  http://localhost:6789
   Dashboard: http://localhost:6790

⌨️  VIRTUAL KEYBOARD COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Start keyboard:
   onboard &              # Recommended
   florence --no-gnome &  # Alternative
   matchbox-keyboard &    # Minimal

Stop keyboard:
   killall onboard
   killall florence
   killall matchbox-keyboard

Check if running:
   ps aux | grep -E 'onboard|florence|matchbox'

🌐 BROWSER LAUNCH OPTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Full Kiosk Mode:
   chromium-browser --kiosk --app=http://localhost:6789 \
     --touch-events=enabled --disable-pinch --noerrdialogs

Normal Mode:
   chromium-browser --app=http://localhost:6789 \
     --touch-events=enabled

With Debugging:
   chromium-browser --app=http://localhost:6789 \
     --touch-events=enabled --auto-open-devtools-for-tabs

🎯 TOUCH GESTURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Swipe Up/Down     → Smooth scroll through content
Tap Input Field   → Virtual keyboard auto-shows
Tap Outside       → Keyboard auto-hides
Pinch Zoom        → Zoom in/out (up to 5x)
Long Press        → Text selection (in inputs)

🔧 TROUBLESHOOTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Keyboard not showing:
   1. ps aux | grep onboard
   2. onboard &
   3. Check browser console (F12)

Scrolling not smooth:
   1. Enable: chrome://flags/#smooth-scrolling
   2. Enable: chrome://flags/#touch-events
   3. Restart Chromium

Screen blanking:
   xset s off && xset -dpms && xset s noblank

Calibrate touchscreen:
   xinput_calibrator

Reset app state:
   docker-compose down && docker-compose up -d

View logs:
   docker-compose logs -f backend
   docker-compose logs -f frontend

🛠️  DEVELOPMENT COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stop containers:
   docker-compose down

Rebuild after changes:
   docker-compose up -d --build

View container status:
   docker-compose ps

Access container shell:
   docker exec -it goapp-backend-1 sh
   docker exec -it goapp-frontend-1 sh

Clear Docker cache:
   docker system prune -a

📊 SYSTEM MONITORING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CPU/Memory usage:
   htop

Temperature:
   vcgencmd measure_temp

GPU memory:
   vcgencmd get_mem gpu

Display info:
   xrandr

Touch device info:
   xinput list

🔐 SECURITY TIPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Disable SSH password login:
   sudo nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no

Setup firewall:
   sudo apt-get install ufw
   sudo ufw allow 22/tcp
   sudo ufw allow 6789/tcp
   sudo ufw allow 6790/tcp
   sudo ufw enable

Auto-update system:
   sudo apt-get install unattended-upgrades
   sudo dpkg-reconfigure unattended-upgrades

📚 USEFUL FILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RASPBERRY_PI_SETUP.md    → Detailed setup guide
TOUCH_ENHANCEMENTS.md    → Technical documentation
setup-rpi.sh             → Automated setup script
docker-compose.yml       → Container configuration

🌐 NETWORK CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Find Pi IP address:
   hostname -I

Set static IP:
   sudo nano /etc/dhcpcd.conf
   # Add:
   # interface eth0
   # static ip_address=192.168.1.100/24
   # static routers=192.168.1.1
   # static domain_name_servers=192.168.1.1

Access from other devices:
   http://<raspberry-pi-ip>:6789

📞 SUPPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Check browser console:    F12 → Console tab
Check network requests:   F12 → Network tab
Test touch events:        F12 → Console → enter:
                         document.addEventListener('touchstart', 
                           () => console.log('Touch works!'))

View PWA manifest:        F12 → Application → Manifest
Check service worker:     F12 → Application → Service Workers

═══════════════════════════════════════════════════════════════════
              Built for Raspberry Pi 5 (64-bit OS)
═══════════════════════════════════════════════════════════════════
EOF

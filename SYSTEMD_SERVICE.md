# GoApp Systemd Service Configuration
# Auto-start GoApp PWA on Raspberry Pi boot

## Installation Instructions

### 1. Create systemd service file:
```bash
sudo nano /etc/systemd/system/goapp.service
```

### 2. Paste the following configuration:
```ini
[Unit]
Description=GoApp PWA Docker Container
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/pi/goapp
ExecStartPre=/usr/bin/docker-compose down
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=pi
Group=pi

[Install]
WantedBy=multi-user.target
```

### 3. Update WorkingDirectory:
Replace `/home/pi/goapp` with your actual project path.

### 4. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable goapp.service
sudo systemctl start goapp.service
```

### 5. Check status:
```bash
sudo systemctl status goapp.service
```

## Service Management Commands

### Start service:
```bash
sudo systemctl start goapp.service
```

### Stop service:
```bash
sudo systemctl stop goapp.service
```

### Restart service:
```bash
sudo systemctl restart goapp.service
```

### View logs:
```bash
sudo journalctl -u goapp.service -f
```

### Disable auto-start:
```bash
sudo systemctl disable goapp.service
```

## Full Auto-Start Configuration

For a complete kiosk setup with auto-start on boot:

### 1. Install GoApp service (as above)

### 2. Configure Chromium auto-start:
```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/goapp-browser.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=GoApp Browser
Exec=/bin/bash -c 'sleep 10 && chromium-browser --kiosk --app=http://localhost:6789 --touch-events=enabled --disable-pinch --noerrdialogs'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

### 3. Configure virtual keyboard auto-start:
```bash
cat > ~/.config/autostart/virtual-keyboard.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Virtual Keyboard
Exec=onboard
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

### 4. Disable screen blanking:
```bash
# Add to autostart
cat > ~/.config/autostart/disable-screensaver.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Disable Screensaver
Exec=/bin/bash -c 'xset s off && xset -dpms && xset s noblank'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
```

## Boot Order

With this configuration, on Raspberry Pi boot:

1. **Docker starts** (system service)
2. **GoApp containers start** (goapp.service)
3. **Desktop loads** (LXDE/X11)
4. **Screen blanking disabled** (autostart)
5. **Virtual keyboard starts** (autostart)
6. **Browser launches in kiosk mode** (autostart after 10s delay)

## Troubleshooting

### Service fails to start:
```bash
# Check logs
sudo journalctl -u goapp.service -n 50

# Check Docker
sudo systemctl status docker

# Check docker-compose
docker-compose config
```

### Browser doesn't start:
```bash
# Check autostart files
ls -la ~/.config/autostart/

# Test browser command manually
chromium-browser --kiosk --app=http://localhost:6789 --touch-events=enabled
```

### Containers not running:
```bash
# Check Docker containers
docker ps -a

# Manually start
cd /home/pi/goapp
docker-compose up -d

# Check logs
docker-compose logs
```

## Alternative: Using Crontab

If you prefer crontab over systemd:

```bash
crontab -e

# Add:
@reboot sleep 30 && cd /home/pi/goapp && /usr/bin/docker-compose up -d
```

## Health Check Script

Create a health check to restart if containers fail:

```bash
cat > ~/goapp-healthcheck.sh << 'EOF'
#!/bin/bash
cd /home/pi/goapp

if ! docker ps | grep -q goapp-frontend; then
    echo "Frontend down, restarting..."
    docker-compose restart frontend
fi

if ! docker ps | grep -q goapp-backend; then
    echo "Backend down, restarting..."
    docker-compose restart backend
fi

if ! docker ps | grep -q goapp-dashboard; then
    echo "Dashboard down, restarting..."
    docker-compose restart dashboard
fi
EOF

chmod +x ~/goapp-healthcheck.sh
```

### Add to crontab (run every 5 minutes):
```bash
crontab -e

# Add:
*/5 * * * * /home/pi/goapp-healthcheck.sh >> /home/pi/goapp-health.log 2>&1
```

## Complete Uninstall

To remove all auto-start configurations:

```bash
# Stop and disable service
sudo systemctl stop goapp.service
sudo systemctl disable goapp.service
sudo rm /etc/systemd/system/goapp.service
sudo systemctl daemon-reload

# Remove autostart entries
rm ~/.config/autostart/goapp-browser.desktop
rm ~/.config/autostart/virtual-keyboard.desktop
rm ~/.config/autostart/disable-screensaver.desktop

# Remove crontab entries
crontab -e  # Manually remove lines

# Stop containers
cd ~/goapp
docker-compose down
```

## Production Recommendations

For production deployment:

1. **Use systemd service** (more reliable than crontab)
2. **Enable health checks** (automatic restart on failure)
3. **Configure proper logging** (journald integration)
4. **Set resource limits** (prevent memory overflow)
5. **Enable automatic updates** (unattended-upgrades)
6. **Configure watchdog** (auto-reboot on system hang)

Example with resource limits:

```ini
[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/pi/goapp
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=pi
Group=pi
MemoryLimit=512M
CPUQuota=50%
Restart=on-failure
RestartSec=10s
```

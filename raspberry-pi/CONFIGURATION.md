# Raspberry Pi Configuration Tips

## Display Orientation

If your touchscreen is rotated, edit `/boot/config.txt`:

```bash
sudo nano /boot/config.txt
```

Add one of these lines:
```
display_rotate=0  # Normal
display_rotate=1  # 90 degrees
display_rotate=2  # 180 degrees
display_rotate=3  # 270 degrees
```

Reboot after changes.

## Touchscreen Calibration

If touch input is offset from actual position:

```bash
# Install calibration tool
sudo apt install -y xinput-calibrator

# Run calibration
xinput_calibrator

# Follow on-screen instructions
# Save output to: /etc/X11/xorg.conf.d/99-calibration.conf
```

## Performance Optimization

### Disable Unnecessary Services

```bash
# Disable Bluetooth (if not needed)
sudo systemctl disable bluetooth

# Disable WiFi (if using ethernet)
sudo rfkill block wifi
```

### Overclock (Optional - increases performance but may void warranty)

Edit `/boot/config.txt`:
```bash
sudo nano /boot/config.txt
```

Add:
```
# Overclock (Pi 5 - use with caution)
over_voltage=2
arm_freq=2800
```

### Increase GPU Memory

In `/boot/config.txt`:
```
gpu_mem=256
```

## Browser Optimization

### Clear Cache Regularly

Add to crontab:
```bash
crontab -e
```

Add:
```
0 3 * * * rm -rf ~/.cache/chromium
```

### Disable Chromium Sync

Already configured in kiosk.sh with `--no-first-run`

## Network Configuration

### Static IP Address

```bash
sudo nano /etc/dhcpcd.conf
```

Add:
```
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

### WiFi Auto-Connect

```bash
sudo raspi-config
# System Options → Wireless LAN
```

## Security

### Change Default Password

```bash
passwd
```

### Enable Firewall (if needed)

```bash
sudo apt install -y ufw
sudo ufw allow 22/tcp  # SSH
sudo ufw enable
```

### Disable SSH (for public kiosk)

```bash
sudo systemctl disable ssh
sudo systemctl stop ssh
```

## Backup

### Backup Docker Volumes

```bash
# Backup uploads
tar -czf backup-uploads-$(date +%Y%m%d).tar.gz ~/goapp/backend/uploads
```

### Backup Configuration

```bash
# Backup important configs
tar -czf backup-config-$(date +%Y%m%d).tar.gz \
  ~/.config/lxsession \
  ~/kiosk.sh \
  ~/goapp/.env \
  ~/goapp/docker-compose.yml
```

## Monitoring

### Temperature Monitoring

```bash
# Check temperature
vcgencmd measure_temp

# Add to monitor script
watch -n 2 vcgencmd measure_temp
```

### Resource Usage

```bash
# Install htop
sudo apt install -y htop

# Monitor
htop
```

### Docker Stats

```bash
docker stats
```

## Maintenance Schedule

### Daily (Automated)
- Clear browser cache (3 AM cron job)

### Weekly
- Check Docker logs: `docker logs goapp-frontend`
- Check system temperature
- Review disk space: `df -h`

### Monthly
- Update system: `sudo apt update && sudo apt upgrade`
- Update Docker images: `docker-compose pull && docker-compose up -d`
- Test touchscreen calibration

## Recovery

### Factory Reset Kiosk

```bash
# Remove kiosk configuration
rm ~/.config/lxsession/LXDE-pi/autostart
rm ~/kiosk.sh

# Reboot
sudo reboot
```

### Recover from Black Screen

1. SSH into Pi
2. Check Chromium: `ps aux | grep chromium`
3. Kill if needed: `pkill chromium-browser`
4. Check Docker: `docker ps`
5. Restart: `~/kiosk.sh &`

### Emergency Access

1. Connect keyboard to Pi
2. Press `Ctrl+Alt+F2` to switch to terminal
3. Login as pi
4. Debug or stop kiosk: `pkill chromium-browser`
5. Return to GUI: `Ctrl+Alt+F7`

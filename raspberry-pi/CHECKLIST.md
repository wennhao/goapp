# Raspberry Pi Kiosk Setup Checklist

Use this checklist to ensure everything is properly configured.

## ☐ Pre-Setup (Before Starting)

- [ ] Raspberry Pi 5 with power supply (5V 3A minimum)
- [ ] Touchscreen connected and working
- [ ] Raspberry Pi OS (64-bit) installed and booted
- [ ] Keyboard and mouse connected (temporary, for setup)
- [ ] Internet connection (WiFi or Ethernet)
- [ ] Backend server running and accessible on network
- [ ] Know your backend server IP address

## ☐ File Preparation

- [ ] Copy entire `raspberry-pi` folder to Raspberry Pi
- [ ] Copy entire `goapp` project to `~/goapp` on Raspberry Pi
- [ ] All scripts have execute permissions (`chmod +x *.sh`)

## ☐ System Setup

- [ ] System updated: `sudo apt update && sudo apt upgrade -y`
- [ ] Docker installed: `docker --version`
- [ ] Docker Compose installed: `docker-compose --version`
- [ ] User added to docker group: `groups | grep docker`
- [ ] Chromium browser installed: `which chromium-browser`
- [ ] Unclutter installed (hides cursor): `which unclutter`
- [ ] On-screen keyboard installed: `which matchbox-keyboard`

## ☐ Configuration

- [ ] Auto-login enabled in `raspi-config`
- [ ] `.env` file created in `~/goapp/` with correct backend URL
- [ ] `kiosk.sh` copied to `~/kiosk.sh`
- [ ] `kiosk.sh` is executable: `ls -l ~/kiosk.sh`
- [ ] Autostart file copied to `~/.config/lxsession/LXDE-pi/autostart`

## ☐ Docker Setup

- [ ] Docker service enabled: `sudo systemctl status docker`
- [ ] Navigated to project: `cd ~/goapp`
- [ ] Frontend container built: `docker-compose build frontend`
- [ ] Frontend container started: `docker-compose up -d frontend`
- [ ] Container is running: `docker ps | grep goapp-frontend`
- [ ] Frontend accessible: `curl http://localhost:6789`

## ☐ Kiosk Testing (Before Auto-Start)

- [ ] Manually run kiosk script: `~/kiosk.sh`
- [ ] Chromium opens in fullscreen
- [ ] Frontend loads correctly
- [ ] No browser controls visible (address bar, etc.)
- [ ] No desktop visible
- [ ] Can't close with Alt+F4 or other shortcuts

## ☐ Touchscreen Testing

- [ ] Touchscreen responds to taps
- [ ] Can scroll by swiping up/down
- [ ] Buttons respond to touch
- [ ] Touch is accurately aligned (not offset)
- [ ] Multi-touch gestures work (if needed)

## ☐ On-Screen Keyboard Testing

- [ ] Keyboard process running: `pgrep matchbox-keyboard`
- [ ] Tap on text input field
- [ ] Keyboard appears automatically
- [ ] Can type text with on-screen keyboard
- [ ] Keyboard is the right size
- [ ] Can dismiss keyboard

## ☐ Application Testing

- [ ] Navigate through all pages
- [ ] Fill out forms
- [ ] Upload/take photos (if applicable)
- [ ] Submit form successfully
- [ ] Backend receives data: `docker logs goapp-backend`
- [ ] Dashboard shows updates (if applicable)

## ☐ Auto-Start Configuration

- [ ] Rebooted Raspberry Pi: `sudo reboot`
- [ ] Pi boots to desktop automatically
- [ ] Chromium starts automatically
- [ ] Frontend loads without intervention
- [ ] Full kiosk mode active (no way to exit)

## ☐ Final Validation

- [ ] Wait 2-3 minutes to ensure stability
- [ ] Test full user workflow end-to-end
- [ ] Verify can't access desktop/browser controls
- [ ] Verify can't close application
- [ ] Test touch scrolling throughout app
- [ ] Test all buttons and interactions
- [ ] Test form submission with keyboard

## ☐ Reliability Testing

- [ ] Simulated crash: `pkill chromium-browser` - does it restart?
- [ ] Reboot test: Does everything start correctly?
- [ ] Power cycle test: Unplug and replug power
- [ ] Network reconnection: Disconnect and reconnect network

## ☐ Production Readiness (Optional)

- [ ] Temperature monitoring: `vcgencmd measure_temp` (should be < 70°C)
- [ ] Monitor script installed: `~/monitor.sh`
- [ ] Scheduled reboot configured (if desired): `sudo crontab -l`
- [ ] Remote access tested (SSH/VNC)
- [ ] Backup created of configuration files
- [ ] Default password changed
- [ ] Unnecessary services disabled

## ☐ Performance Optimization (Optional)

- [ ] GPU memory increased to 256MB in `/boot/config.txt`
- [ ] Bluetooth disabled (if not needed)
- [ ] WiFi disabled (if using Ethernet)
- [ ] Chromium cache clearing scheduled
- [ ] Swap memory configured

## ☐ Security (For Public Kiosks)

- [ ] SSH disabled: `sudo systemctl disable ssh`
- [ ] Default password changed
- [ ] Firewall enabled (if needed)
- [ ] Physical access restricted
- [ ] Network isolated (if needed)

## ☐ Documentation

- [ ] Tested emergency access (Ctrl+Alt+F2)
- [ ] Documented backend IP and ports
- [ ] Documented WiFi/Network credentials
- [ ] Saved troubleshooting notes
- [ ] Contact info for support documented

## ☐ Handoff (If Deploying for Someone Else)

- [ ] Demonstrated basic usage
- [ ] Showed how to restart: `sudo reboot`
- [ ] Provided remote access credentials
- [ ] Explained how to update: `docker-compose pull && up -d`
- [ ] Left documentation accessible
- [ ] Provided support contact

## 📊 Sign-Off

**Setup completed by:** ___________________________

**Date:** ___________________________

**Pi Location/Label:** ___________________________

**Backend Server:** ___________________________

**Notes:**
___________________________________________
___________________________________________
___________________________________________

---

## 🆘 Quick Troubleshooting Reference

| Problem | Quick Fix |
|---------|-----------|
| Black screen | SSH in, run `~/kiosk.sh &` |
| Touch not working | `xinput list` then `xinput enable <id>` |
| Keyboard missing | `matchbox-keyboard -d &` |
| App won't load | Check `docker ps` and `.env` file |
| Can't connect | Verify backend IP in `.env` |
| Chromium crashed | `rm -rf ~/.cache/chromium` |

**Emergency Shell Access:** Ctrl+Alt+F2, login, fix issue, Ctrl+Alt+F7 to return

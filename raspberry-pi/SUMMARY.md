# Raspberry Pi Touchscreen Kiosk - Complete Setup Summary

## 🎯 What You Get

Your GoApp will run on a Raspberry Pi 5 with touchscreen as a locked-down kiosk:

- **Auto-starts** when the Pi boots
- **Touch-enabled** with swipe scrolling
- **On-screen keyboard** appears when you tap input fields
- **Cannot be closed** - completely locked to your app
- **No browser controls** - looks like a native app
- **Auto-recovers** if it crashes

## 📦 What's Included

All setup files are in the `raspberry-pi/` folder:

| File | What It Does |
|------|--------------|
| **README.md** | Main guide with overview |
| **setup.sh** | Automated installer - run this first |
| **kiosk.sh** | Launches Chromium in kiosk mode |
| **autostart** | Makes kiosk start on boot |
| **monitor.sh** | Restarts kiosk if it crashes |
| **QUICKSTART.md** | Quick command reference |
| **CONFIGURATION.md** | Advanced settings & optimization |
| **CHECKLIST.md** | Step-by-step validation checklist |
| **ARCHITECTURE.md** | Technical diagrams & architecture |
| **.env.example** | Configuration template |

## 🚀 Super Quick Setup (TL;DR)

```bash
# 1. On Raspberry Pi, run the setup script
cd ~/goapp/raspberry-pi
chmod +x setup.sh
./setup.sh

# 2. Enable auto-login
sudo raspi-config
# System Options → Boot / Auto Login → Desktop Autologin

# 3. Configure backend URL
cd ~/goapp
nano .env
# Set: BACKEND_URL=http://YOUR-BACKEND-IP:3001

# 4. Start and reboot
docker-compose up -d frontend
sudo reboot
```

Done! Your kiosk is ready.

## 📋 Requirements

### Hardware
- ✅ Raspberry Pi 5 (or Pi 4 Model B with 2GB+ RAM)
- ✅ Official Raspberry Pi Touchscreen (or compatible)
- ✅ Power supply: 5V 3A minimum
- ✅ MicroSD card: 16GB+ (32GB recommended)
- ✅ (Optional) Case with touchscreen mount
- ✅ (Optional) Fan/heatsink for cooling

### Software
- ✅ Raspberry Pi OS (64-bit) - Desktop version
- ✅ Docker & Docker Compose (installed by setup script)
- ✅ Your GoApp backend running somewhere on the network

### Network
- ✅ WiFi or Ethernet connection
- ✅ Backend server accessible on local network
- ✅ Know the backend server's IP address

## 🎨 Features Implemented

### Touch Optimizations
```css
✓ Minimum 48px touch targets (buttons, inputs)
✓ No text selection (except in input fields)
✓ No zoom on input focus
✓ Smooth touch scrolling
✓ No pull-to-refresh
✓ Touch-friendly spacing
```

### Kiosk Security
```
✓ No address bar
✓ No browser menus
✓ No right-click menu
✓ Alt+F4 disabled
✓ Can't switch apps
✓ Can't access desktop
✓ Fullscreen only
```

### Reliability
```
✓ Auto-start on boot
✓ Auto-restart if crashed
✓ Network retry logic
✓ Docker auto-restart
✓ Cache clearing
```

## 🔧 How It Works

1. **Boot**: Pi starts, auto-login to desktop
2. **Autostart**: LXDE runs scripts from `~/.config/lxsession/LXDE-pi/autostart`
3. **Kiosk Script**: `~/kiosk.sh` executes:
   - Disables screensaver
   - Hides mouse cursor
   - Starts on-screen keyboard
   - Launches Chromium in kiosk mode
4. **Frontend**: Chromium loads `http://localhost:6789`
5. **Docker**: Frontend container serves the React app
6. **Touch**: X11 delivers touch events to Chromium
7. **Keyboard**: Matchbox keyboard appears on input focus

## 🎮 User Experience

### Scrolling
- Swipe up/down anywhere to scroll
- Smooth momentum scrolling
- Works just like a phone/tablet

### Buttons
- Tap any button to activate
- Visual feedback on touch
- Large touch-friendly size

### Text Input
1. Tap an input field
2. Keyboard slides up from bottom
3. Tap keys to type
4. Tap outside keyboard to hide

### Navigation
- Back buttons navigate to previous page
- Menu buttons open side menus
- All standard touch gestures work

## 🛠️ Customization Options

### Keyboard Choice

**Matchbox** (default - simple):
```bash
# In kiosk.sh, line ~15:
matchbox-keyboard -d &
```

**Onboard** (modern, with predictions):
```bash
# In kiosk.sh, swap to:
onboard &
```

### Screen Rotation

```bash
sudo nano /boot/config.txt
# Add: display_rotate=1  (for 90° rotation)
```

### Performance Tuning

```bash
sudo nano /boot/config.txt
# Add:
gpu_mem=256        # More GPU memory
over_voltage=2     # Slight overclock
arm_freq=2800
```

### Auto Reboot

```bash
sudo crontab -e
# Add: 0 4 * * * /sbin/shutdown -r now
# (Reboots daily at 4 AM)
```

## 🐛 Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| **Black screen after boot** | SSH in, run `~/kiosk.sh &` |
| **Touch not working** | Run `xinput list`, then `xinput enable <id>` |
| **Keyboard doesn't appear** | Run `matchbox-keyboard -d &` |
| **App doesn't load** | Check Docker: `docker ps` |
| **Wrong backend URL** | Edit `~/goapp/.env` and rebuild |
| **Chromium crashes** | Clear cache: `rm -rf ~/.cache/chromium` |
| **Touch offset/inaccurate** | Run `xinput_calibrator` |
| **Screen too dim** | Adjust in Pi settings or brightness control |

## 📞 Getting Help

1. **Check the docs**:
   - `README.md` - Main guide
   - `QUICKSTART.md` - Command reference
   - `CONFIGURATION.md` - Advanced settings
   - `CHECKLIST.md` - Validation steps

2. **Check logs**:
   ```bash
   # Docker logs
   docker logs goapp-frontend
   
   # System logs (if using systemd)
   sudo journalctl -u goapp-kiosk -f
   ```

3. **Test manually**:
   ```bash
   # Stop auto-start
   pkill chromium-browser
   
   # Run manually to see errors
   ~/kiosk.sh
   ```

## 📊 Maintenance

### Weekly
- Check temperature: `vcgencmd measure_temp`
- Check disk space: `df -h`
- Review logs: `docker logs goapp-frontend`

### Monthly
- Update system: `sudo apt update && sudo apt upgrade`
- Update containers: `docker-compose pull && docker-compose up -d`
- Test touchscreen calibration

### As Needed
- Clear Chromium cache: `rm -rf ~/.cache/chromium`
- Restart kiosk: `sudo reboot`
- Backup config files

## 🔒 Production Checklist

Before deploying to a public location:

- [ ] Test full user workflow multiple times
- [ ] Verify touchscreen accuracy
- [ ] Test on-screen keyboard with real input
- [ ] Confirm auto-start after power cycle
- [ ] Verify can't exit or access desktop
- [ ] Test crash recovery (kill Chromium, see if it restarts)
- [ ] Change default password: `passwd`
- [ ] Disable SSH: `sudo systemctl disable ssh`
- [ ] Mount Pi in secure enclosure
- [ ] Label with contact info for issues
- [ ] Document backend IP for future updates

## 🎓 Learning Resources

- **Raspberry Pi Docs**: https://www.raspberrypi.com/documentation/
- **Docker Docs**: https://docs.docker.com/
- **Chromium Kiosk**: Search "chromium kiosk mode" for advanced flags
- **Touchscreen Calibration**: `man xinput_calibrator`

## 💡 Pro Tips

1. **Use quality power supply** - Cheap adapters cause random reboots
2. **Keep Pi cool** - Add a fan if running 24/7
3. **Use wired network** - More reliable than WiFi for kiosks
4. **Test touchscreen brands** - Not all work well with Pi
5. **Monitor temperature** - Throttles at 80°C, aim for <70°C
6. **Regular reboots** - Schedule weekly reboots to clear memory
7. **Backup before updates** - Save working config before changing
8. **Label everything** - Write backend IP on Pi case
9. **Remote access** - Keep SSH enabled during testing
10. **Document changes** - Note any custom modifications

## 🌟 Success Metrics

Your kiosk is working perfectly when:

✅ Pi boots to your app in under 60 seconds  
✅ Touch responds instantly with no lag  
✅ Scrolling is smooth and natural  
✅ Keyboard appears reliably on input focus  
✅ No accidental exits or desktop access  
✅ Runs for days/weeks without issues  
✅ Auto-recovers from crashes  
✅ Forms submit successfully to backend  
✅ Users can complete full workflow without help  

## 📝 Version Info

- **Created for**: Raspberry Pi 5 (also works on Pi 4)
- **Tested with**: Raspberry Pi OS 64-bit (Debian 12 - Bookworm)
- **Docker**: 24.0+
- **Chromium**: 120+
- **Last updated**: December 2025

---

**Questions?** Review the documentation files or check the main README.md.

**Ready to start?** Go to `raspberry-pi/README.md` and follow the setup guide!

🚀 **Happy Kiosk-ing!**

# Touch & Virtual Keyboard Enhancements

## Overview
This document describes the touch-optimized PWA enhancements for Raspberry Pi 5 with touchscreen support.

## Features Added

### 1. Smooth Touch Scrolling
- **Momentum scrolling** with `-webkit-overflow-scrolling: touch`
- **Overscroll behavior** control to prevent unwanted bouncing
- **Smooth scroll behavior** for better UX
- **Touch-action optimization** for responsive pan gestures

### 2. Virtual Keyboard Support
- Automatic detection of Raspberry Pi environment
- Auto-show keyboard when input fields are focused
- Intelligent keyboard hiding when focus leaves inputs
- Visual feedback when keyboard is active
- Scrolling inputs into view when focused

### 3. Enhanced Input Fields
- `inputMode` attributes for appropriate keyboard types
- `enterKeyHint` for better keyboard interaction
- `autoComplete` support where appropriate
- Touch-friendly focus states

### 4. PWA Manifest Improvements
- `orientation: any` for flexible device rotation
- `purpose: any maskable` for adaptive icons
- Enhanced display mode for standalone app experience

### 5. Viewport Optimization
- Maximum scale set to 5.0 (allows pinch zoom up to 5x)
- User scalable enabled for accessibility
- Viewport-fit cover for edge-to-edge display
- Mobile web app capabilities enabled

## File Changes

### Modified Files:
1. **`frontend/vite.config.js`** - Enhanced PWA manifest
2. **`frontend/index.html`** - Improved viewport settings
3. **`frontend/src/index.css`** - Touch-optimized global styles
4. **`frontend/src/App.css`** - Smooth scrolling and touch properties
5. **`frontend/src/App.jsx`** - Virtual keyboard integration
6. **`frontend/src/components/MeldenForm.jsx`** - Enhanced input attributes
7. **`dashboard/index.html`** - Touch-friendly viewport
8. **`dashboard/src/index.css`** - Touch scrolling support

### New Files:
1. **`frontend/src/utils/virtualKeyboard.js`** - Virtual keyboard manager
2. **`RASPBERRY_PI_SETUP.md`** - Comprehensive setup guide
3. **`setup-rpi.sh`** - Automated setup script for Raspberry Pi

## Usage

### On Raspberry Pi 5:

1. **Clone and navigate to project:**
   ```bash
   cd /path/to/goapp
   ```

2. **Run the setup script:**
   ```bash
   chmod +x setup-rpi.sh
   ./setup-rpi.sh
   ```

3. **Start the application:**
   ```bash
   docker-compose up -d
   ```

4. **Access the app:**
   - Frontend: http://localhost:6789
   - Dashboard: http://localhost:6790

### Touch Gestures:
- **Swipe up/down** - Smooth scrolling through content
- **Tap input field** - Virtual keyboard appears automatically
- **Pinch zoom** - Allowed up to 5x (configurable)
- **Tap outside input** - Keyboard hides automatically

### Virtual Keyboard Options:
The setup script offers three keyboard choices:
- **Onboard** (Recommended) - Feature-rich with auto-show
- **Florence** - Simple and lightweight
- **Matchbox** - Minimal footprint

## CSS Properties Explained

### Touch Scrolling:
```css
-webkit-overflow-scrolling: touch;  /* Momentum scrolling on iOS/Safari */
overscroll-behavior-y: contain;      /* Prevent scroll chaining */
scroll-behavior: smooth;             /* Smooth scrolling animation */
```

### Touch Action:
```css
touch-action: pan-y pan-x;           /* Allow vertical/horizontal panning */
touch-action: manipulation;          /* Remove 300ms tap delay */
```

### User Selection:
```css
-webkit-user-select: none;           /* Prevent text selection during touch */
user-select: text;                   /* Allow selection in inputs */
```

### Tap Highlight:
```css
-webkit-tap-highlight-color: rgba(0, 0, 0, 0);  /* Remove tap flash */
```

## Virtual Keyboard API

### Automatic Usage:
The virtual keyboard manager automatically initializes and handles all input focus events.

### Manual Control:
```javascript
import virtualKeyboard from './utils/virtualKeyboard';

// Show keyboard for specific element
virtualKeyboard.showForElement(inputElement);

// Listen for keyboard events
window.addEventListener('virtualKeyboardShow', (e) => {
  console.log('Keyboard shown for:', e.detail.input);
});

window.addEventListener('virtualKeyboardHide', () => {
  console.log('Keyboard hidden');
});
```

### Input Optimization:
```javascript
import { VirtualKeyboardManager } from './utils/virtualKeyboard';

// Optimize an input field
VirtualKeyboardManager.optimizeInput(inputElement);
```

## Browser Configuration

### Chromium Flags for Best Performance:
1. Enable touch events: `chrome://flags/#touch-events`
2. Enable smooth scrolling: `chrome://flags/#smooth-scrolling`
3. Enable GPU acceleration: `chrome://flags/#ignore-gpu-blacklist`

### Kiosk Mode:
```bash
chromium-browser --kiosk --app=http://localhost:6789 \
  --touch-events=enabled \
  --disable-pinch \
  --noerrdialogs \
  --disable-infobars
```

## Troubleshooting

### Keyboard Doesn't Appear:
1. Check if keyboard daemon is running:
   ```bash
   ps aux | grep -E 'onboard|florence|matchbox'
   ```
2. Start keyboard manually:
   ```bash
   onboard &  # or florence --no-gnome &
   ```
3. Check browser console for errors

### Scrolling Not Smooth:
1. Verify CSS properties are applied (check DevTools)
2. Enable smooth scrolling in Chrome flags
3. Check if GPU acceleration is enabled
4. Reduce browser extensions that may interfere

### Touch Not Detected:
1. Verify touch events in browser:
   ```javascript
   document.addEventListener('touchstart', () => console.log('Touch works!'));
   ```
2. Check Chromium launch flags include `--touch-events=enabled`
3. Calibrate touchscreen: `xinput_calibrator`

### Screen Blanking:
1. Disable DPMS:
   ```bash
   xset s off
   xset -dpms
   xset s noblank
   ```
2. Add to autostart (handled by setup script)

## Performance Tips

### Optimize for Raspberry Pi:
1. **Reduce GPU memory if not needed:**
   ```bash
   sudo nano /boot/config.txt
   # Set: gpu_mem=128
   ```

2. **Disable unnecessary services:**
   ```bash
   sudo systemctl disable bluetooth
   sudo systemctl disable avahi-daemon
   ```

3. **Use hardware acceleration:**
   - Ensure Chromium uses GPU
   - Enable video decode acceleration

4. **Optimize Docker:**
   ```bash
   # Use lighter base images
   # Reduce container memory limits
   ```

## Testing

### Test Touch Scrolling:
1. Open the app on Raspberry Pi touchscreen
2. Swipe up/down on any scrollable content
3. Verify smooth momentum scrolling
4. Check no unwanted bounce effects

### Test Virtual Keyboard:
1. Navigate to "Melden" form
2. Tap on "Naam" input field
3. Verify keyboard appears automatically
4. Type some text
5. Tap outside or on another input
6. Verify keyboard behavior is correct

### Test in DevTools:
1. Open Chromium DevTools (F12)
2. Toggle device toolbar (Ctrl+Shift+M)
3. Select a touch device
4. Test touch events and scrolling

## Future Enhancements

Potential improvements:
- [ ] Custom keyboard layout for specific inputs
- [ ] Haptic feedback on touch (if hardware supports)
- [ ] Gesture support (swipe to go back, etc.)
- [ ] Offline keyboard support in PWA
- [ ] Voice input integration
- [ ] Multi-touch gesture recognition

## References

- [MDN: Touch Events](https://developer.mozilla.org/en-US/docs/Web/API/Touch_events)
- [CSS touch-action](https://developer.mozilla.org/en-US/docs/Web/CSS/touch-action)
- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
- [PWA Best Practices](https://web.dev/pwa-checklist/)

## Support

For issues or questions:
1. Check `RASPBERRY_PI_SETUP.md` for detailed setup instructions
2. Review browser console for errors
3. Test on different browsers (Chromium recommended)
4. Verify Raspberry Pi OS is up to date

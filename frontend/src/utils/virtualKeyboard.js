/**
 * Virtual Keyboard Handler for Raspberry Pi Touchscreen
 * 
 * This utility automatically triggers the on-screen keyboard when input fields are focused.
 * Compatible with Raspberry Pi OS (64-bit) virtual keyboard implementations like:
 * - onboard
 * - matchbox-keyboard
 * - wvkbd (Wayland Virtual Keyboard)
 */

class VirtualKeyboardManager {
  constructor() {
    this.isRaspberryPi = this.detectRaspberryPi();
    this.keyboardCommand = null;
    this.activeInput = null;
    this.init();
  }

  /**
   * Detect if running on Raspberry Pi
   */
  detectRaspberryPi() {
    // Check user agent for ARM/Linux indicators
    const ua = navigator.userAgent.toLowerCase();
    const isLinuxArm = ua.includes('linux') && (ua.includes('arm') || ua.includes('aarch64'));
    
    // Additional check via platform
    const isArmPlatform = navigator.platform.toLowerCase().includes('arm') || 
                          navigator.platform.toLowerCase().includes('linux');
    
    return isLinuxArm || isArmPlatform;
  }

  /**
   * Initialize keyboard handlers
   */
  init() {
    if (!this.isRaspberryPi) {
      console.log('Virtual Keyboard: Not running on Raspberry Pi, skipping initialization');
      return;
    }

    console.log('Virtual Keyboard: Initializing for Raspberry Pi');
    this.attachEventListeners();
  }

  /**
   * Attach event listeners to all input fields
   */
  attachEventListeners() {
    // Use event delegation for dynamic inputs
    document.addEventListener('focusin', (e) => {
      const target = e.target;
      
      // Check if focused element is an input or textarea
      if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') {
        this.activeInput = target;
        this.showKeyboard();
      }
    });

    document.addEventListener('focusout', (e) => {
      const target = e.target;
      
      // Only hide if we're leaving an input field and not going to another one
      if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') {
        // Small delay to check if focus moved to another input
        setTimeout(() => {
          const activeElement = document.activeElement;
          if (activeElement.tagName !== 'INPUT' && activeElement.tagName !== 'TEXTAREA') {
            this.hideKeyboard();
          }
        }, 100);
      }
    });
  }

  /**
   * Show the virtual keyboard
   */
  showKeyboard() {
    console.log('Virtual Keyboard: Attempting to show keyboard');
    
    // For Raspberry Pi, we need to trigger the OS-level keyboard
    // This is typically done via system commands, but from browser we can:
    // 1. Ensure the input is properly focused and in viewport
    // 2. Use proper input attributes that trigger mobile keyboards
    
    if (this.activeInput) {
      // Scroll input into view
      this.activeInput.scrollIntoView({ 
        behavior: 'smooth', 
        block: 'center',
        inline: 'nearest'
      });

      // Ensure input is focused
      this.activeInput.focus();

      // Add a visual indicator that keyboard should be active
      this.activeInput.classList.add('keyboard-active');

      // Dispatch a custom event that can be caught by parent apps or system
      const event = new CustomEvent('virtualKeyboardShow', {
        detail: { input: this.activeInput }
      });
      window.dispatchEvent(event);
    }
  }

  /**
   * Hide the virtual keyboard
   */
  hideKeyboard() {
    console.log('Virtual Keyboard: Hiding keyboard');
    
    if (this.activeInput) {
      this.activeInput.classList.remove('keyboard-active');
      this.activeInput = null;
    }

    // Dispatch custom event
    const event = new CustomEvent('virtualKeyboardHide');
    window.dispatchEvent(event);
  }

  /**
   * Programmatically show keyboard for a specific element
   */
  showForElement(element) {
    if (element && (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA')) {
      this.activeInput = element;
      element.focus();
      this.showKeyboard();
    }
  }

  /**
   * Add input mode attributes to optimize keyboard type
   */
  static optimizeInput(input) {
    if (!input) return;

    const type = input.type || 'text';
    
    // Set appropriate inputmode for better keyboard on touchscreens
    switch (type) {
      case 'email':
        input.setAttribute('inputmode', 'email');
        break;
      case 'tel':
        input.setAttribute('inputmode', 'tel');
        break;
      case 'number':
        input.setAttribute('inputmode', 'numeric');
        break;
      case 'url':
        input.setAttribute('inputmode', 'url');
        break;
      case 'search':
        input.setAttribute('inputmode', 'search');
        break;
      default:
        input.setAttribute('inputmode', 'text');
    }

    // Enable autocomplete where appropriate
    if (!input.hasAttribute('autocomplete')) {
      input.setAttribute('autocomplete', 'on');
    }

    // Add touch-friendly attributes
    input.setAttribute('enterkeyhint', 'done');
  }
}

// Create singleton instance
const virtualKeyboard = new VirtualKeyboardManager();

export default virtualKeyboard;
export { VirtualKeyboardManager };

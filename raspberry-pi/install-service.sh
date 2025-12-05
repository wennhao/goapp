#!/bin/bash
# Install GoApp Kiosk as a systemd service (alternative to autostart)

echo "Installing GoApp Kiosk Service..."

# Copy service file
sudo cp goapp-kiosk.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable goapp-kiosk.service

echo ""
echo "Service installed successfully!"
echo ""
echo "Commands:"
echo "  Start:   sudo systemctl start goapp-kiosk"
echo "  Stop:    sudo systemctl stop goapp-kiosk"
echo "  Status:  sudo systemctl status goapp-kiosk"
echo "  Logs:    sudo journalctl -u goapp-kiosk -f"
echo ""
echo "The service will start automatically on boot."

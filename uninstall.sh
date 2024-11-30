#!/bin/bash

# Variables
SERVICE_NAME="whispercpp.service"
SERVICE_USER="whispercpp"
SERVICE_GROUP="whispercpp"
APP_DIR="/opt/whispercpp"

# Stop and disable the systemd service
echo "Stopping and disabling systemd service..."
sudo systemctl stop "$SERVICE_NAME"
sudo systemctl disable "$SERVICE_NAME"

# Remove the systemd service file
if [ -f "/etc/systemd/system/$SERVICE_NAME" ]; then
    echo "Removing systemd service file..."
    sudo rm "/etc/systemd/system/$SERVICE_NAME"
fi

# Reload systemd daemon to apply changes
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Delete the user and group
if id -u "$SERVICE_USER" >/dev/null 2>&1; then
    echo "Deleting user: $SERVICE_USER..."
    sudo userdel "$SERVICE_USER"
fi

if getent group "$SERVICE_GROUP" >/dev/null 2>&1; then
    echo "Deleting group: $SERVICE_GROUP..."
    sudo groupdel "$SERVICE_GROUP"
fi

# Remove application directory
if [ -d "$APP_DIR" ]; then
    echo "Removing application directory: $APP_DIR..."
    sudo rm -rf "$APP_DIR"
fi

# Remove any logs and temporary files
LOG_DIR="$APP_DIR/logs"
TMP_AUDIO_DIR="$APP_DIR/tmp/audio"
if [ -d "$LOG_DIR" ]; then
    echo "Removing log directory: $LOG_DIR..."
    sudo rm -rf "$LOG_DIR"
fi

if [ -d "$TMP_AUDIO_DIR" ]; then
    echo "Removing temporary audio directory: $TMP_AUDIO_DIR..."
    sudo rm -rf "$TMP_AUDIO_DIR"
fi

echo "Uninstallation complete!"


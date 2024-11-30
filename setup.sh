#!/bin/bash

# Variables
SERVICE_USER="whispercpp"
SERVICE_GROUP="whispercpp"
APP_DIR="/opt/whispercpp"
SERVICE_NAME="whispercpp.service"
ENV_FILE="$APP_DIR/.env"
DEFAULT_PORT="8080"
DEFAULT_MODEL_PATH="$APP_DIR/models/ggml-base.bin"
LOG_FILE="$APP_DIR/logs/whispercpp.log"
TMP_AUDIO_DIR="$APP_DIR/tmp/audio"

# Create user and group if they do not exist
if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
    echo "Creating user and group: $SERVICE_USER"
    sudo groupadd "$SERVICE_GROUP"
    sudo useradd -r -g "$SERVICE_GROUP" -d "$APP_DIR" -s /usr/sbin/nologin "$SERVICE_USER"

    # Verify user and group creation
    if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
        echo "Error: Failed to create user $SERVICE_USER."
        exit 1
    fi

    if ! getent group "$SERVICE_GROUP" >/dev/null 2>&1; then
        echo "Error: Failed to create group $SERVICE_GROUP."
        exit 1
    fi
else
    echo "User $SERVICE_USER already exists."
fi

# Set up application directory
echo "Setting up application directory: $APP_DIR"
sudo mkdir -p "$APP_DIR"
sudo mkdir -p "$APP_DIR/models" "$APP_DIR/logs" "$TMP_AUDIO_DIR"
sudo chown -R "$SERVICE_USER:$SERVICE_GROUP" "$APP_DIR"

# Move application files to the application directory (adjust paths as needed)
echo "Moving application files to $APP_DIR"
sudo cp -r /path/to/whisper.cpp "$APP_DIR"
sudo chown -R "$SERVICE_USER:$SERVICE_GROUP" "$APP_DIR"

# Verify directory ownership
if [ "$(stat -c '%U' $APP_DIR)" != "$SERVICE_USER" ]; then
    echo "Error: Ownership of $APP_DIR is not set to $SERVICE_USER."
    exit 1
fi

# Create a default .env file if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating .env file with default values"
    sudo bash -c "cat > $ENV_FILE" <<EOF
# Configuration for Whisper.cpp server

# Server Configuration
WHISPERCPP_PORT=$DEFAULT_PORT
WHISPERCPP_MODEL=$DEFAULT_MODEL_PATH

# User and Group Configuration
WHISPERCPP_USER=$SERVICE_USER
WHISPERCPP_GROUP=$SERVICE_GROUP

# Logging Configuration
WHISPERCPP_LOG_LEVEL=info
WHISPERCPP_LOG_FILE=$LOG_FILE

# Audio Configuration
WHISPERCPP_AUDIO_DEVICE=default
WHISPERCPP_SAMPLE_RATE=16000

# Paths for Additional Dependencies
WHISPERCPP_FFMPEG_BIN=/usr/bin/ffmpeg
WHISPERCPP_AUDIO_TMP_DIR=$TMP_AUDIO_DIR
EOF
    sudo chown "$SERVICE_USER:$SERVICE_GROUP" "$ENV_FILE"
fi

# Create systemd service
echo "Setting up systemd service: $SERVICE_NAME"
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME" <<EOF
[Unit]
Description=Whisper.cpp Server (Nix Isolated)
After=network.target

[Service]
Type=simple
EnvironmentFile=$ENV_FILE
ExecStart=/nix/store/.../bin/nix-shell $APP_DIR/default.nix --run "\
  $APP_DIR/examples/server/server \
  --port \$WHISPERCPP_PORT \
  --model \$WHISPERCPP_MODEL \
  --log-file \$WHISPERCPP_LOG_FILE \
  --log-level \$WHISPERCPP_LOG_LEVEL"
User=$SERVICE_USER
Group=$SERVICE_GROUP
WorkingDirectory=$APP_DIR
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Verify systemd service creation
if [ ! -f "/etc/systemd/system/$SERVICE_NAME" ]; then
    echo "Error: Failed to create systemd service file."
    exit 1
fi

# Reload systemd and enable service
echo "Reloading systemd daemon and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

# Verify systemd enablement
if ! systemctl is-enabled "$SERVICE_NAME" >/dev/null 2>&1; then
    echo "Error: Failed to enable $SERVICE_NAME."
    exit 1
fi

echo "Setup complete. Start the service with: sudo systemctl start $SERVICE_NAME"

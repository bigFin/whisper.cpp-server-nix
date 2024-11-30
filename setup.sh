#!/bin/bash

# Variables
SERVICE_NAME="whispercpp.service"
SERVICE_USER="whispercpp"
SERVICE_GROUP="whispercpp"
HOST_USER=$(whoami)  # Host user running the setup script
APP_DIR=$(pwd)  # Should resolve to /SSD500/Code/llm/whisper.cpp/whisper-server
RUN_SERVER_SCRIPT="$APP_DIR/run_server.sh"
ENV_FILE="$APP_DIR/.env"

# Ensure run_server.sh exists
if [ ! -f "$RUN_SERVER_SCRIPT" ]; then
  echo "Error: $RUN_SERVER_SCRIPT not found. Ensure the script is in $APP_DIR."
  exit 1
fi

# Make run_server.sh executable
chmod +x "$RUN_SERVER_SCRIPT"

# Create user and group if they do not exist
if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
  echo "Creating user and group: $SERVICE_USER"
  sudo groupadd "$SERVICE_GROUP"
  sudo useradd -r -g "$SERVICE_GROUP" -d "$APP_DIR" -s /usr/sbin/nologin "$SERVICE_USER"
fi

# Add host user to the whispercpp group for shared access
echo "Adding $HOST_USER to $SERVICE_GROUP group."
sudo usermod -aG "$SERVICE_GROUP" "$HOST_USER"

# Add the whispercpp user to the nixbld group for Nix daemon access
if getent group nixbld >/dev/null; then
  echo "Adding $SERVICE_USER to the nixbld group for Nix daemon access."
  sudo usermod -aG nixbld "$SERVICE_USER"
else
  echo "The nixbld group does not exist. Granting direct ACL permissions."
  sudo setfacl -m u:$SERVICE_USER:rwx /nix/var/nix/daemon-socket/socket
fi

# Set up application directory
echo "Setting up application directory: $APP_DIR"
sudo chown -R "$SERVICE_USER:$SERVICE_GROUP" "$APP_DIR"

# Grant group write permissions to the directory and ensure the host user can access it
sudo chmod -R g+rwX "$APP_DIR"
sudo setfacl -R -m u:$HOST_USER:rwx "$APP_DIR"
sudo setfacl -R -m g:$SERVICE_GROUP:rwx "$APP_DIR"

# Create a default .env file if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
  echo "Creating .env file with default values"
  sudo bash -c "cat > $ENV_FILE" <<EOF
# Configuration for Whisper.cpp server

# Server Configuration
WHISPERCPP_PORT=8080
WHISPERCPP_MODEL=../models/ggml-base.en.bin  # Adjusted to match working path

# Logging Configuration
WHISPERCPP_LOG_FILE=$APP_DIR/logs/whispercpp.log

# Audio Configuration
WHISPERCPP_AUDIO_TMP_DIR=$APP_DIR/tmp/audio
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
ExecStart=$RUN_SERVER_SCRIPT
User=$SERVICE_USER
Group=$SERVICE_GROUP
WorkingDirectory=$APP_DIR
EnvironmentFile=$ENV_FILE
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
echo "Reloading systemd daemon and enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

echo "Setup complete. Start the service with: sudo systemctl start $SERVICE_NAME"

#!/bin/bash
# Constants
SERVICE_NAME="whispercpp.service"
TEST_AUDIO="../samples/jfk.mp3"
CONVERTED_AUDIO="/tmp/test_audio.wav"  # Temporary WAV file for testing
SERVER_URL="http://127.0.0.1:8080/inference"  # Correct endpoint

# Restart the systemd service
echo "Restarting $SERVICE_NAME..."
sudo systemctl restart "$SERVICE_NAME"

# Print the systemd service status
echo "Checking $SERVICE_NAME status..."
sudo systemctl status "$SERVICE_NAME"

# Allow time for the server to start
echo "Waiting for the server to start..."
sleep 2

# Convert MP3 to WAV
echo "Converting $TEST_AUDIO to WAV format..."
ffmpeg -i "$TEST_AUDIO" -ar 16000 -ac 1 "$CONVERTED_AUDIO" -y >/dev/null 2>&1 || {
  echo "Error: Failed to convert $TEST_AUDIO to WAV format."
  exit 1
}

# Perform the curl test
echo "Testing server with $CONVERTED_AUDIO..."
curl -X POST \
  -H "Accept: application/json" \
  -F "file=@$CONVERTED_AUDIO" \
  "$SERVER_URL" || {
  echo "Error: Failed to connect to the server. Ensure it is running and accessible at $SERVER_URL."
  exit 1
}

# Cleanup temporary WAV file
rm -f "$CONVERTED_AUDIO"

echo "Quickstart complete!"

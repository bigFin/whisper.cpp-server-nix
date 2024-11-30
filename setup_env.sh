#!/usr/bin/env bash

echo "Entering Whisper.cpp environment..."

# Load variables from .env if it exists
if [ -f .env ]; then
  echo "Loading variables from .env"
  while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
    export "$line"
  done < .env
else
  echo ".env file not found. Using defaults."
fi

# Display configuration with shell defaults
echo "Port: ${WHISPERCPP_PORT:-8080}"
echo "Model: ${WHISPERCPP_MODEL:-./models/ggml-base.en.bin}"
echo "Log file: ${WHISPERCPP_LOG_FILE:-./logs/whispercpp.log}"
echo "Audio temp dir: ${WHISPERCPP_AUDIO_TMP_DIR:-./tmp/audio}"


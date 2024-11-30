#!/bin/bash

# Set nix-shell path explicitly
NIX_SHELL_PATH="/nix/var/nix/profiles/default/bin/nix-shell"
SHELL_NIX_FILE="$PWD/shell.nix"
SERVER_BINARY="$PWD/../server"

# Check if nix-shell exists
if [ ! -x "$NIX_SHELL_PATH" ]; then
  echo "Error: nix-shell not found at $NIX_SHELL_PATH"
  exit 1
fi

# Check if shell.nix exists
if [ ! -f "$SHELL_NIX_FILE" ]; then
  echo "Error: shell.nix not found at $SHELL_NIX_FILE"
  exit 1
fi

# Check if server binary exists
if [ ! -x "$SERVER_BINARY" ]; then
  echo "Error: Server binary not found or not executable at $SERVER_BINARY"
  exit 1
fi

# Load environment variables from .env
if [ -f .env ]; then
  set -a
  source .env
  set +a
else
  echo "Warning: .env file not found. Using default values."
fi

# Ensure default values for critical variables
WHISPERCPP_PORT=${WHISPERCPP_PORT:-8080}
WHISPERCPP_MODEL=${WHISPERCPP_MODEL:-models/ggml-base.en.bin}
WHISPERCPP_PUBLIC_PATH=${WHISPERCPP_PUBLIC_PATH:-examples/server/public}
WHISPERCPP_INFERENCE_PATH=${WHISPERCPP_INFERENCE_PATH:-/inference}

# Execute nix-shell and run the server with appropriate arguments
exec "$NIX_SHELL_PATH" "$SHELL_NIX_FILE" --run "\
  $SERVER_BINARY \
  --host 127.0.0.1 \
  --port $WHISPERCPP_PORT \
  --model $WHISPERCPP_MODEL \
  --public $WHISPERCPP_PUBLIC_PATH \
  --inference-path $WHISPERCPP_INFERENCE_PATH"

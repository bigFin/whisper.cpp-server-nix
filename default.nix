{ pkgs ? import <nixpkgs> {} }:

let
  dotenv = pkgs.writeScriptBin "dotenv" ''
    #!/usr/bin/env bash
    # Load variables from .env and export them
    if [ -f .env ]; then
      export $(grep -v '^#' .env | xargs)
    fi
  '';
in
pkgs.mkShell {
  buildInputs = [
    pkgs.gcc
    pkgs.cmake
    pkgs.libstdcxx
    pkgs.python3
    pkgs.ffmpeg
    pkgs.alsa-utils
    pkgs.portaudio
    pkgs.sox
    dotenv
  ];

  shellHook = ''
    echo "Entering Whisper.cpp environment..."

    # Load .env if present
    dotenv

    # Fall back to default values if .env variables are not set
    export WHISPERCPP_PORT=${WHISPERCPP_PORT:-8080}
    export WHISPERCPP_MODEL=${WHISPERCPP_MODEL:-./models/ggml-base.bin}
    export WHISPERCPP_LOG_FILE=${WHISPERCPP_LOG_FILE:-./logs/whispercpp.log}
    export WHISPERCPP_AUDIO_TMP_DIR=${WHISPERCPP_AUDIO_TMP_DIR:-./tmp/audio}

    # Display environment settings
    echo "Using port: $WHISPERCPP_PORT"
    echo "Using model: $WHISPERCPP_MODEL"
    echo "Log file: $WHISPERCPP_LOG_FILE"
    echo "Audio temp directory: $WHISPERCPP_AUDIO_TMP_DIR"
  '';
}

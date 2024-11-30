# Whisper.cpp Setup with Nix Shell and Systemd Service

## Overview
This repository contains scripts and configurations to set up the Whisper.cpp server using a Nix shell for isolation. It creates a dedicated system user and configures a systemd service to manage the server process.

## Prerequisites
- Nix package manager installed
- Whisper.cpp repository cloned locally
- Root or sudo privileges

## Setup
1. Clone this repository and create a symlink to `whisper.cpp/examples/server`:
   ```bash
   ln -s /path/to/this/repo /path/to/whisper.cpp/examples/server/whisper-server

    Navigate to the setup directory and run the setup script:

    cd /path/to/whisper.cpp/examples/server/whisper-server
    sudo ./setup.sh

Configuration

Modify /opt/whispercpp/.env to adjust runtime parameters:

WHISPERCPP_PORT=8080
WHISPERCPP_MODEL=/opt/whispercpp/models/ggml-base.bin
WHISPERCPP_LOG_LEVEL=info
WHISPERCPP_LOG_FILE=/opt/whispercpp/logs/whispercpp.log
WHISPERCPP_AUDIO_TMP_DIR=/opt/whispercpp/tmp/audio

Apply changes by restarting the service:

sudo systemctl restart whispercpp.service

Usage

    Start the service:

sudo systemctl start whispercpp.service

Stop the service:

sudo systemctl stop whispercpp.service

Check status:

    sudo systemctl status whispercpp.service

Uninstallation

Run the provided uninstall script to remove the systemd service, system user, and associated files:

sudo ./uninstall.sh

Notes

    Default installation directory: /opt/whispercpp
    System user: whispercpp
    Ensure Whisper.cpp is built and ready before running setup.

Troubleshooting

Verify user and group:

    id whispercpp

Check logs:

    journalctl -u whispercpp.service -f


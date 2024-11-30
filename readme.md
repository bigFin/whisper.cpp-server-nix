# Whisper.cpp Server (Nix Isolated)

## TL;DR

1. Clone this repository into the root of `whisper.cpp`:

   ```bash
   git clone <repo-url> whisper.cpp/whisper-server
   ```

2. Run `setup.sh` to configure the server:

   ```bash
   cd whisper.cpp/whisper-server
   ./setup.sh
   ```

3. Test the server with `quickstart.sh`:

   ```bash
   ./quickstart.sh
   ```

## Overview

This project sets up a secure, isolated server for Whisper.cpp using nix-shell and systemd.

## Features

- Isolated execution via nix-shell
- Minimal-privilege whispercpp user
- Automatic MP3-to-WAV conversion using ffmpeg
- Preconfigured `.env` file for server settings

## Structure

- **setup.sh**: Installs dependencies, creates whispercpp user, and sets up the systemd service.
- **quickstart.sh**: Restarts the server, checks its status, and tests it with a sample audio file.
- **.env**: Configurable server parameters (e.g., port, model path).

## Prerequisites

- Nix package manager (multi-user installation)
- Systemd

## Customization

Edit `.env` to adjust server parameters like port, model path, or log locations.

```bash
WHISPERCPP_PORT=8080
WHISPERCPP_MODEL=../models/ggml-base.en.bin
WHISPERCPP_LOG_FILE=logs/whispercpp.log
WHISPERCPP_AUDIO_TMP_DIR=tmp/audio
```

## Maintenance

To restart the server:

```bash
sudo systemctl restart whispercpp.service
```

To check server logs:

```bash
sudo journalctl -u whispercpp.service
```

To uninstall:

```bash
./uninstall.sh
```

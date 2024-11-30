# Whisper.cpp Server (Nix Isolated)
This project sets up a secure, isolated server for Whisper.cpp using nix-shell and systemd using bash. 

- whisper.cpp server https://github.com/ggerganov/whisper.cpp/tree/master/examples/server 

## TL;DR


1. Clone `whisper.cpp`:

   ```bash
   git clone https://github.com/ggerganov/whisper.cpp/tree/master
   ```
2. Clone this repository into the root of `whisper.cpp`:

   ```bash
   cd whisper.cpp
   git clone https://github.com/bigFin/whisper.cpp-server-nix-systemd
   ```

3. Run `setup.sh` to configure the server:

   ```bash
   cd whisper.cpp/whisper.cpp-server-nix-systemd
   ./setup.sh
   ```

4. Test the server with `quickstart.sh`:

   ```bash
   ./quickstart.sh
   ```


## Features

- Isolated execution via nix-shell
- Minimal-privilege whispercpp user
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

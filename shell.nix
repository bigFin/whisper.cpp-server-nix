{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.stdenv.cc
    pkgs.cmake
    pkgs.python3
    pkgs.ffmpeg
    pkgs.alsa-utils
    pkgs.portaudio
    pkgs.sox
    pkgs.bashInteractive
  ];

  # Reference an external script for the shell hook
  shellHook = ''
    bash ./setup_env.sh
  '';
}

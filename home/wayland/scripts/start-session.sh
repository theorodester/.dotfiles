#!/usr/bin/env bash

set -euo pipefail

wallpaper="$HOME/.dotfiles/wallpapers/shark_coral_background_1_upscale.jpg"

start_if_missing() {
  local process="$1"
  shift

  if ! pgrep -xu "$USER" "$process" >/dev/null 2>&1; then
    "$@" >/dev/null 2>&1 &
  fi
}

start_if_missing swww-daemon swww-daemon
sleep 0.2
swww img "$wallpaper" >/dev/null 2>&1 &

start_if_missing nm-applet nm-applet --indicator
start_if_missing blueman-applet blueman-applet
start_if_missing swayidle swayidle -w before-sleep 'swaylock -f'
start_if_missing mako mako

"$HOME/.dotfiles/home/wayland/scripts/start-waybar.sh" >/dev/null 2>&1 &

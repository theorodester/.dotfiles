#!/usr/bin/env bash

set -euo pipefail

config_dir="$HOME/.config/waybar"
style="$config_dir/style.css"
config="$config_dir/hyprland.json"

if [[ -n "${NIRI_SOCKET:-}" ]]; then
  config="$config_dir/niri.json"
elif [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  case "${XDG_CURRENT_DESKTOP:-}" in
    *niri*|*Niri*)
      config="$config_dir/niri.json"
      ;;
  esac
fi

pkill -xu "$USER" waybar >/dev/null 2>&1 || true
exec waybar -c "$config" -s "$style"

#!/usr/bin/env bash
# Removes the app, its launcher entry and (optionally) the saved profile.
set -euo pipefail

APP_DIR="${APP_DIR:-$HOME/.local/opt/netflix-desktop}"
DESKTOP_DIR="$HOME/.local/share/applications"

rm -rf "$APP_DIR"
rm -f "$DESKTOP_DIR/netflix-desktop.desktop"
update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true

if [[ "${1:-}" == "--purge" ]]; then
  rm -rf "$HOME/.config/Netflix"
  echo "Removed app and profile."
else
  echo "Removed app. Profile kept at ~/.config/Netflix (use --purge to delete)."
fi

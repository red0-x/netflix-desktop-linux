#!/usr/bin/env bash
# Installs a standalone Netflix desktop app: a small Electron wrapper around
# netflix.com using a Widevine-enabled Electron build (castlabs).
#
# No root required. Everything lands under $HOME.
set -euo pipefail

ELECTRON_VERSION="${ELECTRON_VERSION:-42.11.10+wvcus}"
APP_DIR="${APP_DIR:-$HOME/.local/opt/netflix-desktop}"
DESKTOP_DIR="$HOME/.local/share/applications"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/src"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

case "$(uname -m)" in
  x86_64 | amd64) ARCH=x64 ;;
  *) die "only x86_64 is supported (castlabs publishes no other Linux build)" ;;
esac

command -v curl >/dev/null || die "curl is required"
command -v unzip >/dev/null || die "unzip is required"

URL="https://github.com/castlabs/electron-releases/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-${ARCH}.zip"

echo "Downloading Electron ${ELECTRON_VERSION} (Widevine build)..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fL --progress-bar -o "$TMP/electron.zip" "$URL"
unzip -q "$TMP/electron.zip" -d "$TMP/electron"

echo "Installing to $APP_DIR"
mkdir -p "$APP_DIR"
cp -a "$TMP/electron/." "$APP_DIR/"

# Replace the bundled default app with the Netflix wrapper.
rm -rf "$APP_DIR/resources/app"
mkdir -p "$APP_DIR/resources/app"
cp "$SOURCE_DIR/package.json" "$SOURCE_DIR/main.js" "$APP_DIR/resources/app/"
chmod +x "$APP_DIR/electron"

mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/netflix-desktop.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Netflix
GenericName=Streaming Video
Comment=Netflix in a standalone window (Widevine DRM)
Exec=$APP_DIR/electron %U
Icon=video-display
Terminal=false
Categories=AudioVideo;Video;Player;
StartupWMClass=Netflix
StartupNotify=true
EOF

update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true

echo
echo "Done. Launch \"Netflix\" from your app menu, or run:"
echo "  $APP_DIR/electron"
echo
echo "First launch downloads the Widevine CDM (a few seconds). Playback"
echo "starts after that. Your login is kept in ~/.config/Netflix."

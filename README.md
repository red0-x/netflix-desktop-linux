# netflix-desktop-linux

A standalone Netflix window for Linux.

Netflix has never shipped a Linux client, and the website often fails in
distro browsers because they lack Google's Widevine CDM. This is a ~70 line
Electron wrapper around `netflix.com` that runs on a Widevine-enabled Electron
build, so playback works with no browser extension, no PPA, and no root.

![type](https://img.shields.io/badge/platform-linux%20x86__64-informational)
![license](https://img.shields.io/badge/license-MIT-blue)

## What you get

- Its own window, icon, and launcher entry. No tabs, no address bar.
- Persistent login (`~/.config/Netflix`).
- External links open in your normal browser.
- Single instance: launching it again focuses the existing window.
- Widevine CDM installed automatically on first launch by the Electron
  component updater.

## Requirements

- Linux x86_64 (castlabs publishes no other Linux build)
- `curl` and `unzip`
- An active Netflix subscription

No root, no system packages, no Flatpak, no Snap.

## Install

```sh
git clone https://github.com/red0-x/netflix-desktop-linux
cd netflix-desktop-linux
./install.sh
```

Then launch **Netflix** from your app menu, or run:

```sh
~/.local/opt/netflix-desktop/electron
```

The first launch downloads the Widevine CDM. Give it a few seconds before the
first playback.

### Custom location / Electron version

```sh
APP_DIR=$HOME/Apps/netflix ELECTRON_VERSION=42.11.10+wvcus ./install.sh
```

## Uninstall

```sh
./uninstall.sh
```

Removes the app and its launcher entry. Your profile (`~/.config/Netflix`) is
left alone unless you pass `--purge`.

## How it works

Stock Electron ships no Widevine CDM, so DRM video returns
`NotSupportedError`. [castlabs' Electron releases](https://github.com/castlabs/electron-releases)
add the CDM through Chromium's component updater under the `wvcus` label.

`src/main.js` does three things worth knowing:

1. Calls `components.whenReady()` so the CDM is installed promptly instead of
   on the updater's delayed timer.
2. Strips the `Electron/x.y.z` and app-name tokens from the user agent, which
   otherwise trips up site feature detection.
3. Denies and forwards non-Netflix popups to the system browser.

## Troubleshooting

**Video shows an error or stays black.** The CDM may not have finished
installing. Quit the app, delete `~/.config/Netflix`, relaunch and wait a few
seconds.

**No window on Wayland.** Some compositors report incomplete image
descriptions. Try `--ozone-platform=x11`:

```sh
~/.local/opt/netflix-desktop/electron --ozone-platform=x11
```

**Blank page with VA-API errors.** The GPU stack is unhealthy rather than the
app; `--disable-gpu` will confirm it.

## Notes

- Resolution is limited by what Widevine L3 permits on Linux.
- No icon is bundled: the launcher uses the `video-display` theme icon. Drop a
  PNG at `<app dir>/resources/app/icon.png` to override it.

## Disclaimer

Unofficial. Not affiliated with, endorsed by, or supported by Netflix or
Google. No Netflix assets, no DRM keys, and no Electron binaries are
distributed here; the installer downloads Electron directly from castlabs.
You are responsible for complying with Netflix's terms of service in your
jurisdiction.

MIT licensed.

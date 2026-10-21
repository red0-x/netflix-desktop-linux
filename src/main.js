const { app, components, BrowserWindow, Menu, shell, session } = require('electron');
const fs = require('fs');
const path = require('path');

const HOME_URL = 'https://www.netflix.com/browse';

app.setName('Netflix');

if (!app.requestSingleInstanceLock()) {
  app.quit();
}

let win = null;

function cleanUserAgent() {
  return app.userAgentFallback
    .replace(/\s*\b(?:netflix-desktop|Netflix|Electron)\/[\w.+-]+/gi, '')
    .replace(/\s{2,}/g, ' ')
    .trim();
}

function createWindow() {
  win = new BrowserWindow({
    width: 1440,
    height: 900,
    minWidth: 800,
    minHeight: 500,
    backgroundColor: '#000000',
    autoHideMenuBar: true,
    title: 'Netflix',
    icon: fs.existsSync(path.join(__dirname, 'icon.png'))
      ? path.join(__dirname, 'icon.png')
      : undefined,
  });

  const ua = cleanUserAgent();
  win.webContents.setUserAgent(ua);
  session.defaultSession.setUserAgent(ua);

  win.loadURL(HOME_URL);

  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.includes('netflix.com')) return { action: 'allow' };
    shell.openExternal(url);
    return { action: 'deny' };
  });

  win.on('closed', () => { win = null; });
}

app.on('second-instance', () => {
  if (win) {
    if (win.isMinimized()) win.restore();
    win.show();
    win.focus();
  }
});

app.whenReady().then(() => {
  Menu.setApplicationMenu(null);

  // wvcus builds install the Widevine CDM through the component updater.
  // Triggering it now means the CDM is there before the player needs it.
  components
    .whenReady()
    .then((comps) => console.error('widevine ready', JSON.stringify(comps)))
    .catch((e) => console.error('widevine error', e && e.message));

  createWindow();
});

app.on('window-all-closed', () => app.quit());

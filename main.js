const { app, BrowserWindow, shell, Menu, ipcMain, nativeTheme, session, protocol } = require('electron');
const path = require('path');
const fs = require('fs');
const http = require('http');
const crypto = require('crypto');

const WEBUI_URL = 'http://127.0.0.1:8082';
const APP_TITLE = 'DeepSeek Harness';
const DSH_HOME = process.env.DSH_HOME || path.join(require('os').homedir(), '.dsh');
const LOG_FILE = 'D:\\dsh\\harness-shell\\dsh-shell.log';
const WEB_FRONTEND = path.join(__dirname, 'web-frontend');

let mainWindow;
let logStream;
let hostUrl = null;
let hostCookie = null;

function log(msg) {
  try {
    const timestamp = new Date().toISOString();
    const line = `[${timestamp}] ${msg}\n`;
    if (logStream) {
      logStream.write(line);
    }
  } catch (e) {
    // ignore logging errors
  }
}

function getCredentialsSecret() {
  try {
    const credPath = path.join(DSH_HOME, '.credentials.yaml');
    const content = fs.readFileSync(credPath, 'utf8');
    const match = content.match(/secret:\s*([^\s\n]+)/);
    if (match) return match[1].trim();
  } catch (e) {
    log('Failed to read credentials: ' + e.message);
  }
  return null;
}

function base64UrlEncode(buffer) {
  return buffer.toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function generateAuthCookie(authority, secretBase64Url) {
  const secret = Buffer.from(secretBase64Url.replace(/-/g, '+').replace(/_/g, '/'), 'base64');
  const now = Date.now();
  const expiresAt = now + (30 * 24 * 60 * 60 * 1000);
  const payload = {
    version: 1,
    authority: authority,
    issuedAt: now,
    expiresAt: expiresAt
  };
  const payloadJson = JSON.stringify(payload);
  const payloadBytes = Buffer.from(payloadJson, 'utf8');
  const body = base64UrlEncode(payloadBytes);
  const signature = crypto.createHmac('sha256', secret)
    .update(body)
    .digest();
  const signatureEncoded = base64UrlEncode(signature);
  return {
    cookieName: 'dsh-auth-' + base64UrlEncode(crypto.createHash('sha256').update(authority).digest()),
    cookieValue: `v1.${body}.${signatureEncoded}`,
    expiresAt
  };
}

async function checkWebUIAuth() {
  return new Promise((resolve) => {
    const url = new URL(WEBUI_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: '/',
      method: 'HEAD',
      timeout: 3000
    };
    const req = http.request(options, (res) => {
      resolve({ running: true, authenticated: res.statusCode === 200 });
    });
    req.on('error', () => resolve({ running: false, authenticated: false }));
    req.on('timeout', () => { req.destroy(); resolve({ running: false, authenticated: false }); });
    req.end();
  });
}

async function startWebUI() {
  const { spawn } = require('child_process');
  const dshScript = path.join(process.env.APPDATA, 'npm', 'dsh.ps1');
  const nodeExe = 'D:\\nodejs26\\node.exe';

  const child = spawn(nodeExe, [dshScript, '--profile', 'web', '--no-open', '--port', '8082'], {
    stdio: 'ignore'
  });
  child.unref();

  for (let i = 0; i < 30; i++) {
    await new Promise(r => setTimeout(r, 1000));
    const status = await checkWebUIAuth();
    if (status.running) return status;
  }
  return { running: true, authenticated: false };
}

async function authenticateWebHost(url) {
  // Use cookie-based auth instead of token exchange
  const secret = getCredentialsSecret();
  if (!secret) throw new Error('No credentials secret found');
  
  const { cookieName, cookieValue } = generateAuthCookie('127.0.0.1:8082', secret);
  hostCookie = cookieName + '=' + cookieValue;
  hostUrl = WEBUI_URL;
  return hostCookie;
}

const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf'
};

function createLocalServer(port) {
  const http = require('http');
  const server = http.createServer(async (req, res) => {
    try {
      let urlPath = decodeURIComponent(req.url.split('?')[0]);
      if (urlPath.startsWith('/shell/')) urlPath = urlPath.slice('/shell'.length);
      const target = path.join(WEB_FRONTEND, urlPath === '/' ? '/index.html' : urlPath);
      
      if (!target.startsWith(WEB_FRONTEND)) {
        res.writeHead(403);
        res.end();
        return;
      }
      
      const body = await fs.promises.readFile(target);
      const ext = path.extname(target);
      const contentType = MIME_TYPES[ext] || 'application/octet-stream';
      res.writeHead(200, { 'content-type': contentType });
      res.end(body);
    } catch (error) {
      if (error.code === 'ENOENT') {
        res.writeHead(404);
        res.end();
      } else {
        res.writeHead(500);
        res.end();
      }
    }
  });
  
  server.listen(port, () => {
    log('Local server started on port ' + port);
  });
  
  return server;
}

async function serveWebDocument(request, root) {
  if (!['GET', 'HEAD'].includes(request.method)) return new Response('<html><body>405</body></html>', { status: 405, headers: { 'content-type': 'text/html' } });
  const url = new URL(request.url);
  let pathname;
  try {
    pathname = decodeURIComponent(url.pathname);
  } catch {
    return new Response('<html><body>400</body></html>', { status: 400, headers: { 'content-type': 'text/html' } });
  }

  // Suppress favicon.ico download
  if (pathname === '/favicon.ico') {
    return new Response(null, { status: 204 });
  }

  const target = path.join(root, pathname === '/' ? '/index.html' : pathname);
  const ext = pathname === '/' ? '.html' : path.extname(pathname);

  // Security: prevent directory traversal
  if (!target.startsWith(root)) return new Response('<html><body>403</body></html>', { status: 403, headers: { 'content-type': 'text/html' } });

  let body;
  try {
    body = await fs.promises.readFile(target);
  } catch (error) {
    if (error.code === 'ENOENT') {
      // Return a proper HTML error page instead of empty response
      const errorHtml = '<html><body>404 - Not Found</body></html>';
      return new Response(request.method === 'HEAD' ? null : errorHtml, {
        status: 404,
        headers: { 'content-type': 'text/html' }
      });
    }
    throw error;
  }

  const contentType = MIME_TYPES[ext] || 'application/octet-stream';
  return new Response(request.method === 'HEAD' ? null : body, {
    headers: { 'content-type': contentType }
  });
}

function createLocalServer(port) {
  const http = require('http');
  const server = http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');
    const target = path.join(WEB_FRONTEND, url.pathname === '/' ? '/index.html' : url.pathname);
    
    if (!target.startsWith(WEB_FRONTEND)) {
      res.writeHead(403);
      res.end();
      return;
    }
    
    try {
      const body = await fs.promises.readFile(target);
      const ext = path.extname(target);
      const contentType = MIME_TYPES[ext] || 'application/octet-stream';
      res.writeHead(200, { 'content-type': contentType });
      res.end(body);
    } catch (error) {
      if (error.code === 'ENOENT') {
        res.writeHead(404);
        res.end();
      } else {
        res.writeHead(500);
        res.end();
      }
    }
  });
  
  server.listen(port, () => {
    log('Local server started on port ' + port);
  });
  
  return server;
}

const WITHHELD_RESPONSE_HEADERS = [
  'set-cookie',
  'content-encoding',
  'content-length',
  'transfer-encoding',
  'connection',
  'keep-alive',
  'te',
  'trailer',
  'upgrade',
  'proxy-authenticate',
  'proxy-authorization'
];

const PLUGIN_BUNDLE_PATH = /^\/plugins\//u;
const WINDOWS_INSTALLER_PATH = /dsh-latest-windows-x64\.exe$/iu;
const DOWNLOAD_BLOCKED_PATTERNS = [
  /dsh-latest-windows-x64\.exe$/iu
];

function shouldBlockDownload(request, pathname) {
  const source = request.url || '';
  for (const pattern of DOWNLOAD_BLOCKED_PATTERNS) {
    if (pattern.test(source) || pattern.test(pathname)) return true;
  }
  return false;
}

async function forwardWebRequest(request, host, cookie) {
  const source = new URL(request.url);
  const origin = request.headers.get('origin');
  if (origin !== null && origin !== 'dsh-app://app') return new Response('<html><body>403</body></html>', { status: 403, headers: { 'content-type': 'text/html' } });

  const target = new URL(host);
  target.pathname = source.pathname;
  target.search = source.search;

  const headers = new Headers(request.headers);
  for (const name of ['host', 'origin', 'cookie', 'sec-fetch-site']) {
    headers.delete(name);
  }
  headers.set('cookie', cookie);

  const init = {
    method: request.method,
    headers,
    body: request.body,
    signal: request.signal,
    duplex: 'half',
    redirect: 'manual'
  };

  const response = await fetch(target, init);
  const outgoing = new Headers(response.headers);
  for (const name of WITHHELD_RESPONSE_HEADERS) outgoing.delete(name);
  if (PLUGIN_BUNDLE_PATH.test(source.pathname)) outgoing.set('cache-control', 'no-store');

  if (response.status === 200 && WINDOWS_INSTALLER_PATH.test(source.pathname)) {
    outgoing.delete('content-disposition');
    const payload = new Uint8Array([0x7b, 0x22, 0x73, 0x6b, 0x69, 0x70, 0x70, 0x65, 0x64, 0x22, 0x3a, 0x74, 0x72, 0x75, 0x65, 0x7d]);
    return new Response(payload, {
      status: 200,
      headers: { ...outgoing, 'content-type': 'application/json' }
    });
  }

  return new Response(response.body, {
    status: response.status,
    headers: outgoing
  });
}

async function setupProtocol() {
  await app.whenReady();
  
  protocol.handle('dsh-app', async (request) => {
    const url = new URL(request.url);
    const pathname = url.pathname;
    
    try {
      if (url.hostname === 'shell') {
        log('[protocol] shell: ' + pathname);
        return await serveWebDocument(request, path.join(app.getAppPath(), 'renderer'));
      }
      if (url.hostname === 'app') {
        // Forward root to WebUI server to get dynamic HTML
        if (pathname === '/' || pathname === '/index.html') {
          log('[protocol] forwarding root to WebUI');
          const response = await forwardWebRequest(request, hostUrl, hostCookie);
          if (response.status === 200 && response.headers.get('content-type')?.includes('text/html')) {
            let html = await response.text();
            return new Response(html, {
              status: 200,
              headers: {
                'content-type': 'text/html; charset=utf-8',
                'cache-control': 'no-store'
              }
            });
          }
          return response;
        }
        
        // Serve static files from web-frontend
        if (pathname.startsWith('/assets/') || 
            ['/favicon.svg', '/favicon.ico', '/manifest.webmanifest'].includes(pathname)) {
          log('[protocol] static: ' + pathname);
          return await serveWebDocument(request, WEB_FRONTEND);
        }
        
        // Forward API requests to WebUI
        if (hostUrl === null || hostCookie === null) {
          log('[protocol] no host for: ' + pathname);
          return new Response('<html><body>503</body></html>', { status: 503, headers: { 'content-type': 'text/html' } });
        }
        
        // Block known download paths
        if (shouldBlockDownload(request, pathname)) {
          log('[protocol] blocked: ' + pathname);
          return new Response(null, { status: 204 });
        }
        
        log('[protocol] forward: ' + pathname);
        return await forwardWebRequest(request, hostUrl, hostCookie);
      }
    } catch (e) {
      log('[protocol] error: ' + e.message);
      return new Response(null, { status: 500 });
    }
    
    const notFound = '<html><body>404</body></html>';
    log('[protocol] 404: ' + url.href);
    return new Response(notFound, { status: 404, headers: { 'content-type': 'text/html' } });
  });
}

function createWindow() {
  const isWin = process.platform === 'win32';
  const isDark = nativeTheme.shouldUseDarkColors;

  mainWindow = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    title: APP_TITLE,
    icon: path.join(__dirname, 'assets', 'icon.png'),
    autoHideMenuBar: true,
    ...(isWin ? {
      titleBarStyle: 'hidden',
      titleBarOverlay: {
        height: 40,
        color: isDark ? '#1b1b1c' : '#f9fafb',
        symbolColor: isDark ? '#f9fafb' : '#0f1115'
      }
    } : {}),
    ...(process.platform === 'darwin' ? {
      titleBarStyle: 'hiddenInset',
      trafficLightPosition: { x: 16, y: 18 },
      vibrancy: 'sidebar',
      visualEffectState: 'active',
      backgroundColor: '#00000000'
    } : {}),
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
      webSecurity: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  // Sync theme changes from the web UI
  ipcMain.on('dsh-desktop:native-theme-set', (event, source) => {
    if (source === 'light' || source === 'dark' || source === 'system') {
      nativeTheme.themeSource = source;
    }
    refreshApplicationMenu();
  });

  // Handle Windows appearance updates from the web UI
  ipcMain.on('dsh-desktop:windows-appearance', (event, language, color, symbolColor) => {
    if (mainWindow && !mainWindow.isDestroyed() && event.sender === mainWindow.webContents && event.senderFrame === mainWindow.webContents.mainFrame) {
      const validColor = (value) => typeof value === 'string' && /^(?:#[\da-f]{3,8}|rgba?\([\d.,%\s]+\))$/iu.test(value);
      if (validColor(color) && validColor(symbolColor)) {
        mainWindow.setTitleBarOverlay({ color, symbolColor });
      }
    }
  });

  // Handle Windows menu popup requests
  ipcMain.handle('dsh-desktop:windows-menu', (event, name, x, y) => {
    if (!mainWindow || mainWindow.isDestroyed() || event.sender !== mainWindow.webContents || event.senderFrame !== mainWindow.webContents.mainFrame) return;
    if (name !== 'application' && name !== 'edit' || typeof x !== 'number' || typeof y !== 'number' || !Number.isFinite(x) || !Number.isFinite(y) || x < 0 || y < 0 || x > 1e5 || y > 1e5) return;
    const window = mainWindow;
    const editItem = (label, keyCode, modifiers, accelerator) => ({
      label,
      ...accelerator === undefined ? {} : { accelerator },
      click: () => {
        mainWindow.webContents.send('dsh-desktop:shortcuts-input', { kind: 'keyboard', keyCode, modifiers });
      }
    });
    const items = name === 'application' ? [
      { label: 'Application', submenu: [
        { label: 'About DeepSeek Harness', click: () => {} },
        { type: 'separator' },
        { label: 'Exit', click: () => { app.quit(); } }
      ]},
      { label: 'Edit', submenu: [
        editItem('Undo', 'Z', ['control'], 'Ctrl+Z'),
        editItem('Redo', 'Y', ['control'], 'Ctrl+Y'),
        { type: 'separator' },
        editItem('Cut', 'X', ['control'], 'Ctrl+X'),
        editItem('Copy', 'C', ['control'], 'Ctrl+C'),
        editItem('Paste', 'V', ['control'], 'Ctrl+V'),
        { label: 'Delete', click: () => {} },
        { type: 'separator' },
        editItem('Select All', 'A', ['control'], 'Ctrl+A')
      ]}
    ] : [];
    const zoom = mainWindow.webContents.getZoomFactor();
    Menu.buildFromTemplate(items).popup({
      window,
      x: Math.round(x * zoom),
      y: Math.round(y * zoom)
    });
  });

  // Minimal shortcuts IPC to satisfy desktop plugins
  const assertDesktopSender = (event) => {
    const owner = mainWindow;
    if (owner === void 0 || event.sender !== owner.webContents || event.senderFrame !== owner.webContents.mainFrame) throw new Error('desktop: rejected sender');
    return owner;
  };

  ipcMain.handle('dsh-desktop:shortcuts-get', async (event, input) => {
    assertDesktopSender(event);
    return { status: 'ready', revision: '1', document: { definitions: [] } };
  });

  ipcMain.handle('dsh-desktop:shortcuts-edit', async (event, input, expectedRevision) => {
    assertDesktopSender(event);
    if (typeof expectedRevision !== 'string') throw new Error('shortcuts: invalid revision');
    return { status: 'ready', revision: expectedRevision, document: { definitions: [] } };
  });

  ipcMain.on('dsh-desktop:shortcuts-recording', (event, active) => {
    const window = assertDesktopSender(event);
    if (typeof active !== 'boolean') return;
    window.webContents.setIgnoreMenuShortcuts(active);
  });

  ipcMain.on('dsh-desktop:shortcuts-close-window', (event, expected) => {
    const window = assertDesktopSender(event);
    if (typeof expected !== 'string') return;
    window.close();
  });

  // Desktop boot API
  ipcMain.handle('dsh-desktop:boot', async (event) => {
    const window = assertDesktopSender(event);
    return {
      injections: [],
      streamBaseUrl: WEBUI_URL
    };
  });

  ipcMain.on('dsh-desktop:boot-failed', (event, message) => {
    const window = assertDesktopSender(event);
    log('Desktop boot failed: ' + message);
  });

  // Locale bootstrap
  ipcMain.handle('dsh-desktop:locale-bootstrap', async (event) => {
    const window = assertDesktopSender(event);
    return {
      languages: ['zh-CN', 'en-US'],
      preference: 'zh-CN'
    };
  });

  ipcMain.on('dsh-desktop:locale-changed', (event, next) => {
    const window = assertDesktopSender(event);
    if (typeof next !== 'string') return;
    log('Locale changed to: ' + next);
  });

  // Platform bridge stubs
  ipcMain.handle('dsh-platform:open', (event, page, bounds) => {
    const window = assertDesktopSender(event);
    log('Platform open: ' + page);
    return {};
  });

  ipcMain.handle('dsh-platform:bounds', (event, bounds) => {
    assertDesktopSender(event);
    return {};
  });

  ipcMain.handle('dsh-platform:close', (event) => {
    assertDesktopSender(event);
    return {};
  });

  startWebUI().then(async (status) => {
    log('WebUI status: ' + JSON.stringify(status));

    try {
      hostCookie = await authenticateWebHost(WEBUI_URL);
      log('Authenticated with host, cookie length: ' + hostCookie.length);
    } catch (e) {
      log('Host authentication failed: ' + e.message);
    }

    // Load dsh-app://app/
    log('Loading dsh-app://app/');
    mainWindow.loadURL('dsh-app://app/');
    
    // Forward renderer console to main log
    mainWindow.webContents.on('console-message', (event, level, message, line, sourceId) => {
      const prefix = level === 2 ? 'CONSOLE-ERROR' : level === 1 ? 'CONSOLE-WARN' : 'CONSOLE-LOG';
      log(`${prefix}: ${message} (${sourceId}:${line})`);
    });
    
    // Log navigation events
    mainWindow.webContents.on('did-start-navigation', (event, url, isInPlace, isMainFrame) => {
      if (isMainFrame) {
        log('Navigation: ' + url);
      }
    });
    
    mainWindow.webContents.on('did-navigate', (event, url) => {
      log('Navigated: ' + url);
    });
    
    mainWindow.webContents.on('did-navigate-in-page', (event, url) => {
      log('In-page navigation: ' + url);
    });
  });

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Only block the known DSH self-update installer; allow other downloads
  const BLOCKED_DOWNLOAD_PATTERN = /dsh-latest-windows-x64\.exe$/iu;
  mainWindow.webContents.on('will-download', (event, item, webContents) => {
    const url = item.getURL() || '';
    if (BLOCKED_DOWNLOAD_PATTERN.test(url)) {
      log('Blocked download: ' + url);
      event.preventDefault();
    }
  });

  session.defaultSession.on('will-download', (event, item, webContents) => {
    const url = item.getURL() || '';
    if (BLOCKED_DOWNLOAD_PATTERN.test(url)) {
      log('Blocked session download: ' + url);
      event.preventDefault();
    }
  });
  
  // Deny all permission requests (including download)
  session.defaultSession.setPermissionRequestHandler((_contents, _permission, callback) => {
    callback(false);
  });
  session.defaultSession.setPermissionCheckHandler(() => false);
  session.defaultSession.setDevicePermissionHandler(() => false);

  // Strip Content-Disposition headers to prevent forced downloads
  session.defaultSession.webRequest.onHeadersReceived({ urls: ['dsh-app://*/*', 'http://127.0.0.1:8082/*'] }, (details, callback) => {
    const headers = { ...details.responseHeaders };
    const cd = headers['content-disposition'] || headers['Content-Disposition'];
    if (cd) {
      log('Stripped Content-Disposition from: ' + details.url + ' (' + cd + ')');
      delete headers['content-disposition'];
      delete headers['Content-Disposition'];
    }
    callback({ responseHeaders: headers });
  });

  // Log all requests and responses to find download trigger
  session.defaultSession.webRequest.onBeforeRequest({ urls: ['*://*/*'] }, (details, callback) => {
    if (details.url.startsWith('dsh-app://') || details.url.startsWith('http://127.0.0.1:8082')) {
      log('REQ: ' + details.url + ' type=' + details.resourceType);
    }
    callback({});
  });

  session.defaultSession.webRequest.onBeforeSendHeaders({ urls: ['*://*/*'] }, (details, callback) => {
    if (details.url.startsWith('dsh-app://') || details.url.startsWith('http://127.0.0.1:8082')) {
      log('REQ-HEADERS: ' + details.url);
    }
    callback({ requestHeaders: details.requestHeaders });
  });

  session.defaultSession.webRequest.onHeadersReceived({ urls: ['*://*/*'] }, (details, callback) => {
    if (details.url.startsWith('dsh-app://') || details.url.startsWith('http://127.0.0.1:8082')) {
      log('RES: ' + details.statusCode + ' for ' + details.url);
      if (details.responseHeaders) {
        const ct = details.responseHeaders['content-type'] || details.responseHeaders['Content-Type'];
        const cd = details.responseHeaders['content-disposition'] || details.responseHeaders['Content-Disposition'];
        if (ct) log('  Content-Type: ' + ct);
        if (cd) log('  Content-Disposition: ' + cd);
      }
    }
    callback({ responseHeaders: details.responseHeaders });
  });

  // WebSocket auth injection for localhost
  session.defaultSession.webRequest.onBeforeSendHeaders({ urls: ['ws://127.0.0.1/*'] }, (details, callback) => {
    if (hostUrl === null || hostCookie === null) {
      callback({});
      return;
    }
    const target = new URL(hostUrl);
    if (new URL(details.url).host !== target.host) {
      callback({});
      return;
    }
    const headers = Object.fromEntries(Object.entries(details.requestHeaders).map(([name, value]) => [name.toLowerCase(), value]));
    if (headers.origin !== 'dsh-app://app') {
      callback({ cancel: true });
      return;
    }
    callback({ requestHeaders: {
      ...headers,
      origin: target.origin,
      cookie: hostCookie,
      'sec-fetch-site': 'same-origin'
    } });
  });

  // Log all dsh-app:// loads to debug download
  mainWindow.webContents.on('did-start-loading', () => {
    const url = mainWindow.webContents.getURL();
    if (url.startsWith('dsh-app://')) {
      log('Main frame URL: ' + url);
    }
  });

  mainWindow.webContents.on('did-finish-load', () => {
    const url = mainWindow.webContents.getURL();
    log('Page loaded: ' + url);
  });

  mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL) => {
    log('Page failed: ' + validatedURL + ' (' + errorCode + ': ' + errorDescription + ')');
  });

  // Debug: check URL after 2 seconds
  setTimeout(() => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      log('Current URL: ' + mainWindow.webContents.getURL());
    }
  }, 2000);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function refreshApplicationMenu() {
  const template = process.platform === 'win32' ? [
    {
      label: 'File',
      submenu: [
        { role: 'quit', label: 'Exit' }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo', label: 'Undo' },
        { role: 'redo', label: 'Redo' },
        { type: 'separator' },
        { role: 'cut', label: 'Cut' },
        { role: 'copy', label: 'Copy' },
        { role: 'paste', label: 'Paste' },
        { role: 'selectAll', label: 'Select All' }
      ]
    }
  ] : [];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

// Register scheme before app is ready
protocol.registerSchemesAsPrivileged([
  { scheme: 'dsh-app', privileges: { standard: true, secure: true, supportFetchAPI: true, corsEnabled: true, stream: true, codeCache: true } }
]);

app.whenReady().then(async () => {
  // Setup logging
  try {
    logStream = fs.createWriteStream(LOG_FILE, { flags: 'a' });
    log('App starting, log file: ' + LOG_FILE);
  } catch (e) {
    console.error('Failed to create log stream:', e);
  }

  // Register protocol handler
  await setupProtocol();
  log('Protocol registered: dsh-app://');

  refreshApplicationMenu();
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

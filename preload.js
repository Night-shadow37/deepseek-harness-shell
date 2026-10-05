const { contextBridge, ipcRenderer } = require('electron');

const DESKTOP_IPC = {
  nativeThemeSet: 'dsh-desktop:native-theme-set',
  windowsAppearance: 'dsh-desktop:windows-appearance',
  windowsMenu: 'dsh-desktop:windows-menu',
  windowFullscreen: 'dsh-desktop:window-fullscreen',
  shortcutsInput: 'dsh-desktop:shortcuts-input',
  shortcutsCloseWindow: 'dsh-desktop:shortcuts-close-window',
  shortcutsGet: 'dsh-desktop:shortcuts-get',
  shortcutsEdit: 'dsh-desktop:shortcuts-edit',
  shortcutsChanged: 'dsh-desktop:shortcuts-changed',
  shortcutsRecording: 'dsh-desktop:shortcuts-recording'
};

function markDocumentPlatform() {
  const mark = () => {
    document.documentElement.dataset.platform = process.platform;
  };
  if (document.documentElement === null) window.addEventListener('DOMContentLoaded', mark);
  else mark();
}

function syncWindowFullscreen() {
  if (process.platform !== 'darwin' && process.platform !== 'win32') return;
  ipcRenderer.on(DESKTOP_IPC.windowFullscreen, (_event, fullscreen) => {
    const root = document.documentElement;
    if (root === null) return;
    if (fullscreen) root.dataset.fullscreen = 'true';
    else delete root.dataset.fullscreen;
  });
}

const THEME_SOURCE_ATTRIBUTE = 'data-ds-theme-source';
function syncNativeTheme() {
  let sent;
  const send = () => {
    const value = document.documentElement.getAttribute(THEME_SOURCE_ATTRIBUTE);
    if (value === null || value === sent) return;
    sent = value;
    ipcRenderer.send(DESKTOP_IPC.nativeThemeSet, value);
  };
  const observe = () => {
    new MutationObserver(send).observe(document.documentElement, { attributeFilter: [THEME_SOURCE_ATTRIBUTE] });
    send();
  };
  if (document.readyState === 'loading') window.addEventListener('DOMContentLoaded', observe, { once: true });
  else observe();
}

function installWindowsMenu() {
  const host = document.createElement('div');
  host.dataset.windowsMenu = '';
  const shadow = host.attachShadow({ mode: 'open' });
  const style = document.createElement('style');
  style.textContent = `
    :host { position: fixed; top: 0; left: var(--dsh-windows-menu-start, 48px); z-index: 1100;
      height: var(--dsh-windows-titlebar-height); display: flex; align-items: center;
      font-family: var(--dsw-font-family); -webkit-app-region: no-drag; }
    [role=menubar] { display: flex; gap: 2px; }
    button { height: 28px; padding: 0 10px; border: 0; border-radius: 6px;
      background: transparent; color: var(--dsw-alias-label-secondary);
      font: inherit; font-size: 14px; cursor: default; }
    button:hover, button[aria-expanded=true] { background: var(--dsw-alias-interactive-bg-hover);
      color: var(--dsw-alias-label-primary); }
    button:focus-visible { outline: 2px solid var(--dsw-alias-state-business-primary); outline-offset: -2px; }
    :host-context(html[data-input-modality='pointer']) button:focus-visible { outline-color: transparent; }
  `;
  const bar = document.createElement('div');
  bar.setAttribute('role', 'menubar');
  let restoreEditor = () => {};
  const rememberEditor = (event) => {
    const target = event.composedPath()[0];
    if (!(target instanceof HTMLElement) || target === host || shadow.contains(target)) return;
    if (!(target instanceof HTMLInputElement) && !(target instanceof HTMLTextAreaElement) && !target.matches('[contenteditable="true"]')) return;
    const selection = document.getSelection();
    const ranges = selection === null ? [] : Array.from({ length: selection.rangeCount }, (_, i) => selection.getRangeAt(i).cloneRange());
    const input = target instanceof HTMLInputElement || target instanceof HTMLTextAreaElement ? target : undefined;
    const start = input?.selectionStart;
    const end = input?.selectionEnd;
    const direction = input?.selectionDirection;
    restoreEditor = () => {
      if (!target.isConnected) return;
      target.focus({ preventScroll: true });
      if (input !== undefined && start != null && end != null) input.setSelectionRange(start, end, direction ?? null);
      else if (selection !== null && ranges.length > 0) {
        selection.removeAllRanges();
        for (const range of ranges) selection.addRange(range);
      }
    };
  };
  document.addEventListener('focusout', rememberEditor, true);
  const createButton = (name, index) => {
    const button = document.createElement('button');
    button.type = 'button';
    button.setAttribute('role', 'menuitem');
    button.setAttribute('aria-haspopup', 'menu');
    button.setAttribute('aria-expanded', 'false');
    button.tabIndex = index === 0 ? 0 : -1;
    button.addEventListener('pointerdown', (event) => { event.preventDefault(); });
    button.addEventListener('mousedown', (event) => { event.preventDefault(); });
    const open = async () => {
      if (button.getAttribute('aria-expanded') === 'true') return;
      const rect = button.getBoundingClientRect();
      button.setAttribute('aria-expanded', 'true');
      if (document.activeElement === host) restoreEditor();
      try {
        await ipcRenderer.invoke(DESKTOP_IPC.windowsMenu, name, rect.left, rect.bottom);
      } catch (error) {
        console.error('Desktop caption menu failed', error);
      } finally {
        button.setAttribute('aria-expanded', 'false');
      }
    };
    button.addEventListener('click', () => { open(); });
    button.addEventListener('keydown', (event) => {
      if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
        event.preventDefault();
        const next = buttons[index === 0 ? 1 : 0];
        button.tabIndex = -1;
        next.tabIndex = 0;
        next.focus();
      } else if (event.key === 'ArrowDown') {
        event.preventDefault();
        open();
      }
    });
    bar.append(button);
    return button;
  };
  const buttons = [createButton('application', 0), createButton('edit', 1)];
  shadow.append(style, bar);
  const mount = () => {
    if (document.querySelector('[data-shell-overlay]') === null) return;
    document.body.append(host);
    observer.disconnect();
  };
  const observer = new MutationObserver(mount);
  observer.observe(document.body, { childList: true, subtree: true });
  mount();
  const update = () => {
    const messages = {
      application: 'Application',
      edit: 'Edit',
      menuBar: 'Application menu'
    };
    bar.setAttribute('aria-label', messages.menuBar);
    buttons[0].textContent = messages.application;
    buttons[1].textContent = messages.edit;
  };
  update();
  return {
    update,
    dispose: () => {
      observer.disconnect();
      document.removeEventListener('focusout', rememberEditor, true);
      host.remove();
    }
  };
}

function syncWindowsAppearance() {
  if (process.platform !== 'win32') return;
  const mark = () => {
    const root = document.documentElement;
    root.dataset.windowsTitlebar = '';
    root.style.setProperty('--dsh-windows-titlebar-height', '40px');
  };
  if (document.documentElement !== null) mark();
  const install = () => {
    mark();
    const root = document.documentElement;
    const menu = installWindowsMenu();
    const probe = document.createElement('span');
    probe.style.cssText = 'position:fixed;visibility:hidden;pointer-events:none;background-color:var(--dsw-specific-sidebar-fill);color:var(--dsw-alias-label-primary)';
    document.body.append(probe);
    const canvas = document.createElement('canvas');
    canvas.width = canvas.height = 1;
    const context = canvas.getContext('2d', { willReadFrequently: true });
    if (context === null) throw new Error('Desktop caption requires a 2D canvas context');
    const nativeColor = (color) => {
      context.clearRect(0, 0, 1, 1);
      context.fillStyle = color;
      context.fillRect(0, 0, 1, 1);
      const [red, green, blue, alpha] = context.getImageData(0, 0, 1, 1).data;
      return `rgba(${red}, ${green}, ${blue}, ${Number(alpha) / 255})`;
    };
    let previous = '';
    const send = () => {
      const style = getComputedStyle(probe);
      const color = nativeColor(style.backgroundColor);
      const symbolColor = nativeColor(style.color);
      const values = [root.lang, color, symbolColor];
      const current = JSON.stringify(values);
      if (current === previous) return;
      previous = current;
      menu.update();
      ipcRenderer.send(DESKTOP_IPC.windowsAppearance, ...values);
    };
    const observer = new MutationObserver(send);
    observer.observe(root, { attributes: true, attributeFilter: ['lang'] });
    observer.observe(document.body, { attributes: true, attributeFilter: ['data-ds-dark-theme', 'style'] });
    observer.observe(document.head, { childList: true, subtree: true, characterData: true });
    document.head.addEventListener('load', send, true);
    window.addEventListener('pagehide', () => {
      observer.disconnect();
      menu.dispose();
      probe.remove();
      document.head.removeEventListener('load', send, true);
    }, { once: true });
    send();
  };
  if (document.readyState === 'loading') window.addEventListener('DOMContentLoaded', install, { once: true });
  else install();
}

// Expose minimal API
contextBridge.exposeInMainWorld('__HARNESS_SHELL__', {
  platform: process.platform
});

// Expose dshDesktop API for shortcuts and other desktop features
contextBridge.exposeInMainWorld('dshDesktop', {
  protocolVersion: 1,
  boot: () => ipcRenderer.invoke('dsh-desktop:boot'),
  bootFailed: (message) => ipcRenderer.invoke('dsh-desktop:boot-failed', message),
  keyboard: {
    closeWindow: (revision) => ipcRenderer.invoke('dsh-desktop:shortcuts-close-window', revision),
    subscribe: (listener) => {
      const handle = (_event, input) => {
        if (input.kind === 'iframe') {
          const element = document.activeElement;
          if (!(element instanceof HTMLIFrameElement) || !element.isConnected || !element.matches('iframe[data-sidebar-browser-frame], iframe[data-html-preview]')) return;
          if (input.frameName === '' || element.name !== input.frameName) return;
        }
        if (input.kind === 'webview') {
          const element = document.activeElement;
          if (element?.matches('webview[data-sidebar-browser-frame]') !== true || !element.isConnected || input.frameName === '' || element.getAttribute('name') !== input.frameName) return;
        }
        listener(input);
      };
      ipcRenderer.on('dsh-desktop:shortcuts-input', handle);
      return () => {
        ipcRenderer.off('dsh-desktop:shortcuts-input', handle);
      };
    }
  },
  shortcuts: {
    get: (definitions) => ipcRenderer.invoke('dsh-desktop:shortcuts-get', definitions),
    edit: (edit, revision) => ipcRenderer.invoke('dsh-desktop:shortcuts-edit', edit, revision),
    recording: (active) => ipcRenderer.invoke('dsh-desktop:shortcuts-recording', active),
    subscribe(listener) {
      const handle = (_event, snapshot) => {
        listener(snapshot);
      };
      ipcRenderer.on('dsh-desktop:shortcuts-changed', handle);
      return () => {
        ipcRenderer.off('dsh-desktop:shortcuts-changed', handle);
      };
    }
  },
  shortcutsChanged: (listener) => {
    ipcRenderer.on('dsh-desktop:shortcuts-changed', (_event, snapshot) => {
      listener(snapshot);
    });
    return () => ipcRenderer.removeListener('dsh-desktop:shortcuts-changed', listener);
  }
});

// Desktop platform bridge
contextBridge.exposeInMainWorld('dshPlatform', {
  open: (page, bounds) => ipcRenderer.invoke('dsh-platform:open', page, bounds),
  setBounds: (bounds) => ipcRenderer.invoke('dsh-platform:bounds', bounds),
  close: () => ipcRenderer.invoke('dsh-platform:close')
});

// Locale bootstrap for Chinese/English UI
contextBridge.exposeInMainWorld('__DSH_LOCALE__', {
  read: () => ipcRenderer.invoke('dsh-desktop:locale-bootstrap'),
  onChange: (locale) => {
    ipcRenderer.send('dsh-desktop:locale-changed', locale);
  }
});

// Onboarding bridge to skip login flow
contextBridge.exposeInMainWorld('dshOnboarding', {
  hasApiKey: () => Promise.resolve(false)
});

// Desktop boot readiness
contextBridge.exposeInMainWorld('dshDesktopBoot', {
  ready: () => ipcRenderer.invoke('dsh-desktop:boot'),
  failed: (message) => ipcRenderer.invoke('dsh-desktop:boot-failed', message)
});

// Run setup
markDocumentPlatform();
syncWindowFullscreen();
syncNativeTheme();
if (process.platform === 'win32') syncWindowsAppearance();

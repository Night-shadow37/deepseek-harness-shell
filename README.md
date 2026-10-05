# DeepSeek Harness Shell

A custom Electron shell for DeepSeek Harness with Windows Start Menu integration, plugin fixes, and enhanced download handling.

## Features

- **Electron Shell**: Wraps DeepSeek Harness WebUI in a native Windows desktop app
- **Windows Start Menu Integration**: Proper Start Menu shortcut with embedded icon
- **Plugin Sync Fix**: Resolves account plugin loading errors
- **Download Handling**: Allows chat history export while blocking self-update installer
- **Launch Options**: 
  - Batch launcher (`启动 DeepSeek Harness.bat`)
  - VBScript launcher (no console window)
  - Compiled EXE launcher with embedded icon

## Project Structure

```
harness-shell/
├── main.js                 # Electron main process
├── preload.js              # Preload script with DSH bridges
├── package.json            # Project configuration
├── assets/                 # Icons and images
│   ├── icon.png           # Source icon (1024x1024)
│   ├── icon.ico           # Windows icon file
│   └── icon-validated.ico # Validated multi-size ICO
├── release/                # Windows launchers and shortcuts
│   ├── 启动 DeepSeek Harness.bat  # Batch launcher
│   ├── 启动 DeepSeek Harness.vbs  # VBScript launcher
│   └── icons/              # Icon files for shortcuts
├── launcher/               # Compiled EXE launcher source
│   ├── DeepSeek Harness Launcher.exe
│   └── Program.cs          # C# launcher source
├── web-frontend/           # Custom web UI assets
│   ├── index.html
│   ├── assets/
│   └── favicon.ico
├── make_ico.py             # Python script to generate valid ICO files
└── user-data/              # Electron user data (runtime)
```

## Requirements

- Windows 10/11
- Node.js (for development)
- Python 3 + Pillow (for icon generation)
- .NET SDK (for EXE launcher compilation)
- DeepSeek Harness runtime at `C:\Users\xingg\.dsh\dsh-orb\electron-runtime\`

## Installation

### Option 1: Batch Launcher (Simplest)
1. Clone this repository
2. Ensure DeepSeek Harness runtime is installed
3. Double-click `release/启动 DeepSeek Harness.bat`

### Option 2: VBScript Launcher (No Console Window)
1. Double-click `release/启动 DeepSeek Harness.vbs`

### Option 3: EXE Launcher (With Icon)
1. Compile `launcher/Program.cs` using Visual Studio or `csc.exe`:
   ```
   csc /win32icon:assets/icon.ico /out:launcher/DeepSeek Harness Launcher.exe launcher/Program.cs
   ```
2. Double-click the compiled EXE

## Creating Windows Start Menu Shortcut

Run the following PowerShell command as administrator:

```powershell
$WshShell = New-Object -ComObject WScript.Shell
$StartMenu = [Environment]::GetFolderPath('Programs')
$ShortcutPath = Join-Path $StartMenu "DeepSeek Harness.lnk"
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "D:\dsh\harness-shell\release\启动 DeepSeek Harness.vbs"
$Shortcut.WorkingDirectory = "D:\dsh\harness-shell"
$Shortcut.IconLocation = "D:\dsh\harness-shell\assets\icon.ico"
$Shortcut.Save()
```

## Building ICO Files

Use the included Python script to generate valid Windows ICO files:

```bash
python make_ico.py
```

This generates `assets/icon-validated.ico` with multiple sizes (16x16 to 256x256).

## Known Issues & Fixes

### Issue: Account Plugin Sync Error
**Error**: `client-modules: could not load "@deepseek-ai/dsh-client-ui-settings-account"`

**Fix**: The `main.js` has been modified to stop aggressive HTML/URL stripping of the account plugin.

### Issue: supportsImageAttachments is not a function
**Error**: `resolve(...).supportsImageAttachments is not a function`

**Fix**: The overlay-guard wrapper in `overlay-guard.ts` now properly forwards `supportsImageAttachments`.

### Issue: Start Menu Icon Not Displaying
**Workaround**: Use the compiled EXE launcher with embedded icon, or ensure the `.ico` file has valid 16-byte directory entries.

## Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server:
   ```bash
   npm start
   ```

3. Make changes to `main.js` or `preload.js`

## License

MIT

## Disclaimer

This project is not affiliated with DeepSeek. Use at your own risk.

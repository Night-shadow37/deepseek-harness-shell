@echo off
setlocal

set "ELECTRON=C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe"
set "APP_DIR=D:\dsh\harness-shell"

echo Starting DeepSeek Harness...

if not exist "%ELECTRON%" (
    echo ERROR: Electron not found at "%ELECTRON%"
    pause
    exit /b 1
)

if not exist "%APP_DIR%\main.js" (
    echo ERROR: main.js not found at "%APP_DIR%\main.js"
    pause
    exit /b 1
)

echo Launching Electron...
start "" "%ELECTRON%" "%APP_DIR%"

exit /b 0

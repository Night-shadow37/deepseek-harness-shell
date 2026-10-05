@echo off
echo Starting DeepSeek Harness...
echo Electron path: C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe
echo App dir: D:\dsh\harness-shell

if not exist "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" (
    echo ERROR: Electron not found
    pause
    exit /b 1
)

echo Launching Electron...
start "" "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" "D:\dsh\harness-shell"
echo Done

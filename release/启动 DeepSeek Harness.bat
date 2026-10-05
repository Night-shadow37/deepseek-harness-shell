@echo off
chcp 65001 >nul
echo ==========================================
echo Starting DeepSeek Harness...
echo ==========================================
echo.
echo Electron: C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe
echo App Dir: D:\dsh\harness-shell
echo.
echo Launching... (this window will stay open)
echo.

start "" "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" "D:\dsh\harness-shell"

echo.
echo DeepSeek Harness should be starting...
echo Check the taskbar for the DeepSeek Harness window.
echo.
pause

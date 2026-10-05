@echo off
chcp 65001 >nul
echo [%date% %time%] Starting DeepSeek Harness... >> "D:\dsh\harness-shell\release\launch-debug.log"
echo [%date% %time%] Electron: C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe >> "D:\dsh\harness-shell\release\launch-debug.log"
echo [%date% %time%] App Dir: D:\dsh\harness-shell >> "D:\dsh\harness-shell\release\launch-debug.log"
echo [%date% %time%] Current Dir: %cd% >> "D:\dsh\harness-shell\release\launch-debug.log"
echo [%date% %time%] Launching... >> "D:\dsh\harness-shell\release\launch-debug.log"
start "" "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" "D:\dsh\harness-shell" 2>> "D:\dsh\harness-shell\release\launch-debug.log"
echo [%date% %time%] Launch command sent >> "D:\dsh\harness-shell\release\launch-debug.log"
timeout /t 5 /nobreak >nul
echo [%date% %time%] Checking electron processes... >> "D:\dsh\harness-shell\release\launch-debug.log"
tasklist /fi "imagename eq electron.exe" 2>> "D:\dsh\harness-shell\release\launch-debug.log"
echo [%date% %time%] Done >> "D:\dsh\harness-shell\release\launch-debug.log"

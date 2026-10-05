@echo off
chcp 65001 >nul
echo Starting DeepSeek Harness...
start "" "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" "D:\dsh\harness-shell"
timeout /t 3 /nobreak >nul
echo Done

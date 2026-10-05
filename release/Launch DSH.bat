@echo off
title DeepSeek Harness Launcher
echo Starting DeepSeek Harness...
echo.
echo If a window appears and disappears immediately, check:
echo 1. Task Manager for electron.exe processes
echo 2. This window for error messages
echo.
echo Launching now...
start "" "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" "D:\dsh\harness-shell"
echo.
echo Launcher started. DSH should open shortly.
echo If you don't see DSH window, try pressing Alt+Tab.
echo.
pause

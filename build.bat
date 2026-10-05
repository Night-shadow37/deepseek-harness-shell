@echo off
chcp 65001 >nul
echo ==========================================
echo DeepSeek Harness Shell - Build Script
echo ==========================================
echo.

REM Check if we're in the right directory
if not exist "main.js" (
    echo [ERROR] main.js not found. Please run this script from the project root.
    pause
    exit /b 1
)

REM Clean old builds
echo [INFO] Cleaning old builds...
if exist "dist" rmdir /s /q dist
if exist "release" rmdir /s /q release
mkdir release >nul 2>&1

REM Generate ICO
echo [INFO] Generating ICO files...
python make_ico.py
if errorlevel 1 (
    echo [ERROR] Failed to generate ICO
    pause
    exit /b 1
)

REM Copy assets
echo [INFO] Copying assets...
xcopy /Y assets\*.ico release\icons\ >nul 2>&1
mkdir release\icons >nul 2>&1
copy /Y assets\icon.ico release\icons\ >nul
copy /Y assets\icon-validated.ico release\icons\ >nul

REM Build Python-based EXE launcher
echo [INFO] Building EXE launcher with PyInstaller...
python -m PyInstaller launcher\launcher.spec --distpath release\launcher-dist --workpath release\launcher-build --clean >nul 2>&1
if exist "release\launcher-dist\DeepSeek Harness Launcher.exe" (
    copy /Y "release\launcher-dist\DeepSeek Harness Launcher.exe" release\ >nul
    echo [OK] EXE launcher built
) else (
    echo [WARN] Failed to build EXE launcher. Creating .bat fallback.
    (
    echo @echo off
    echo chcp 65001 ^>nul
    echo echo Starting DeepSeek Harness...
    echo start "" "C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe" "%~dp0.."
    ) > release\启动 DeepSeek Harness.bat
)

REM Copy launcher to main directory
echo [INFO] Copying launcher to harness-shell directory...
if exist "release\DeepSeek Harness Launcher.exe" (
    copy /Y "release\DeepSeek Harness Launcher.exe" launcher\ >nul
    echo [OK] Launcher copied
)

echo.
echo ==========================================
echo Build Complete!
echo ==========================================
echo.
echo Files created in release\:
dir /b release
echo.
echo To install shortcuts, run:
echo   powershell -ExecutionPolicy Bypass -File setup\create-shortcut.ps1
echo.
pause

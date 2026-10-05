@echo off
chcp 65001 >nul
echo ==========================================
echo DeepSeek Harness Shell - Setup
echo ==========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed. Please install Python 3.8+
    pause
    exit /b 1
)
echo [OK] Python found

REM Check Pillow
python -c "import PIL" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing Pillow...
    pip install Pillow
)
echo [OK] Pillow ready

REM Generate ICO
echo [INFO] Generating ICO files...
python make_ico.py
if errorlevel 1 (
    echo [ERROR] Failed to generate ICO
    pause
    exit /b 1
)
echo [OK] ICO files generated

REM Check Python and PyInstaller
python --version >nul 2>&1
if errorlevel 1 (
    echo [WARN] Python not found. EXE launcher will not be built.
    echo [INFO] You can still use the .bat or .vbs launchers.
) else (
    echo [OK] Python found
    python -m PyInstaller --version >nul 2>&1
    if errorlevel 1 (
        echo [INFO] Installing PyInstaller...
        pip install PyInstaller
    )
    echo [OK] PyInstaller ready
    echo [INFO] Building EXE launcher with PyInstaller...
    cd launcher
    python -m PyInstaller launcher.spec --distpath ..\release\launcher-dist --workpath ..\release\launcher-build --clean >nul 2>&1
    if errorlevel 1 (
        echo [WARN] Failed to build EXE launcher. Use .bat or .vbs instead.
    ) else (
        echo [OK] EXE launcher built
        copy /Y ..\release\launcher-dist\DeepSeek Harness Launcher.exe ..\ >nul
    )
    cd ..
)

echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.
echo To create Start Menu shortcut, run:
echo   powershell -ExecutionPolicy Bypass -File setup\create-shortcut.ps1
echo.
pause

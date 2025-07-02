@echo off
echo ========================================
echo Machine Monitoring - Quick Fix
echo ========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ ERROR: Must run as Administrator
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ✅ Running as Administrator

echo.
echo 🔧 Step 1: Configuring Windows Firewall...
netsh advfirewall firewall delete rule name="Machine Monitoring Port 8000" >nul 2>&1
netsh advfirewall firewall add rule name="Machine Monitoring Port 8000" dir=in action=allow protocol=TCP localport=8000
netsh advfirewall firewall add rule name="Machine Monitoring Port 8000 Out" dir=out action=allow protocol=TCP localport=8000
echo ✅ Firewall configured for port 8000

echo.
echo 🔧 Step 2: Stopping any existing Python processes...
taskkill /F /IM python.exe /T >nul 2>&1
echo ✅ Existing processes stopped

echo.
echo 🔧 Step 3: Starting application...
cd /d "C:\inetpub\wwwroot\machine-monitoring\app"

if not exist "venv\Scripts\activate.bat" (
    echo ❌ ERROR: Virtual environment not found
    echo Expected location: C:\inetpub\wwwroot\machine-monitoring\app\venv
    pause
    exit /b 1
)

call venv\Scripts\activate.bat
echo ✅ Virtual environment activated

python -c "from app import app; print('✅ App imported successfully')" 2>nul
if errorlevel 1 (
    echo ❌ ERROR: Cannot import Flask app
    echo Check if all dependencies are installed:
    pip list | findstr Flask
    pause
    exit /b 1
)

echo.
echo 🚀 Starting server on all interfaces, port 8000...
echo.
echo 🌐 Server will be accessible at:
echo   ➤ Local: http://127.0.0.1:8000
echo   ➤ Server: http://103.181.200.14:8000
echo   ➤ Static: http://103.183.24.243:8000
echo.
echo ⏹️  Press Ctrl+C to stop the server
echo.

waitress-serve --host=0.0.0.0 --port=8000 app:app

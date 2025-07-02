@echo off

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Running with Administrator privileges
) else (
    echo ❌ ERROR: This script requires Administrator privileges
    echo.
    echo Please right-click on start_app.bat and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ========================================
echo Machine Monitoring System - Production Server
echo ========================================
echo Server: 103.181.200.14
echo Static IP: 103.183.24.243
echo ========================================
echo.

cd /d "C:\inetpub\wwwroot\machine-monitoring\app"
call venv\Scripts\activate.bat
echo ✅ Virtual environment activated

echo 🧪 Testing app import...
python -c "from app import app; print('✅ App imported successfully')"
if errorlevel 1 (
    echo ❌ ERROR: Failed to import app
    pause
    exit /b 1
)

echo.
echo � Checking port availability...

REM Check if port 5000 is available
netstat -an | find ":5000 " >nul
if %errorlevel% == 0 (
    echo ⚠️  Port 5000 is already in use
    echo 🔄 Will try to stop existing process...
    for /f "tokens=5" %%a in ('netstat -ano ^| find ":5000 "') do taskkill /PID %%a /F >nul 2>&1
    timeout /t 2 /nobreak >nul
) else (
    echo ✅ Port 5000 is available
)

REM Check if port 9090 is available
netstat -an | find ":9090 " >nul
if %errorlevel% == 0 (
    echo ⚠️  Port 9090 is already in use
    echo 🔄 Will try to stop existing process...
    for /f "tokens=5" %%a in ('netstat -ano ^| find ":9090 "') do taskkill /PID %%a /F >nul 2>&1
    timeout /t 2 /nobreak >nul
) else (
    echo ✅ Port 9090 is available
)

echo.
echo �🚀 Starting Flask application with Waitress...
echo.
echo 🌐 Server will be accessible at:
echo    ➤ Static IP: http://103.183.24.243:9090
echo    ➤ Server IP: http://103.181.200.14:5000
echo    ➤ Local: http://127.0.0.1:5000
echo.
echo ⏹️  Press Ctrl+C to stop the server
echo.

REM Kill any existing Flask/Waitress processes first
echo 🧹 Cleaning up existing processes...
taskkill /f /im python.exe >nul 2>&1
taskkill /f /im waitress-serve.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Start multiple Flask instances for redundancy
echo 🔄 Starting multiple server instances...
echo.

REM Start first instance on port 5000 (Primary Server) - Listen on all interfaces
echo [1/2] Starting Primary Server on port 5000 (accessible via 103.181.200.14:5000)...
echo     Binding to all interfaces (0.0.0.0) for maximum compatibility...
start "Flask Primary - Port 5000" cmd /k "cd /d C:\inetpub\wwwroot\machine-monitoring\app && call venv\Scripts\activate.bat && echo ✅ Virtual environment activated && echo 🚀 Starting Waitress server on port 5000... && echo 🌐 Server will be accessible via: && echo    - http://103.181.200.14:5000 && echo    - http://localhost:5000 && waitress-serve --host=0.0.0.0 --port=5000 --threads=6 --connection-limit=100 --cleanup-interval=30 --channel-timeout=120 app:app || (echo ❌ Failed to start server on port 5000 && echo Press any key to close... && pause)"

REM Wait for first instance to start
echo ⏳ Waiting for primary server to initialize...
timeout /t 6 /nobreak >nul

REM Check if first server started successfully
netstat -an | find ":5000 " >nul
if %errorlevel% == 0 (
    echo ✅ Primary server started successfully on port 5000
    echo 🧪 Testing primary server...
    curl -s -o nul -w "HTTP %%{http_code}" http://localhost:5000 2>nul && echo " - Response OK" || echo " - No response"
) else (
    echo ❌ Primary server failed to start on port 5000
)

echo.
REM Start second instance on port 9090 (Backup Server) - Listen on all interfaces
echo [2/2] Starting Backup Server on port 9090 (accessible via 103.183.24.243:9090)...
echo     Binding to all interfaces (0.0.0.0) for maximum compatibility...
start "Flask Backup - Port 9090" cmd /k "cd /d C:\inetpub\wwwroot\machine-monitoring\app && call venv\Scripts\activate.bat && echo ✅ Virtual environment activated && echo 🚀 Starting Waitress server on port 9090... && echo 🌐 Server will be accessible via: && echo    - http://103.183.24.243:9090 && echo    - http://localhost:9090 && waitress-serve --host=0.0.0.0 --port=9090 --threads=6 --connection-limit=100 --cleanup-interval=30 --channel-timeout=120 app:app || (echo ❌ Failed to start server on port 9090 && echo Press any key to close... && pause)"

echo ⏳ Waiting for backup server to initialize...
timeout /t 6 /nobreak >nul

REM Check if second server started successfully
netstat -an | find ":9090 " >nul
if %errorlevel% == 0 (
    echo ✅ Backup server started successfully on port 9090
    echo 🧪 Testing backup server...
    curl -s -o nul -w "HTTP %%{http_code}" http://localhost:9090 2>nul && echo " - Response OK" || echo " - No response"
) else (
    echo ❌ Backup server failed to start on port 9090
)

echo.
echo 🔍 Final server status check:
netstat -an | find ":5000 " >nul && echo ✅ Port 5000: ACTIVE || echo ❌ Port 5000: INACTIVE
netstat -an | find ":9090 " >nul && echo ✅ Port 9090: ACTIVE || echo ❌ Port 9090: INACTIVE

echo.
echo 🌐 Network Configuration Check:
echo ================================
echo Checking if static IPs are configured on this machine...
ipconfig | findstr "IPv4"
echo.
echo 🔍 Checking for static IP 103.183.24.243:
ipconfig | findstr "103.183.24.243" >nul && echo ✅ Static IP 103.183.24.243 is configured || echo ❌ Static IP 103.183.24.243 NOT found
echo.
echo 🔍 Checking for server IP 103.181.200.14:
ipconfig | findstr "103.181.200.14" >nul && echo ✅ Server IP 103.181.200.14 is configured || echo ❌ Server IP 103.181.200.14 NOT found
echo.
echo 🔥 Firewall Rules Check:
netsh advfirewall firewall show rule name="Flask Port 5000 Inbound" >nul 2>&1 && echo ✅ Port 5000 firewall rule exists || echo ❌ Port 5000 firewall rule missing
netsh advfirewall firewall show rule name="Flask Port 9090 Inbound" >nul 2>&1 && echo ✅ Port 9090 firewall rule exists || echo ❌ Port 9090 firewall rule missing

echo.
echo 🧪 Testing Local Access:
echo ========================
echo Testing localhost:5000...
curl -s -o nul -w "%%{http_code}" http://localhost:5000 2>nul && echo ✅ localhost:5000 responds || echo ❌ localhost:5000 not responding

echo Testing localhost:9090...
curl -s -o nul -w "%%{http_code}" http://localhost:9090 2>nul && echo ✅ localhost:9090 responds || echo ❌ localhost:9090 not responding

echo.
echo 🌐 Testing Static IP Access:
echo ============================
echo Testing 103.181.200.14:5000...
curl -s -o nul -w "%%{http_code}" http://103.181.200.14:5000 2>nul && echo ✅ 103.181.200.14:5000 responds || echo ❌ 103.181.200.14:5000 not responding

echo Testing 103.183.24.243:9090...
curl -s -o nul -w "%%{http_code}" http://103.183.24.243:9090 2>nul && echo ✅ 103.183.24.243:9090 responds || echo ❌ 103.183.24.243:9090 not responding

echo.
echo 🔧 Auto-fixing firewall rules...
netsh advfirewall firewall add rule name="Flask Port 5000 Inbound" dir=in action=allow protocol=TCP localport=5000 >nul 2>&1
netsh advfirewall firewall add rule name="Flask Port 9090 Inbound" dir=in action=allow protocol=TCP localport=9090 >nul 2>&1
echo ✅ Firewall rules added/updated

echo.
echo 📋 TROUBLESHOOTING GUIDE:
echo =========================
echo If external access fails:
echo 1. Check router port forwarding:
echo    - Forward external 103.181.200.14:5000 to this machine's port 5000
echo    - Forward external 103.183.24.243:9090 to this machine's port 9090
echo.
echo 2. Test URLs:
echo    - Local: http://localhost:5000 and http://localhost:9090
echo    - External: http://103.181.200.14:5000 and http://103.183.24.243:9090
echo.
echo 3. Check your router/ISP settings for port blocking

echo.
echo ✅ ========================================
echo ✅ BOTH FLASK INSTANCES STARTED SUCCESSFULLY!
echo ✅ ========================================
echo.
echo 🌐 Your Flask app is now running on BOTH ports:
echo    🔵 Primary Server:  http://103.181.200.14:5000 (via port 5000)
echo    🟢 Backup Server:   http://103.183.24.243:9090 (via port 9090)
echo    🌍 Local Access:    http://localhost:5000 and http://localhost:9090
echo.
echo 📡 API Endpoints available on both servers:
echo    ➤ POST /api/machine-data (for Arduino GSM data)
echo    ➤ GET / (Dashboard web interface)
echo.
echo 🔧 Arduino GSM Module Configuration:
echo    ➤ Primary:  serverURL = "103.181.200.14", port = 5000
echo    ➤ Backup:   serverURL = "103.183.24.243", port = 9090
echo.
echo 🔍 How this works:
echo    ➤ Both servers listen on 0.0.0.0 (all network interfaces)
echo    ➤ External traffic to 103.181.200.14:5000 → Port 5000 server
echo    ➤ External traffic to 103.183.24.243:9090 → Port 9090 server
echo    ➤ Router/firewall forwards external IPs to this machine
echo.
echo 💡 Benefits of dual server setup:
echo    ✅ Redundancy - if one server fails, the other continues
echo    ✅ Load distribution - can handle more concurrent requests
echo    ✅ Network flexibility - accessible via different IPs
echo.
echo 🔍 To check server status:
echo    ➤ Open browser and visit both URLs above
echo    ➤ Both should show the same dashboard
echo.
echo ⚠️  IMPORTANT: Both server windows will open separately
echo    ➤ Do NOT close the server windows to keep them running
echo    ➤ Close this window only - servers will continue running
echo.
echo Press any key to close this launcher window...
echo (Flask servers will continue running in separate windows)
pause
@echo off
echo ========================================
echo Machine Monitoring - Connection Troubleshoot
echo ========================================
echo Server IP: 103.181.200.14
echo Testing connectivity and configuration...
echo ========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Running as Administrator
) else (
    echo ⚠️  Not running as Administrator - some fixes may not work
    echo   Right-click and select "Run as administrator" for full troubleshooting
)

echo.
echo 🔍 Step 1: Checking if application is running...
netstat -an | findstr :8000
if errorlevel 1 (
    echo ❌ Port 8000 not listening - application not running
    echo.
    echo 🚀 Starting application...
    cd /d "C:\inetpub\wwwroot\machine-monitoring\app"
    if exist "venv\Scripts\activate.bat" (
        call venv\Scripts\activate.bat
        echo ✅ Virtual environment activated
        
        echo 🧪 Testing app import...
        python -c "from app import app; print('✅ App can be imported')"
        if errorlevel 1 (
            echo ❌ ERROR: Cannot import app - check your Flask application
            pause
            exit /b 1
        )
        
        echo.
        echo 🌐 Starting server on port 8000...
        echo Press Ctrl+C to stop when testing is complete
        start /B waitress-serve --host=0.0.0.0 --port=8000 app:app
        
        echo ⏳ Waiting 5 seconds for server to start...
        timeout /t 5 /nobreak > nul
        
    ) else (
        echo ❌ ERROR: Virtual environment not found
        echo Expected: C:\inetpub\wwwroot\machine-monitoring\app\venv\Scripts\activate.bat
        pause
        exit /b 1
    )
) else (
    echo ✅ Port 8000 is listening
)

echo.
echo 🔍 Step 2: Testing local connectivity...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://127.0.0.1:8000 --connect-timeout 10
if errorlevel 1 (
    echo ❌ Local connection failed - application may not be responding
) else (
    echo ✅ Local connection successful
)

echo.
echo 🔍 Step 3: Testing server IP connectivity...
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://103.181.200.14:8000 --connect-timeout 10
if errorlevel 1 (
    echo ❌ Server IP connection failed - likely firewall issue
    echo.
    echo 🔥 Attempting to fix Windows Firewall...
    netsh advfirewall firewall add rule name="Machine Monitoring Port 8000" dir=in action=allow protocol=TCP localport=8000
    if errorlevel 1 (
        echo ⚠️  Could not add firewall rule - run as Administrator
    ) else (
        echo ✅ Firewall rule added for port 8000
        echo.
        echo 🔄 Testing again...
        timeout /t 3 /nobreak > nul
        curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://103.181.200.14:8000 --connect-timeout 10
        if errorlevel 1 (
            echo ❌ Still failing - may need hosting provider firewall configuration
        ) else (
            echo ✅ Server IP connection now working!
        )
    )
) else (
    echo ✅ Server IP connection successful
)

echo.
echo 🔍 Step 4: Network configuration check...
echo Current IP configuration:
ipconfig | findstr "IPv4"

echo.
echo Active network connections on port 8000:
netstat -an | findstr :8000

echo.
echo 🔍 Step 5: Firewall status...
netsh advfirewall show allprofiles state | findstr "State"

echo.
echo ========================================
echo 🎯 TROUBLESHOOTING SUMMARY
echo ========================================

echo.
echo 📋 Next steps based on results above:
echo.
echo If LOCAL connection works but SERVER IP fails:
echo   ➤ Run this script as Administrator
echo   ➤ Check with hosting provider about external firewall
echo   ➤ Try different port (8080, 9000)
echo.
echo If APPLICATION is not running:
echo   ➤ Check Python installation: python --version
echo   ➤ Check virtual environment: venv\Scripts\activate
echo   ➤ Check Flask app: python -c "from app import app"
echo.
echo If FIREWALL is blocking:
echo   ➤ Run as Administrator and re-run this script
echo   ➤ Temporarily disable Windows Firewall for testing
echo   ➤ Contact hosting provider about external firewall
echo.
echo 🌐 If everything works, access your app at:
echo   ➤ http://103.181.200.14:8000
echo   ➤ http://103.183.24.243:8000 (if routed by hosting provider)
echo.

pause

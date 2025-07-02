@echo off
echo ========================================
echo Machine Monitoring - 24/7 Auto-Restart
echo ========================================
echo This will keep your webapp running continuously
echo and restart it automatically if it stops
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
echo 🔧 Creating auto-restart scheduled task...

REM Delete existing task if it exists
schtasks /delete /tn "MachineMonitoringAutoRestart" /f >nul 2>&1

REM Create scheduled task to start on boot
schtasks /create /tn "MachineMonitoringAutoRestart" /tr "C:\inetpub\wwwroot\machine-monitoring\start_app.bat" /sc onstart /ru SYSTEM /rl highest /f

if errorlevel 1 (
    echo ❌ Failed to create scheduled task
    pause
    exit /b 1
) else (
    echo ✅ Scheduled task created successfully
)

echo.
echo 🔧 Creating monitoring script...

REM Create a monitoring script that checks and restarts the app
(
echo @echo off
echo :loop
echo timeout /t 60 /nobreak ^> nul
echo tasklist /fi "imagename eq python.exe" ^| findstr python ^> nul
echo if errorlevel 1 ^(
echo     echo Application stopped - restarting...
echo     cd /d "C:\inetpub\wwwroot\machine-monitoring"
echo     start /min start_app.bat
echo ^)
echo goto loop
) > "C:\inetpub\wwwroot\machine-monitoring\monitor_app.bat"

echo ✅ Monitoring script created

echo.
echo 🔧 Creating monitoring scheduled task...

REM Create task to run monitoring script
schtasks /delete /tn "MachineMonitoringMonitor" /f >nul 2>&1
schtasks /create /tn "MachineMonitoringMonitor" /tr "C:\inetpub\wwwroot\machine-monitoring\monitor_app.bat" /sc onstart /ru SYSTEM /rl highest /f

if errorlevel 1 (
    echo ❌ Failed to create monitoring task
) else (
    echo ✅ Monitoring task created successfully
)

echo.
echo 🚀 Starting the application now...
cd /d "C:\inetpub\wwwroot\machine-monitoring"
start /min start_app.bat

echo.
echo ========================================
echo 🎉 24/7 AUTO-RESTART CONFIGURED!
echo ========================================
echo.
echo ✅ Your webapp will now:
echo   - Start automatically when server boots
echo   - Restart automatically if it crashes
echo   - Run continuously 24/7
echo.
echo 🌐 Access your webapp at:
echo   ➤ Server IP: http://103.181.200.14:5000
echo   ➤ Static IP: http://103.183.24.243:5000 (after hosting provider setup)
echo.
echo 🔧 Management Commands:
echo   View tasks: schtasks /query /tn "MachineMonitoringAutoRestart"
echo   Delete task: schtasks /delete /tn "MachineMonitoringAutoRestart" /f
echo   Manual start: start_app.bat
echo.
echo 📊 The application is now running in the background
echo    and will continue running even if you close this window
echo.

pause

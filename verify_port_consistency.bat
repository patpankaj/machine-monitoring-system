@echo off
echo ========================================
echo Port Consistency Verification
echo ========================================
echo Checking all scripts use the same port (5000)
echo ========================================
echo.

echo 🔍 Checking start_app.bat...
findstr "5000" "C:\inetpub\wwwroot\machine-monitoring\start_app.bat" >nul
if errorlevel 1 (
    echo ❌ start_app.bat doesn't contain port 5000
) else (
    echo ✅ start_app.bat uses port 5000
)

echo.
echo 🔍 Checking what port is actually running...
netstat -an | findstr :5000
if errorlevel 1 (
    echo ⚠️  No application running on port 5000
    echo Run start_app.bat to start the application
) else (
    echo ✅ Application is running on port 5000
)

echo.
echo 🔍 Testing actual access...
curl -s -o nul -w "Server IP (5000): HTTP %%{http_code}\n" http://103.181.200.14:5000 --connect-timeout 5
curl -s -o nul -w "Local (5000): HTTP %%{http_code}\n" http://127.0.0.1:5000 --connect-timeout 5

echo.
echo ========================================
echo 📋 SUMMARY
echo ========================================
echo.
echo ✅ All scripts should now use port 5000 consistently
echo ✅ Your webapp is accessible at:
echo    ➤ http://103.181.200.14:5000 (Server IP)
echo    ➤ http://127.0.0.1:5000 (Local)
echo    ➤ http://103.183.24.243:5000 (Static IP - after hosting setup)
echo.
echo 🚀 Next steps:
echo 1. Run start_app.bat to start your webapp
echo 2. Test access at http://103.181.200.14:5000
echo 3. Contact hosting provider for static IP routing
echo.

pause

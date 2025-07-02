@echo off
echo ========================================
echo Static IP Routing Test
echo ========================================
echo Server IP: 103.181.200.14
echo Static IP: 103.183.24.243
echo Port: 5000
echo ========================================
echo.

echo 🔍 Step 1: Testing if static IP responds to ping...
ping -n 4 103.183.24.243
if errorlevel 1 (
    echo ❌ Static IP does not respond to ping
    echo   This might be normal if ICMP is blocked
) else (
    echo ✅ Static IP responds to ping
)

echo.
echo 🔍 Step 2: Testing if server IP is accessible...
curl -s -o nul -w "Server IP Status: %%{http_code} (Response time: %%{time_total}s)\n" http://103.181.200.14:5000 --connect-timeout 10
if errorlevel 1 (
    echo ❌ Server IP not accessible - check if application is running
) else (
    echo ✅ Server IP is accessible
)

echo.
echo 🔍 Step 3: Testing if static IP routes to your application...
curl -s -o nul -w "Static IP Status: %%{http_code} (Response time: %%{time_total}s)\n" http://103.183.24.243:5000 --connect-timeout 15
if errorlevel 1 (
    echo ❌ Static IP routing FAILED
    echo   Possible reasons:
    echo   - Hosting provider hasn't configured routing
    echo   - Port 5000 not allowed through external firewall
    echo   - Static IP not properly assigned
    echo.
    echo 📞 Contact hosting provider with these details:
    echo   - Server IP: 103.181.200.14
    echo   - Static IP: 103.183.24.243
    echo   - Port: 5000
    echo   - Service: HTTP web application
) else (
    echo ✅ Static IP routing WORKS!
    echo   Your application is accessible via static IP
)

echo.
echo 🔍 Step 4: Testing different ports...
echo Testing common ports to see what's accessible:

for %%p in (80 8000 8080 3000) do (
    echo Testing port %%p...
    curl -s -o nul -w "Port %%p Status: %%{http_code}\n" http://103.183.24.243:%%p --connect-timeout 5
)

echo.
echo 🔍 Step 5: Network route analysis...
echo Checking routing table for static IP:
route print | findstr 103.183.24.243
if errorlevel 1 (
    echo ⚠️  No specific route found for static IP
    echo   This is normal - routing handled by hosting provider
) else (
    echo ✅ Route found for static IP
)

echo.
echo 🔍 Step 6: DNS resolution test...
echo Testing if static IP resolves:
nslookup 103.183.24.243
if errorlevel 1 (
    echo ⚠️  DNS lookup failed - this is normal for IP addresses
) else (
    echo ✅ DNS information available
)

echo.
echo ========================================
echo 📊 ROUTING TEST SUMMARY
echo ========================================
echo.
echo ✅ If Static IP Status shows 200: Routing works perfectly
echo ❌ If Static IP Status shows error: Contact hosting provider
echo.
echo 📞 Information for hosting provider:
echo   Server IP: 103.181.200.14
echo   Static IP: 103.183.24.243
echo   Application Port: 5000
echo   Service Type: HTTP Web Application
echo   Required: Route traffic from static IP to server IP on port 5000
echo.
echo 🌐 Test URLs:
echo   Working: http://103.181.200.14:5000
echo   Testing: http://103.183.24.243:9090
echo.

pause

@echo off
echo Installing Machine Monitoring as Windows Service...

# Install NSSM (Non-Sucking Service Manager)
# Download from https://nssm.cc/download
# Extract nssm.exe to C:\Windows\System32\

nssm install "MachineMonitoring" "C:\inetpub\wwwroot\machine-monitoring\app\start_app.bat"
nssm set "MachineMonitoring" DisplayName "Machine Monitoring System"
nssm set "MachineMonitoring" Description "IoT Machine Monitoring Dashboard"
nssm set "MachineMonitoring" Start SERVICE_AUTO_START

echo Service installed successfully!
echo Use 'net start MachineMonitoring' to start the service
pause
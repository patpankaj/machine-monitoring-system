@echo off
set BACKUP_DIR=C:\inetpub\wwwroot\machine-monitoring\backups
set DATE=%date:~-4,4%%date:~-10,2%%date:~-7,2%
set TIME=%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_NAME=backup_%DATE%_%TIME%

echo Creating backup: %BACKUP_NAME%
mkdir "%BACKUP_DIR%\%BACKUP_NAME%"

# Backup application files
xcopy "C:\inetpub\wwwroot\machine-monitoring\app" "%BACKUP_DIR%\%BACKUP_NAME%\app" /E /I /H

# Backup logs
xcopy "C:\inetpub\wwwroot\machine-monitoring\logs" "%BACKUP_DIR%\%BACKUP_NAME%\logs" /E /I /H

echo Backup completed: %BACKUP_DIR%\%BACKUP_NAME%

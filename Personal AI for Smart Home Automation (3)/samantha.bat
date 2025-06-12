@echo off
setlocal

set "INSTALL_DIR=C:\Samantha"
cd /d "%INSTALL_DIR%"

if "%1"=="start" (
    echo 🚀 Starting Samantha AI...
    docker-compose up -d
    echo ✅ Samantha AI started successfully!
    echo 🌐 Access at: http://localhost:3000
) else if "%1"=="stop" (
    echo 🛑 Stopping Samantha AI...
    docker-compose down
    echo ✅ Samantha AI stopped
) else if "%1"=="restart" (
    echo 🔄 Restarting Samantha AI...
    docker-compose restart
    echo ✅ Samantha AI restarted
) else if "%1"=="status" (
    echo 📊 Samantha AI Status:
    docker-compose ps
) else if "%1"=="logs" (
    echo 📋 Samantha AI Logs:
    docker-compose logs -f
) else if "%1"=="update" (
    echo ⬆️  Updating Samantha AI...
    docker-compose pull
    docker-compose up -d
    echo ✅ Update completed
) else if "%1"=="models" (
    echo 🧠 Available AI Models:
    curl -s http://localhost:11434/api/tags
) else if "%1"=="install-model" (
    if "%2"=="" (
        echo Usage: samantha install-model ^<model-name^>
        echo Example: samantha install-model dolphin-llama3:8b
        exit /b 1
    )
    echo 📥 Installing model: %2
    curl -X POST http://localhost:11434/api/pull -d "{\"name\":\"%2\"}"
) else if "%1"=="backup" (
    echo 💾 Creating backup...
    set BACKUP_NAME=samantha-backup-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.zip
    powershell -command "Compress-Archive -Path '%INSTALL_DIR%\data','%INSTALL_DIR%\logs' -DestinationPath '%TEMP%\!BACKUP_NAME!'"
    echo Backup created: %TEMP%\!BACKUP_NAME!
) else if "%1"=="uninstall" (
    echo 🗑️  Uninstalling Samantha AI...
    docker-compose down -v
    cd /d C:\
    rmdir /s /q "%INSTALL_DIR%"
    echo ✅ Samantha AI has been uninstalled
) else (
    echo 🤖 Samantha AI Management
    echo Usage: samantha {start^|stop^|restart^|status^|logs^|update^|models^|install-model^|backup^|uninstall}
    echo.
    echo Commands:
    echo   start         - Start Samantha AI
    echo   stop          - Stop Samantha AI
    echo   restart       - Restart Samantha AI
    echo   status        - Show status
    echo   logs          - Show logs
    echo   update        - Update to latest version
    echo   models        - List available AI models
    echo   install-model - Install a new AI model
    echo   backup        - Create backup
    echo   uninstall     - Remove Samantha AI
)


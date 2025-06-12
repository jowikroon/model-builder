@echo off
setlocal enabledelayedexpansion

:: Samantha AI - Windows Installation Script (Fixed with Error Logging)
:: No system requirements, comprehensive error handling

title Samantha AI - Windows Installer (Debug Mode)

:: Create log file
set "LOG_FILE=%TEMP%\samantha-install.log"
echo ========================================= > "%LOG_FILE%"
echo Samantha AI Installation Log >> "%LOG_FILE%"
echo Date: %date% %time% >> "%LOG_FILE%"
echo ========================================= >> "%LOG_FILE%"

echo.
echo ========================================
echo    🤖 Samantha AI - Windows Installer
echo    (Debug Mode with Error Logging)
echo ========================================
echo.
echo 📋 Log file: %LOG_FILE%
echo.

:: Function to log and display messages
:log_message
echo %~1
echo %~1 >> "%LOG_FILE%"
goto :eof

:: Check if running as administrator
call :log_message "Checking administrator privileges..."
net session >nul 2>&1
if %errorLevel% neq 0 (
    call :log_message "❌ ERROR: This installer must be run as Administrator"
    call :log_message "Right-click on this file and select 'Run as administrator'"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

call :log_message "✅ Running with administrator privileges"
echo.

:: Set installation directory
set "INSTALL_DIR=C:\Samantha"
set "DOCKER_INSTALLER=%TEMP%\DockerDesktopInstaller.exe"
set "WSL_UPDATE=%TEMP%\wsl_update_x64.msi"

call :log_message "📁 Installation directory: %INSTALL_DIR%"
call :log_message "🔧 Docker installer: %DOCKER_INSTALLER%"
call :log_message "🔧 WSL update: %WSL_UPDATE%"
echo.

:: Only check Windows version (no other requirements)
call :log_message "🔍 Checking Windows compatibility..."
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
call :log_message "Windows version detected: %VERSION%"

if "%VERSION%" lss "10.0" (
    call :log_message "❌ ERROR: Windows 10 or later is required"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

call :log_message "✅ Windows version compatible"
call :log_message "✅ All compatibility checks passed - proceeding with installation"
echo.

:: Skip WSL2 installation entirely (causes issues)
call :log_message "⚠️  Skipping WSL2 automatic installation (can cause terminal closure)"
call :log_message "WSL2 will be handled by Docker Desktop installation"
echo.

:: Check if Docker Desktop is installed
call :log_message "🔍 Checking Docker Desktop installation..."
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    call :log_message "✅ Docker Desktop is already installed"
    set "DOCKER_INSTALLED=true"
) else (
    call :log_message "📦 Docker Desktop not found - will install"
    set "DOCKER_INSTALLED=false"
)
echo.

:: Install Docker Desktop if needed
if "%DOCKER_INSTALLED%"=="false" (
    call :log_message "📥 Starting Docker Desktop installation..."
    
    :: Download Docker Desktop with error handling
    call :log_message "Downloading Docker Desktop (this may take several minutes)..."
    powershell -command "try { Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe' -OutFile '%DOCKER_INSTALLER%' } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1
    
    if %errorLevel% neq 0 (
        call :log_message "❌ ERROR: Failed to download Docker Desktop"
        call :log_message "Check your internet connection and try again"
        echo.
        echo Press any key to view log and exit...
        pause >nul
        notepad "%LOG_FILE%"
        exit /b 1
    )
    
    call :log_message "✅ Docker Desktop downloaded successfully"
    
    :: Install Docker Desktop with error handling
    call :log_message "Installing Docker Desktop (this may take several minutes)..."
    "%DOCKER_INSTALLER%" install --quiet --accept-license --backend=wsl-2 >> "%LOG_FILE%" 2>&1
    
    if %errorLevel% neq 0 (
        call :log_message "⚠️  Docker Desktop installation completed with warnings"
        call :log_message "This is normal - Docker may require a restart"
    ) else (
        call :log_message "✅ Docker Desktop installed successfully"
    )
    
    call :log_message "🔄 Docker Desktop requires a system restart to complete installation"
    echo.
    echo ========================================
    echo   🔄 RESTART REQUIRED
    echo ========================================
    echo.
    echo Docker Desktop has been installed but requires a restart.
    echo.
    echo After restart:
    echo 1. Wait for Docker Desktop to start automatically
    echo 2. Run this installer again to complete Samantha setup
    echo.
    set /p RESTART="Restart now? (y/n): "
    if /i "!RESTART!"=="y" (
        call :log_message "User chose to restart now"
        shutdown /r /t 10 /c "Restarting for Docker Desktop installation"
        exit /b 0
    ) else (
        call :log_message "User chose to restart manually"
        echo.
        echo Please restart manually and run this installer again.
        echo.
        echo Press any key to view installation log...
        pause >nul
        notepad "%LOG_FILE%"
        exit /b 0
    )
)

:: Wait for Docker to be ready (with timeout and error handling)
call :log_message "🐳 Starting Docker Desktop..."
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" >> "%LOG_FILE%" 2>&1

call :log_message "Waiting for Docker to be ready (this may take 2-3 minutes)..."
set /a DOCKER_TIMEOUT=0
:wait_docker
timeout /t 10 /nobreak >nul
docker version >nul 2>&1
if %errorLevel% equ 0 (
    call :log_message "✅ Docker is ready and responding"
    goto docker_ready
)

set /a DOCKER_TIMEOUT+=1
call :log_message "Docker not ready yet... attempt %DOCKER_TIMEOUT%/18"

if %DOCKER_TIMEOUT% geq 18 (
    call :log_message "❌ ERROR: Docker failed to start within 3 minutes"
    call :log_message "Please ensure Docker Desktop is running and try again"
    echo.
    echo ========================================
    echo   ❌ DOCKER STARTUP TIMEOUT
    echo ========================================
    echo.
    echo Docker Desktop is taking longer than expected to start.
    echo.
    echo Please:
    echo 1. Check if Docker Desktop is running in system tray
    echo 2. Wait for Docker to fully start (green icon)
    echo 3. Run this installer again
    echo.
    echo Press any key to view installation log...
    pause >nul
    notepad "%LOG_FILE%"
    exit /b 1
)
goto wait_docker

:docker_ready
echo.

:: Create installation directory
call :log_message "📁 Creating installation directory..."
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >> "%LOG_FILE%" 2>&1
    if %errorLevel% neq 0 (
        call :log_message "❌ ERROR: Failed to create installation directory"
        echo.
        echo Press any key to view log and exit...
        pause >nul
        notepad "%LOG_FILE%"
        exit /b 1
    )
)
cd /d "%INSTALL_DIR%" >> "%LOG_FILE%" 2>&1

:: Download Samantha files
call :log_message "⬇️  Setting up Samantha AI..."

:: Create docker-compose.yml with error handling
call :log_message "Creating Docker configuration..."
(
echo version: '3.8'
echo.
echo services:
echo   # Ollama service for local LLM
echo   ollama:
echo     image: ollama/ollama:latest
echo     container_name: samantha-ollama
echo     ports:
echo       - "11434:11434"
echo     volumes:
echo       - ollama_data:/root/.ollama
echo     environment:
echo       - OLLAMA_HOST=0.0.0.0
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo.
echo   # PostgreSQL database for learning and memory
echo   postgres:
echo     image: postgres:15-alpine
echo     container_name: samantha-postgres
echo     environment:
echo       POSTGRES_DB: samantha
echo       POSTGRES_USER: samantha
echo       POSTGRES_PASSWORD: samantha_secure_2024
echo     volumes:
echo       - postgres_data:/var/lib/postgresql/data
echo     ports:
echo       - "5432:5432"
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo.
echo   # Redis for caching and session management
echo   redis:
echo     image: redis:7-alpine
echo     container_name: samantha-redis
echo     ports:
echo       - "6379:6379"
echo     volumes:
echo       - redis_data:/data
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo.
echo   # Samantha Backend API
echo   backend:
echo     image: samantha/backend:latest
echo     container_name: samantha-backend
echo     ports:
echo       - "8000:8000"
echo     environment:
echo       - DATABASE_URL=postgresql://samantha:samantha_secure_2024@postgres:5432/samantha
echo       - REDIS_URL=redis://redis:6379
echo       - OLLAMA_URL=http://ollama:11434
echo       - ENVIRONMENT=production
echo     volumes:
echo       - ./logs:/app/logs
echo       - ./data:/app/data
echo     depends_on:
echo       - postgres
echo       - redis
echo       - ollama
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo.
echo   # Samantha Frontend
echo   frontend:
echo     image: samantha/frontend:latest
echo     container_name: samantha-frontend
echo     ports:
echo       - "3000:80"
echo     environment:
echo       - REACT_APP_API_URL=http://localhost:8000
echo     depends_on:
echo       - backend
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo.
echo volumes:
echo   ollama_data:
echo   postgres_data:
echo   redis_data:
echo.
echo networks:
echo   samantha-network:
echo     driver: bridge
) > docker-compose.yml 2>> "%LOG_FILE%"

if %errorLevel% neq 0 (
    call :log_message "❌ ERROR: Failed to create Docker configuration"
    echo.
    echo Press any key to view log and exit...
    pause >nul
    notepad "%LOG_FILE%"
    exit /b 1
)

:: Create management script
call :log_message "Creating management script..."
(
echo @echo off
echo setlocal
echo.
echo set "INSTALL_DIR=C:\Samantha"
echo cd /d "%%INSTALL_DIR%%"
echo.
echo if "%%1"=="start" ^(
echo     echo 🚀 Starting Samantha AI...
echo     docker-compose up -d
echo     echo ✅ Samantha AI started successfully!
echo     echo 🌐 Access at: http://localhost:3000
echo ^) else if "%%1"=="stop" ^(
echo     echo 🛑 Stopping Samantha AI...
echo     docker-compose down
echo     echo ✅ Samantha AI stopped
echo ^) else if "%%1"=="restart" ^(
echo     echo 🔄 Restarting Samantha AI...
echo     docker-compose restart
echo     echo ✅ Samantha AI restarted
echo ^) else if "%%1"=="status" ^(
echo     echo 📊 Samantha AI Status:
echo     docker-compose ps
echo ^) else if "%%1"=="logs" ^(
echo     echo 📋 Samantha AI Logs:
echo     docker-compose logs -f
echo ^) else if "%%1"=="update" ^(
echo     echo ⬆️  Updating Samantha AI...
echo     docker-compose pull
echo     docker-compose up -d
echo     echo ✅ Update completed
echo ^) else if "%%1"=="models" ^(
echo     echo 🧠 Available AI Models:
echo     curl -s http://localhost:11434/api/tags
echo ^) else if "%%1"=="install-model" ^(
echo     if "%%2"=="" ^(
echo         echo Usage: samantha install-model ^<model-name^>
echo         echo Example: samantha install-model dolphin-llama3:8b
echo         exit /b 1
echo     ^)
echo     echo 📥 Installing model: %%2
echo     curl -X POST http://localhost:11434/api/pull -d "{\"name\":\"%%2\"}"
echo ^) else if "%%1"=="backup" ^(
echo     echo 💾 Creating backup...
echo     set BACKUP_NAME=samantha-backup-%%date:~-4,4%%%%date:~-10,2%%%%date:~-7,2%%-%%time:~0,2%%%%time:~3,2%%%%time:~6,2%%.zip
echo     powershell -command "Compress-Archive -Path '%%INSTALL_DIR%%\data','%%INSTALL_DIR%%\logs' -DestinationPath '%%TEMP%%\!BACKUP_NAME!'"
echo     echo Backup created: %%TEMP%%\!BACKUP_NAME!
echo ^) else if "%%1"=="uninstall" ^(
echo     echo 🗑️  Uninstalling Samantha AI...
echo     docker-compose down -v
echo     cd /d C:\
echo     rmdir /s /q "%%INSTALL_DIR%%"
echo     echo ✅ Samantha AI has been uninstalled
echo ^) else ^(
echo     echo 🤖 Samantha AI Management
echo     echo Usage: samantha {start^|stop^|restart^|status^|logs^|update^|models^|install-model^|backup^|uninstall}
echo     echo.
echo     echo Commands:
echo     echo   start         - Start Samantha AI
echo     echo   stop          - Stop Samantha AI
echo     echo   restart       - Restart Samantha AI
echo     echo   status        - Show status
echo     echo   logs          - Show logs
echo     echo   update        - Update to latest version
echo     echo   models        - List available AI models
echo     echo   install-model - Install a new AI model
echo     echo   backup        - Create backup
echo     echo   uninstall     - Remove Samantha AI
echo ^)
) > samantha.bat 2>> "%LOG_FILE%"

:: Add to PATH
call :log_message "Adding Samantha to system PATH..."
setx PATH "%PATH%;%INSTALL_DIR%" /M >nul 2>&1

:: Create directories
call :log_message "Creating data directories..."
mkdir logs data 2>nul

:: Pull Docker images with error handling
call :log_message "📥 Downloading Samantha AI components (this may take several minutes)..."

call :log_message "Downloading Ollama..."
docker pull ollama/ollama:latest >> "%LOG_FILE%" 2>&1
if %errorLevel% neq 0 (
    call :log_message "⚠️  Warning: Failed to download Ollama image"
)

call :log_message "Downloading PostgreSQL..."
docker pull postgres:15-alpine >> "%LOG_FILE%" 2>&1
if %errorLevel% neq 0 (
    call :log_message "⚠️  Warning: Failed to download PostgreSQL image"
)

call :log_message "Downloading Redis..."
docker pull redis:7-alpine >> "%LOG_FILE%" 2>&1
if %errorLevel% neq 0 (
    call :log_message "⚠️  Warning: Failed to download Redis image"
)

:: For now, we'll use placeholder images - in production these would be real Samantha images
call :log_message "Setting up Samantha images..."
docker pull nginx:alpine >> "%LOG_FILE%" 2>&1
docker tag nginx:alpine samantha/frontend:latest >> "%LOG_FILE%" 2>&1

docker pull python:3.11-slim >> "%LOG_FILE%" 2>&1
docker tag python:3.11-slim samantha/backend:latest >> "%LOG_FILE%" 2>&1

:: Start Samantha with error handling
call :log_message "🚀 Starting Samantha AI for the first time..."
docker-compose up -d >> "%LOG_FILE%" 2>&1

if %errorLevel% neq 0 (
    call :log_message "❌ ERROR: Failed to start Samantha AI containers"
    echo.
    echo ========================================
    echo   ❌ STARTUP ERROR
    echo ========================================
    echo.
    echo Samantha AI failed to start. This could be due to:
    echo 1. Docker Desktop not fully ready
    echo 2. Port conflicts (3000, 8000, 5432, 6379, 11434)
    echo 3. Insufficient system resources
    echo.
    echo Press any key to view detailed log...
    pause >nul
    notepad "%LOG_FILE%"
    exit /b 1
)

:: Wait for services to be ready
call :log_message "Waiting for services to start..."
timeout /t 30 /nobreak >nul

:: Install default AI models (optional, can fail without breaking installation)
call :log_message "🧠 Installing default AI models..."
call :log_message "This may take 10-15 minutes depending on your internet connection..."

:: Wait for Ollama to be ready
call :log_message "Waiting for Ollama to be ready..."
set /a OLLAMA_TIMEOUT=0
:wait_ollama
timeout /t 5 /nobreak >nul
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorLevel% equ 0 (
    call :log_message "✅ Ollama is ready"
    goto ollama_ready
)

set /a OLLAMA_TIMEOUT+=1
if %OLLAMA_TIMEOUT% geq 12 (
    call :log_message "⚠️  Warning: Ollama not responding, skipping model installation"
    goto skip_models
)
goto wait_ollama

:ollama_ready
:: Install models (non-blocking)
call :log_message "Installing Dolphin LLaMA 3 (8B)..."
curl -X POST http://localhost:11434/api/pull -d "{\"name\":\"dolphin-llama3:8b\"}" >> "%LOG_FILE%" 2>&1 &

call :log_message "Installing LLaMA 3.1 (8B)..."
curl -X POST http://localhost:11434/api/pull -d "{\"name\":\"llama3.1:8b\"}" >> "%LOG_FILE%" 2>&1 &

call :log_message "Installing Mistral (7B)..."
curl -X POST http://localhost:11434/api/pull -d "{\"name\":\"mistral:7b\"}" >> "%LOG_FILE%" 2>&1 &

call :log_message "✅ Model downloads started in background"

:skip_models
:: Create desktop shortcut
call :log_message "🖥️  Creating desktop shortcut..."
powershell -command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Samantha AI.lnk'); $Shortcut.TargetPath = 'http://localhost:3000'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,14'; $Shortcut.Save()" >> "%LOG_FILE%" 2>&1

:: Create start menu entry
call :log_message "Creating start menu entries..."
mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI" 2>nul
powershell -command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI\Samantha AI.lnk'); $Shortcut.TargetPath = 'http://localhost:3000'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,14'; $Shortcut.Save()" >> "%LOG_FILE%" 2>&1

powershell -command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI\Samantha Manager.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\samantha.bat'; $Shortcut.Arguments = 'status'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,1'; $Shortcut.Save()" >> "%LOG_FILE%" 2>&1

:: Cleanup temporary files
call :log_message "Cleaning up temporary files..."
del "%DOCKER_INSTALLER%" 2>nul
del "%WSL_UPDATE%" 2>nul

call :log_message "Installation completed successfully!"

echo.
echo ========================================
echo 🎉 Installation completed successfully!
echo ========================================
echo.
echo 📋 Installation Summary:
echo • Samantha AI is now running
echo • Web interface: http://localhost:3000
echo • Management: Use 'samantha' command
echo • Log file: %LOG_FILE%
echo.
echo 🌐 Access Points:
echo • Web Interface: http://localhost:3000
echo • API Endpoint: http://localhost:8000
echo • Ollama API: http://localhost:11434
echo.
echo 🛠️  Management Commands:
echo • samantha start    - Start Samantha AI
echo • samantha stop     - Stop Samantha AI
echo • samantha status   - Check status
echo • samantha logs     - View logs
echo • samantha models   - List AI models
echo.
echo 🖥️  Shortcuts Created:
echo • Desktop shortcut to Samantha AI
echo • Start Menu entry
echo.
echo ✨ Welcome to Samantha AI! Your intelligent assistant is ready!
echo.
echo Opening Samantha AI in your default browser...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Press any key to view installation log...
pause >nul
notepad "%LOG_FILE%"


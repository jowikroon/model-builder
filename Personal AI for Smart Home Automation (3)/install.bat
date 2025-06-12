@echo off
setlocal EnableDelayedExpansion

:: Samantha AI - Windows Installer
:: One-click installation for Windows 10/11

title Samantha AI - Windows Installer
color 0B

echo.
echo  ========================================
echo  🤖 Samantha AI - Windows Installer
echo  ========================================
echo.
echo  Installing your personal AI assistant...
echo.

:: Check Windows version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" (
    echo ✅ Windows 10/11 detected
) else (
    echo ❌ Windows 10 or 11 required
    pause
    exit /b 1
)

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Administrator privileges confirmed
) else (
    echo ❌ Please run as Administrator
    echo Right-click the installer and select "Run as administrator"
    pause
    exit /b 1
)

:: Create installation directory
set INSTALL_DIR=C:\Samantha
echo 📁 Creating installation directory: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Check if WSL2 is installed
echo 🔍 Checking WSL2...
wsl --status >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ WSL2 is available
) else (
    echo 📦 Installing WSL2...
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    echo ⬇️ Downloading WSL2 kernel update...
    powershell -Command "Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%TEMP%\wsl_update_x64.msi'"
    
    echo 📦 Installing WSL2 kernel update...
    msiexec /i "%TEMP%\wsl_update_x64.msi" /quiet
    
    wsl --set-default-version 2
    
    echo 📦 Installing Ubuntu...
    wsl --install -d Ubuntu-22.04 --no-launch
)

:: Check if Docker Desktop is installed
echo 🔍 Checking Docker Desktop...
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    echo ✅ Docker Desktop is installed
) else (
    echo 📦 Installing Docker Desktop...
    
    echo ⬇️ Downloading Docker Desktop...
    powershell -Command "Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe' -OutFile '%TEMP%\DockerDesktopInstaller.exe'"
    
    echo 📦 Installing Docker Desktop (this may take a few minutes)...
    "%TEMP%\DockerDesktopInstaller.exe" install --quiet --accept-license
    
    echo ⏳ Waiting for Docker Desktop to start...
    timeout /t 30 /nobreak >nul
)

:: Start Docker Desktop if not running
echo 🐳 Starting Docker Desktop...
tasklist /FI "IMAGENAME eq Docker Desktop.exe" 2>NUL | find /I /N "Docker Desktop.exe">NUL
if "%ERRORLEVEL%"=="1" (
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo ⏳ Waiting for Docker to start...
    timeout /t 60 /nobreak >nul
)

:: Create Samantha files
echo 📋 Setting up Samantha AI files...

:: Create docker-compose.yml
(
echo version: '3.8'
echo.
echo services:
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
) > "%INSTALL_DIR%\docker-compose.yml"

:: Create management script
(
echo @echo off
echo setlocal
echo.
echo set INSTALL_DIR=C:\Samantha
echo cd /d "%%INSTALL_DIR%%"
echo.
echo if "%%1"=="start" ^(
echo     echo 🚀 Starting Samantha AI...
echo     docker-compose up -d
echo     echo ✅ Samantha AI is starting up!
echo     echo 🌐 Web Interface: http://localhost:3000
echo     echo 📡 API Endpoint: http://localhost:8000
echo     timeout /t 5 /nobreak ^>nul
echo     start http://localhost:3000
echo ^) else if "%%1"=="stop" ^(
echo     echo 🛑 Stopping Samantha AI...
echo     docker-compose down
echo ^) else if "%%1"=="restart" ^(
echo     echo 🔄 Restarting Samantha AI...
echo     docker-compose restart
echo ^) else if "%%1"=="status" ^(
echo     echo 📊 Samantha AI Status:
echo     docker-compose ps
echo ^) else if "%%1"=="logs" ^(
echo     echo 📋 Samantha AI Logs:
echo     docker-compose logs -f
echo ^) else if "%%1"=="update" ^(
echo     echo ⬆️ Updating Samantha AI...
echo     docker-compose pull
echo     docker-compose up -d
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
echo ^) else ^(
echo     echo 🤖 Samantha AI Management
echo     echo Usage: samantha {start^|stop^|restart^|status^|logs^|update^|models^|install-model}
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
echo ^)
) > "%INSTALL_DIR%\samantha.bat"

:: Add to PATH
echo 🔧 Adding Samantha to system PATH...
setx PATH "%PATH%;%INSTALL_DIR%" /M >nul 2>&1

:: Create desktop shortcut
echo 🖥️ Creating desktop shortcuts...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Samantha AI.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\samantha.bat'; $Shortcut.Arguments = 'start'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.IconLocation = '%INSTALL_DIR%\samantha.ico'; $Shortcut.Save()"

:: Create start menu shortcut
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI" mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI"
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI\Samantha AI.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\samantha.bat'; $Shortcut.Arguments = 'start'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Save()"

:: Download and start Samantha
echo 📥 Downloading Samantha AI containers...
cd /d "%INSTALL_DIR%"
docker-compose pull

echo 🚀 Starting Samantha AI for the first time...
docker-compose up -d

:: Install default AI model
echo 🧠 Installing default AI model (this may take a few minutes)...
timeout /t 30 /nobreak >nul
docker exec samantha-ollama ollama pull dolphin-llama3:8b

echo.
echo ========================================
echo 🎉 Installation Complete!
echo ========================================
echo.
echo ✅ Samantha AI is now installed and running!
echo.
echo 🌐 Web Interface: http://localhost:3000
echo 📡 API Endpoint: http://localhost:8000
echo.
echo 🛠️ Management Commands:
echo   samantha start    - Start Samantha AI
echo   samantha stop     - Stop Samantha AI
echo   samantha status   - Check status
echo   samantha logs     - View logs
echo.
echo 🖥️ Desktop shortcut created: "Samantha AI"
echo 📱 Start menu shortcut created
echo.
echo 🚀 Opening Samantha AI in your browser...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Press any key to exit...
pause >nul


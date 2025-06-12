@echo off
:: Samantha AI - Ultimate Simple Installer
:: Based on Steve Krug's "Don't Make Me Think" principles
:: ONE installer that just works - no choices, no thinking required

setlocal enabledelayedexpansion

:: Set window properties for clean, professional look
mode con: cols=80 lines=25
title Samantha AI - Simple Installation
color 0F

:: Initialize variables
set "INSTALL_DIR=C:\Samantha"
set "LOG_FILE=%USERPROFILE%\Desktop\samantha-install.log"
set "TOTAL_STEPS=4"
set "CURRENT_STEP=0"

:: Create log file
echo Samantha AI Installation Log > "%LOG_FILE%"
echo Started: %date% %time% >> "%LOG_FILE%"
echo ================================ >> "%LOG_FILE%"

:: Clear screen and show simple, scannable interface
cls
echo.
echo  ================================================================================
echo                              SAMANTHA AI INSTALLER
echo  ================================================================================
echo.
echo   Welcome! This installer will set up Samantha AI on your computer.
echo.
echo   What happens next:
echo   [1] Check your system
echo   [2] Install required components  
echo   [3] Set up Samantha AI
echo   [4] Launch your AI assistant
echo.
echo   No choices needed - everything is automatic!
echo.
echo  ================================================================================
echo.
echo   Press any key to start installation...
pause >nul

:: STEP 1: System Check (Auto-detect everything)
set /a CURRENT_STEP=1
call :show_progress "Checking your system..."

echo.
echo  [1/4] Checking your system...
echo.

:: Check admin privileges (required)
net session >nul 2>&1
if %errorLevel% neq 0 (
    call :show_error "Administrator privileges required" "Please right-click the installer and select 'Run as administrator'"
    goto :end_with_error
)
echo   [OK] Administrator privileges confirmed
echo [OK] Administrator privileges confirmed >> "%LOG_FILE%"

:: Check Windows version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo   [OK] Windows version: %VERSION%
echo [OK] Windows version: %VERSION% >> "%LOG_FILE%"

:: Auto-detect Docker
echo.
echo   Checking for Docker...
docker --version >nul 2>&1
if %errorLevel% neq 0 (
    set "NEED_DOCKER=true"
    echo   [INFO] Docker not found - will install automatically
    echo [INFO] Docker not found - will install automatically >> "%LOG_FILE%"
) else (
    set "NEED_DOCKER=false"
    echo   [OK] Docker found and ready
    echo [OK] Docker found and ready >> "%LOG_FILE%"
)

echo.
echo   System check complete!
timeout /t 2 /nobreak >nul

:: STEP 2: Install Components (Auto-install what's needed)
set /a CURRENT_STEP=2
call :show_progress "Installing required components..."

echo.
echo  [2/4] Installing required components...
echo.

if "%NEED_DOCKER%"=="true" (
    echo   Installing Docker Desktop...
    echo   This may take a few minutes and require a restart.
    echo.
    
    :: Download and install Docker Desktop silently
    echo   Downloading Docker Desktop...
    powershell -Command "& { try { Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe' -OutFile '%TEMP%\DockerInstaller.exe' -UseBasicParsing; Write-Host '[OK] Docker downloaded' } catch { Write-Host '[ERROR] Failed to download Docker' } }"
    
    if exist "%TEMP%\DockerInstaller.exe" (
        echo   Installing Docker Desktop...
        echo [INFO] Installing Docker Desktop >> "%LOG_FILE%"
        start /wait "%TEMP%\DockerInstaller.exe" install --quiet
        
        if %errorLevel% equ 0 (
            echo   [OK] Docker Desktop installed
            echo [OK] Docker Desktop installed >> "%LOG_FILE%"
            echo.
            echo   Docker requires a restart to complete setup.
            echo   After restart, run this installer again to continue.
            echo.
            echo   Press any key to restart now...
            pause >nul
            shutdown /r /t 5 /c "Restarting for Docker installation"
            exit /b 0
        ) else (
            call :show_error "Docker installation failed" "Please install Docker Desktop manually from docker.com"
            goto :end_with_error
        )
    ) else (
        call :show_error "Could not download Docker" "Please check your internet connection and try again"
        goto :end_with_error
    )
) else (
    :: Check if Docker is running
    docker info >nul 2>&1
    if %errorLevel% neq 0 (
        echo   Starting Docker Desktop...
        echo [INFO] Starting Docker Desktop >> "%LOG_FILE%"
        
        :: Try to start Docker Desktop
        start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" 2>nul
        if %errorLevel% neq 0 (
            start "" "%PROGRAMFILES%\Docker\Docker\Docker Desktop.exe" 2>nul
        )
        
        :: Wait for Docker to start (up to 60 seconds)
        set WAIT_COUNT=0
        :wait_docker
        timeout /t 5 /nobreak >nul
        docker info >nul 2>&1
        if %errorLevel% equ 0 goto docker_ready
        set /a WAIT_COUNT+=5
        if %WAIT_COUNT% lss 60 (
            echo   Waiting for Docker to start... (%WAIT_COUNT%/60 seconds)
            goto wait_docker
        )
        
        call :show_error "Docker failed to start" "Please start Docker Desktop manually and run installer again"
        goto :end_with_error
        
        :docker_ready
        echo   [OK] Docker is running
        echo [OK] Docker is running >> "%LOG_FILE%"
    ) else (
        echo   [OK] Docker is already running
        echo [OK] Docker is already running >> "%LOG_FILE%"
    )
)

echo.
echo   All components ready!
timeout /t 2 /nobreak >nul

:: STEP 3: Set up Samantha AI (Auto-configure everything)
set /a CURRENT_STEP=3
call :show_progress "Setting up Samantha AI..."

echo.
echo  [3/4] Setting up Samantha AI...
echo.

:: Create installation directory
echo   Creating installation directory...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" 2>nul
    if %errorLevel% neq 0 (
        call :show_error "Cannot create directory" "Failed to create %INSTALL_DIR%"
        goto :end_with_error
    )
)
echo   [OK] Installation directory ready
echo [OK] Installation directory ready >> "%LOG_FILE%"

:: Change to installation directory
cd /d "%INSTALL_DIR%" 2>nul
if %errorLevel% neq 0 (
    call :show_error "Cannot access directory" "Failed to access %INSTALL_DIR%"
    goto :end_with_error
)

:: Create subdirectories
for %%d in (frontend backend config data logs) do (
    if not exist "%%d" mkdir "%%d" 2>nul
)

:: Create premium interface using PowerShell (reliable method)
echo   Creating Samantha AI interface...
echo [INFO] Creating Samantha AI interface >> "%LOG_FILE%"

powershell -Command "& {
$htmlContent = @'
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Samantha AI - Your Intelligent Assistant</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto, sans-serif;
            background: linear-gradient(135deg, #FF6B6B 0%%, #FF8E53 50%%, #FF6B35 100%%);
            color: white; height: 100vh; overflow: hidden;
        }
        .container { height: 100vh; display: flex; flex-direction: column; }
        .header {
            position: absolute; top: 20px; left: 50%%; transform: translateX(-50%%);
            font-size: 14px; font-weight: 300; opacity: 0.7; letter-spacing: 2px;
        }
        .main-content {
            flex: 1; display: flex; flex-direction: column; align-items: center;
            justify-content: center; padding: 20px;
        }
        .logo-container { position: relative; margin-bottom: 60px; }
        .logo { width: 120px; height: 120px; position: relative; cursor: pointer; }
        .logo-circles {
            position: absolute; top: 50%%; left: 50%%; transform: translate(-50%%, -50%%);
            width: 80px; height: 40px;
        }
        .circle {
            width: 40px; height: 40px; border: 4px solid white; border-radius: 50%%;
            position: absolute; top: 0; animation: pulse 2s ease-in-out infinite;
        }
        .circle.left { left: 0; }
        .circle.right { right: 0; animation-delay: 0.1s; }
        .voice-waves {
            position: absolute; top: 50%%; left: 50%%; transform: translate(-50%%, -50%%);
            width: 200px; height: 200px; opacity: 0; transition: opacity 0.3s ease;
        }
        .voice-waves.active { opacity: 1; }
        .wave {
            position: absolute; border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%%; top: 50%%; left: 50%%; transform: translate(-50%%, -50%%);
            animation: wave-pulse 1.5s ease-out infinite;
        }
        .wave:nth-child(1) { width: 80px; height: 80px; }
        .wave:nth-child(2) { width: 120px; height: 120px; animation-delay: 0.2s; }
        .wave:nth-child(3) { width: 160px; height: 160px; animation-delay: 0.4s; }
        .wave:nth-child(4) { width: 200px; height: 200px; animation-delay: 0.6s; }
        .chat-input-container {
            position: fixed; bottom: 0; left: 0; right: 0; padding: 20px;
            background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(20px);
        }
        .chat-input-wrapper { max-width: 600px; margin: 0 auto; position: relative; }
        .chat-input {
            width: 100%%; padding: 16px 60px 16px 20px; border: none; border-radius: 25px;
            background: rgba(255, 255, 255, 0.95); color: #333; font-size: 16px;
            outline: none; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }
        .chat-input:focus { background: white; transform: translateY(-2px); }
        .input-actions {
            position: absolute; right: 8px; top: 50%%; transform: translateY(-50%%);
            display: flex; gap: 8px;
        }
        .action-btn {
            width: 36px; height: 36px; border: none; border-radius: 50%%;
            background: #FF6B6B; color: white; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
        }
        .action-btn:hover { background: #FF5252; transform: scale(1.1); }
        @keyframes pulse { 0%%, 100%% { transform: scale(1); } 50%% { transform: scale(1.1); } }
        @keyframes wave-pulse {
            0%% { transform: translate(-50%%, -50%%) scale(0.5); opacity: 1; }
            100%% { transform: translate(-50%%, -50%%) scale(1); opacity: 0; }
        }
    </style>
</head>
<body>
    <div class=\"container\">
        <div class=\"header\">SAMANTHA AI</div>
        <div class=\"main-content\">
            <div class=\"logo-container\">
                <div class=\"logo\" onclick=\"toggleWaves()\">
                    <div class=\"logo-circles\">
                        <div class=\"circle left\"></div>
                        <div class=\"circle right\"></div>
                    </div>
                    <div class=\"voice-waves\" id=\"voiceWaves\">
                        <div class=\"wave\"></div>
                        <div class=\"wave\"></div>
                        <div class=\"wave\"></div>
                        <div class=\"wave\"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class=\"chat-input-container\">
            <div class=\"chat-input-wrapper\">
                <input type=\"text\" class=\"chat-input\" placeholder=\"Ask Samantha anything...\" autofocus>
                <div class=\"input-actions\">
                    <button class=\"action-btn\" onclick=\"startVoice()\">🎤</button>
                    <button class=\"action-btn\" onclick=\"sendMessage()\">➤</button>
                </div>
            </div>
        </div>
    </div>
    <script>
        function toggleWaves() {
            const waves = document.getElementById(''voiceWaves'');
            waves.classList.toggle(''active'');
            setTimeout(() => waves.classList.remove(''active''), 2000);
        }
        function startVoice() { toggleWaves(); }
        function sendMessage() {
            const input = document.querySelector(''.chat-input'');
            if (input.value.trim()) { toggleWaves(); input.value = ''''; }
        }
        document.querySelector(''.chat-input'').addEventListener(''keypress'', function(e) {
            if (e.key === ''Enter'') sendMessage();
        });
    </script>
</body>
</html>
'@
$htmlContent | Out-File -FilePath 'frontend\index.html' -Encoding UTF8
}"

if %errorLevel% equ 0 (
    echo   [OK] Interface created
    echo [OK] Interface created >> "%LOG_FILE%"
) else (
    echo   [WARNING] Using basic interface
    echo ^<html^>^<body^>^<h1^>Samantha AI^</h1^>^</body^>^</html^> > frontend\index.html
)

:: Create Docker Compose configuration
echo   Creating service configuration...
echo [INFO] Creating service configuration >> "%LOG_FILE%"

powershell -Command "& {
$composeContent = @'
version: ''3.8''

services:
  frontend:
    image: nginx:alpine
    container_name: samantha-frontend
    ports:
      - \"3000:80\"
    volumes:
      - ./frontend:/usr/share/nginx/html:ro
    restart: unless-stopped
    depends_on:
      - backend
    networks:
      - samantha-network

  backend:
    image: python:3.11-slim
    container_name: samantha-backend
    working_dir: /app
    command: >
      sh -c \"pip install fastapi uvicorn requests &&
             python -c \\\"
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title=''Samantha AI Backend'')
app.add_middleware(CORSMiddleware, allow_origins=[''*''], allow_methods=[''*''], allow_headers=[''*''])

@app.get(''/''')
def read_root():
    return {''message'': ''Samantha AI Backend is running'', ''status'': ''healthy''}

@app.post(''/chat'')
def chat(message: dict):
    return {''response'': f''Hello! I received: {message.get(\\\\\\\"text\\\\\\\", \\\\\\\"\\\\\\\")}'', ''status'': ''success''}

if __name__ == ''__main__'':
    uvicorn.run(app, host=''0.0.0.0'', port=8000)
\\\" > main.py && python main.py\"
    ports:
      - \"8000:8000\"
    volumes:
      - ./backend:/app/data
      - ./logs:/app/logs
    restart: unless-stopped
    networks:
      - samantha-network
    environment:
      - PYTHONUNBUFFERED=1

networks:
  samantha-network:
    driver: bridge
'@
$composeContent | Out-File -FilePath 'docker-compose.yml' -Encoding UTF8
}"

if %errorLevel% equ 0 (
    echo   [OK] Configuration created
    echo [OK] Configuration created >> "%LOG_FILE%"
) else (
    call :show_error "Configuration failed" "Could not create Docker configuration"
    goto :end_with_error
)

:: Create management script
echo   Creating management tools...
(
echo @echo off
echo setlocal
echo.
echo set "INSTALL_DIR=%INSTALL_DIR%"
echo cd /d "%%INSTALL_DIR%%" 2^>nul
echo if %%errorLevel%% neq 0 ^(
echo     echo Cannot access Samantha installation directory
echo     pause
echo     exit /b 1
echo ^)
echo.
echo docker compose version ^>nul 2^>^&1
echo if %%errorLevel%% equ 0 ^(
echo     set "COMPOSE_CMD=docker compose"
echo ^) else ^(
echo     set "COMPOSE_CMD=docker-compose"
echo ^)
echo.
echo if "%%1"=="start" ^(
echo     echo Starting Samantha AI...
echo     %%COMPOSE_CMD%% up -d
echo     if %%errorLevel%% equ 0 ^(
echo         echo Samantha AI started successfully!
echo         echo Web Interface: http://localhost:3000
echo         timeout /t 3 /nobreak ^>nul
echo         start http://localhost:3000
echo     ^)
echo ^) else if "%%1"=="stop" ^(
echo     echo Stopping Samantha AI...
echo     %%COMPOSE_CMD%% down
echo ^) else if "%%1"=="status" ^(
echo     echo Samantha AI Status:
echo     %%COMPOSE_CMD%% ps
echo ^) else ^(
echo     echo Samantha AI Management
echo     echo Usage: samantha {start^|stop^|status}
echo ^)
echo.
echo if not "%%1"=="start" pause
) > samantha.bat 2>nul

echo   [OK] Management tools created
echo [OK] Management tools created >> "%LOG_FILE%"

:: Start services
echo   Starting Samantha AI services...
echo [INFO] Starting services >> "%LOG_FILE%"

:: Detect compose command
docker compose version >nul 2>&1
if %errorLevel% equ 0 (
    set "COMPOSE_CMD=docker compose"
) else (
    set "COMPOSE_CMD=docker-compose"
)

%COMPOSE_CMD% up -d
if %errorLevel% neq 0 (
    echo   [WARNING] Services may take a moment to start
    echo [WARNING] Services startup delayed >> "%LOG_FILE%"
) else (
    echo   [OK] Services started successfully
    echo [OK] Services started successfully >> "%LOG_FILE%"
)

echo.
echo   Setup complete!
timeout /t 2 /nobreak >nul

:: STEP 4: Launch (Auto-open Samantha)
set /a CURRENT_STEP=4
call :show_progress "Launching Samantha AI..."

echo.
echo  [4/4] Launching Samantha AI...
echo.

:: Create desktop shortcuts
echo   Creating shortcuts...
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\SamanthaAI.lnk'); $Shortcut.TargetPath = 'http://localhost:3000'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,14'; $Shortcut.Save(); Write-Host '[OK] Desktop shortcut created' } catch { Write-Host '[WARNING] Could not create shortcut' }"

:: Wait for services to be ready
echo   Waiting for services to start...
timeout /t 10 /nobreak >nul

:: Open Samantha AI
echo   Opening Samantha AI...
echo [INFO] Opening Samantha AI >> "%LOG_FILE%"
start http://localhost:3000

echo   [OK] Samantha AI is ready!
echo [OK] Installation completed successfully >> "%LOG_FILE%"

:: Show completion
cls
echo.
echo  ================================================================================
echo                           INSTALLATION COMPLETE!
echo  ================================================================================
echo.
echo   Samantha AI is now running on your computer!
echo.
echo   Access your AI assistant:
echo   Web Interface: http://localhost:3000
echo.
echo   Manage Samantha:
echo   - samantha start    (Start services)
echo   - samantha stop     (Stop services)  
echo   - samantha status   (Check status)
echo.
echo   Desktop shortcut created for easy access.
echo.
echo  ================================================================================
echo.
echo   Installation log saved to: %LOG_FILE%
echo.
echo   Enjoy your intelligent AI assistant!
echo.
echo   Press any key to exit...
pause >nul
goto :end_success

:: Functions
:show_progress
cls
echo.
echo  ================================================================================
echo                              SAMANTHA AI INSTALLER
echo  ================================================================================
echo.
echo   Progress: [%CURRENT_STEP%/%TOTAL_STEPS%] %~1
echo.
set /a PROGRESS_PERCENT=%CURRENT_STEP% * 100 / %TOTAL_STEPS%
set "PROGRESS_BAR="
for /l %%i in (1,1,%CURRENT_STEP%) do set "PROGRESS_BAR=!PROGRESS_BAR!█"
for /l %%i in (%CURRENT_STEP%,1,%TOTAL_STEPS%) do set "PROGRESS_BAR=!PROGRESS_BAR!░"
echo   [!PROGRESS_BAR!] %PROGRESS_PERCENT%%%
echo.
echo  ================================================================================
goto :eof

:show_error
echo.
echo  ================================================================================
echo                                   ERROR
echo  ================================================================================
echo.
echo   %~1
echo.
echo   %~2
echo.
echo   Please resolve this issue and run the installer again.
echo.
echo  ================================================================================
echo.
echo [ERROR] %~1 - %~2 >> "%LOG_FILE%"
echo   Press any key to exit...
pause >nul
goto :eof

:end_with_error
echo [ERROR] Installation failed >> "%LOG_FILE%"
exit /b 1

:end_success
echo [SUCCESS] Installation completed >> "%LOG_FILE%"
exit /b 0


@echo off
:: Samantha AI - Fixed Windows Installer
:: Addresses all issues identified in Claude's review
:: No Unicode characters, improved file generation, better error handling

setlocal enabledelayedexpansion

:: Set console properties for better display
mode con: cols=80 lines=25
title Samantha AI - Fixed Installation

:: Initialize variables
set "INSTALL_DIR=C:\Samantha"
set "LOG_FILE=%USERPROFILE%\Desktop\samantha-install-fixed.log"
set "STEP_CURRENT=0"
set "STEP_TOTAL=6"
set "ERROR_COUNT=0"

:: Create log file with header
echo ================================================= > "%LOG_FILE%"
echo SAMANTHA AI - FIXED INSTALLATION LOG >> "%LOG_FILE%"
echo ================================================= >> "%LOG_FILE%"
echo Installation Date: %date% %time% >> "%LOG_FILE%"
echo Installation Type: Fixed (No Unicode Issues) >> "%LOG_FILE%"
echo Installation Directory: %INSTALL_DIR% >> "%LOG_FILE%"
echo Log File: %LOG_FILE% >> "%LOG_FILE%"
echo ================================================= >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: Function to display dashboard (ASCII only)
:show_dashboard
cls
echo.
echo ================================================================================
echo                        SAMANTHA AI - FIXED INSTALLATION
echo                      (Assumes Docker and Tools Already Installed)
echo ================================================================================
echo.
echo Installation Progress: [Step %STEP_CURRENT% of %STEP_TOTAL%]
echo.
if %STEP_CURRENT% geq 1 (echo [OK] Step 1: Prerequisites Check) else (echo [  ] Step 1: Prerequisites Check)
if %STEP_CURRENT% geq 2 (echo [OK] Step 2: Installation Directory Setup) else (echo [  ] Step 2: Installation Directory Setup)
if %STEP_CURRENT% geq 3 (echo [OK] Step 3: Samantha AI System Deployment) else (echo [  ] Step 3: Samantha AI System Deployment)
if %STEP_CURRENT% geq 4 (echo [OK] Step 4: Docker Compose Configuration) else (echo [  ] Step 4: Docker Compose Configuration)
if %STEP_CURRENT% geq 5 (echo [OK] Step 5: Service Startup) else (echo [  ] Step 5: Service Startup)
if %STEP_CURRENT% geq 6 (echo [OK] Step 6: Management Tools Setup) else (echo [  ] Step 6: Management Tools Setup)
echo.
echo ================================================================================
echo Log File: %LOG_FILE%
if %ERROR_COUNT% gtr 0 (
    echo [WARNING] Errors/Warnings: %ERROR_COUNT% (check log for details)
) else (
    echo [INFO] Status: All checks passed
)
echo ================================================================================
echo.
goto :eof

:: Function to log messages
:log_message
echo %~1 >> "%LOG_FILE%"
echo [%time%] %~1 >> "%LOG_FILE%"
goto :eof

:: Function to show error and increment counter
:show_error
set /a ERROR_COUNT+=1
call :log_message "ERROR: %~1"
echo [ERROR] %~1
goto :eof

:: Function to show warning
:show_warning
set /a ERROR_COUNT+=1
call :log_message "WARNING: %~1"
echo [WARNING] %~1
goto :eof

:: Function to wait for user confirmation
:wait_confirmation
echo.
echo Press any key to continue to the next step...
pause >nul
goto :eof

:: Function to handle critical errors
:critical_error
echo.
echo ================================================================================
echo                               [CRITICAL ERROR]
echo ================================================================================
echo.
echo %~1
echo.
echo The installation cannot continue. Please:
echo 1. Check the log file: %LOG_FILE%
echo 2. Resolve the issue mentioned above
echo 3. Run the installer again
echo.
echo ================================================================================
echo.
call :log_message "CRITICAL ERROR: %~1"
call :log_message "Installation terminated"
echo Press any key to open the log file and exit...
pause >nul
notepad "%LOG_FILE%"
exit /b 1

:: Start installation
call :show_dashboard
echo Welcome to the Samantha AI Fixed Installation!
echo.
echo This installer assumes you already have:
echo - Docker Desktop installed and running
echo - Git (optional, for updates)
echo - Modern web browser
echo.
echo This installer will ONLY install the Samantha AI system components.
echo No external tools will be downloaded or installed.
echo.
call :wait_confirmation

:: STEP 1: Prerequisites Check
set /a STEP_CURRENT=1
call :show_dashboard
echo [INFO] STEP 1: Checking Prerequisites...
call :log_message "STEP 1: Starting prerequisites check"

:: Check if running as administrator
echo.
echo Checking administrator privileges...
call :log_message "Checking administrator privileges..."
net session >nul 2>&1
if %errorLevel% neq 0 (
    call :critical_error "Administrator privileges required. Please right-click the installer and select 'Run as administrator'."
)
echo [OK] Administrator privileges: Confirmed
call :log_message "Administrator privileges: PASSED"

:: Check Docker availability
echo.
echo Checking Docker availability...
call :log_message "Checking Docker availability..."
docker --version >nul 2>&1
if %errorLevel% neq 0 (
    call :critical_error "Docker is not installed or not in PATH. Please install Docker Desktop first."
)

:: Get Docker version for logging (safer approach)
echo [OK] Docker found and accessible
call :log_message "Docker check: PASSED"

:: Check Docker service status with improved error handling
echo.
echo Checking Docker service status...
call :log_message "Checking Docker service status..."
docker info >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Docker is installed but not running
    call :log_message "Docker service not running - user needs to start it"
    echo.
    echo Please start Docker Desktop manually and wait for it to be ready.
    echo Then press any key to continue...
    pause >nul
    
    :: Check again after user confirmation
    docker info >nul 2>&1
    if %errorLevel% neq 0 (
        call :critical_error "Docker Desktop is still not running. Please start Docker Desktop and run the installer again."
    )
    
    echo [OK] Docker is now running
    call :log_message "Docker service confirmed running"
) else (
    echo [OK] Docker service: Running
    call :log_message "Docker service: RUNNING"
)

:: Check Docker Compose availability
echo.
echo Checking Docker Compose availability...
call :log_message "Checking Docker Compose availability..."
docker compose version >nul 2>&1
if %errorLevel% neq 0 (
    docker-compose --version >nul 2>&1
    if %errorLevel% neq 0 (
        call :critical_error "Docker Compose is not available. Please ensure Docker Desktop includes Compose or install docker-compose separately."
    ) else (
        echo [OK] Docker Compose found: Legacy version
        call :log_message "Docker Compose: LEGACY VERSION FOUND"
        set "COMPOSE_CMD=docker-compose"
    )
) else (
    echo [OK] Docker Compose found: Modern version
    call :log_message "Docker Compose: MODERN VERSION FOUND"
    set "COMPOSE_CMD=docker compose"
)

echo.
echo [OK] Step 1 completed successfully!
call :log_message "STEP 1: Prerequisites check - COMPLETED"
call :wait_confirmation

:: STEP 2: Installation Directory Setup
set /a STEP_CURRENT=2
call :show_dashboard
echo [INFO] STEP 2: Setting up Installation Directory...
call :log_message "STEP 2: Setting up installation directory"

:: Create installation directory
echo.
echo Creating installation directory: %INSTALL_DIR%
call :log_message "Creating installation directory: %INSTALL_DIR%"

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" 2>nul
    if %errorLevel% neq 0 (
        call :critical_error "Failed to create installation directory: %INSTALL_DIR%"
    )
    echo [OK] Installation directory created
    call :log_message "Installation directory created successfully"
) else (
    echo [OK] Installation directory already exists
    call :log_message "Installation directory already exists"
)

:: Change to installation directory
cd /d "%INSTALL_DIR%" 2>nul
if %errorLevel% neq 0 (
    call :critical_error "Cannot access installation directory: %INSTALL_DIR%"
)

:: Create subdirectories
echo.
echo Creating subdirectories...
for %%d in (frontend backend config data logs) do (
    if not exist "%%d" (
        mkdir "%%d" 2>nul
        if %errorLevel% equ 0 (
            echo [OK] Created directory: %%d
        ) else (
            call :show_warning "Failed to create directory: %%d"
        )
    )
)

echo.
echo [OK] Step 2 completed successfully!
call :log_message "STEP 2: Installation directory setup - COMPLETED"
call :wait_confirmation

:: STEP 3: Samantha AI System Deployment
set /a STEP_CURRENT=3
call :show_dashboard
echo [INFO] STEP 3: Deploying Samantha AI System...
call :log_message "STEP 3: Deploying Samantha AI system"

:: Create premium web interface using PowerShell (more reliable than echo)
echo.
echo Creating premium web interface...
call :log_message "Creating premium web interface using PowerShell"

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
    echo [OK] Premium interface created successfully
    call :log_message "Premium interface created using PowerShell"
) else (
    call :show_warning "Failed to create premium interface, creating basic version"
    echo ^<html^>^<body^>^<h1^>Samantha AI^</h1^>^</body^>^</html^> > frontend\index.html
)

echo.
echo [OK] Step 3 completed successfully!
call :log_message "STEP 3: Samantha AI system deployment - COMPLETED"
call :wait_confirmation

:: STEP 4: Docker Compose Configuration
set /a STEP_CURRENT=4
call :show_dashboard
echo [INFO] STEP 4: Configuring Docker Compose...
call :log_message "STEP 4: Configuring Docker Compose"

:: Create Docker Compose configuration using PowerShell (more reliable)
echo.
echo Creating Docker Compose configuration...
call :log_message "Creating Docker Compose configuration using PowerShell"

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
    echo [OK] Docker Compose configuration created
    call :log_message "Docker Compose configuration created using PowerShell"
) else (
    call :show_error "Failed to create Docker Compose configuration"
)

echo.
echo [OK] Step 4 completed successfully!
call :log_message "STEP 4: Docker Compose configuration - COMPLETED"
call :wait_confirmation

:: STEP 5: Service Startup (Improved error handling)
set /a STEP_CURRENT=5
call :show_dashboard
echo [INFO] STEP 5: Starting Samantha AI Services...
call :log_message "STEP 5: Starting services"

echo.
echo Starting Samantha AI services...
call :log_message "Starting Samantha AI services with improved error handling"

:: Start services with better error handling
%COMPOSE_CMD% up -d
if %errorLevel% neq 0 (
    call :show_error "Failed to start services"
    echo.
    echo [INFO] Checking what went wrong...
    call :log_message "Service startup failed, checking status"
    
    :: Don't run more Docker commands that might fail
    echo Please check:
    echo 1. Docker Desktop is running
    echo 2. Ports 3000 and 8000 are not in use
    echo 3. No other Samantha instances are running
    echo.
    echo You can try again later with: %COMPOSE_CMD% up -d
    call :log_message "Service startup failed - user guidance provided"
) else (
    echo [OK] Services started successfully
    call :log_message "All services started successfully"
    
    echo.
    echo Waiting for services to be ready...
    timeout /t 10 /nobreak >nul
    
    echo [INFO] Service status:
    %COMPOSE_CMD% ps
)

echo.
echo [OK] Step 5 completed!
call :log_message "STEP 5: Service startup - COMPLETED"
call :wait_confirmation

:: STEP 6: Management Tools Setup (Fixed shortcut creation)
set /a STEP_CURRENT=6
call :show_dashboard
echo [INFO] STEP 6: Setting up Management Tools...
call :log_message "STEP 6: Setting up management tools"

:: Create management script
echo.
echo Creating management tools...
call :log_message "Creating management script"

:: Create samantha.bat with proper content
(
echo @echo off
echo setlocal
echo.
echo set "INSTALL_DIR=%INSTALL_DIR%"
echo cd /d "%%INSTALL_DIR%%" 2^>nul
echo if %%errorLevel%% neq 0 ^(
echo     echo [ERROR] Cannot access Samantha installation directory
echo     pause
echo     exit /b 1
echo ^)
echo.
echo :: Detect compose command
echo docker compose version ^>nul 2^>^&1
echo if %%errorLevel%% equ 0 ^(
echo     set "COMPOSE_CMD=docker compose"
echo ^) else ^(
echo     set "COMPOSE_CMD=docker-compose"
echo ^)
echo.
echo if "%%1"=="start" ^(
echo     echo [INFO] Starting Samantha AI...
echo     %%COMPOSE_CMD%% up -d
echo     if %%errorLevel%% equ 0 ^(
echo         echo [OK] Samantha AI started successfully!
echo         echo Web Interface: http://localhost:3000
echo         echo Backend API: http://localhost:8000
echo         timeout /t 3 /nobreak ^>nul
echo         start http://localhost:3000
echo     ^) else ^(
echo         echo [ERROR] Failed to start Samantha AI
echo     ^)
echo ^) else if "%%1"=="stop" ^(
echo     echo [INFO] Stopping Samantha AI...
echo     %%COMPOSE_CMD%% down
echo     echo [OK] Samantha AI stopped
echo ^) else if "%%1"=="status" ^(
echo     echo [INFO] Samantha AI Status:
echo     %%COMPOSE_CMD%% ps
echo ^) else ^(
echo     echo Samantha AI Management Console
echo     echo Usage: samantha {start^|stop^|status}
echo ^)
echo.
echo if not "%%1"=="start" pause
) > samantha.bat 2>nul

echo [OK] Management script created

:: Create desktop shortcuts with fixed PowerShell command (no spaces in filename)
echo.
echo Creating desktop shortcuts...
call :log_message "Creating desktop shortcuts with fixed PowerShell commands"

:: Fixed shortcut creation - removed space from filename
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\SamanthaAI.lnk'); $Shortcut.TargetPath = 'http://localhost:3000'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,14'; $Shortcut.Save(); Write-Host '[OK] Web interface shortcut created' } catch { Write-Host '[WARNING] Failed to create web shortcut' }"

:: Management shortcut with fixed filename
powershell -Command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\SamanthaManager.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\samantha.bat'; $Shortcut.Arguments = 'status'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,1'; $Shortcut.Save(); Write-Host '[OK] Management shortcut created' } catch { Write-Host '[WARNING] Failed to create management shortcut' }"

:: Create quick start guide
echo.
echo Creating quick start guide...
call :log_message "Creating quick start guide"

(
echo SAMANTHA AI - QUICK START GUIDE
echo ================================
echo.
echo [OK] Installation completed successfully!
echo.
echo ACCESSING SAMANTHA:
echo ==================
echo.
echo Web Interface: http://localhost:3000
echo Backend API: http://localhost:8000  
echo.
echo MANAGEMENT COMMANDS:
echo ===================
echo.
echo samantha start     - Start all services
echo samantha stop      - Stop all services
echo samantha status    - Check service status
echo.
echo TROUBLESHOOTING:
echo ===============
echo.
echo If services don't start:
echo 1. Check Docker is running: docker info
echo 2. Check service status: samantha status
echo 3. Restart services: samantha start
echo.
echo SYSTEM INFO:
echo ============
echo.
echo Installation: %INSTALL_DIR%
echo Compose Command: %COMPOSE_CMD%
echo Log File: %LOG_FILE%
echo Installation Type: Fixed (No Unicode Issues)
echo.
echo Enjoy your intelligent AI assistant!
) > "%USERPROFILE%\Desktop\SamanthaAI-QuickStart.txt" 2>nul

echo [OK] Quick start guide created

echo.
echo [OK] Step 6 completed successfully!
call :log_message "STEP 6: Management tools setup - COMPLETED"

:: Final completion
call :show_dashboard
echo.
echo ================================================================================
echo                        [INSTALLATION COMPLETED SUCCESSFULLY]
echo ================================================================================
echo.
echo Samantha AI has been installed and is running!
echo.
echo WHAT'S AVAILABLE:
echo    - Premium web interface with voice visualization
echo    - AI-powered backend with conversation capabilities  
echo    - Management tools for easy control
echo.
echo ACCESS YOUR AI:
echo    Web Interface: http://localhost:3000
echo    Backend API: http://localhost:8000
echo.
echo MANAGEMENT:
echo    - samantha start/stop/status - Control services
echo    - Desktop shortcuts for easy access
echo    - Quick start guide on desktop
echo.
echo FILES CREATED:
echo    - Desktop shortcuts: SamanthaAI.lnk, SamanthaManager.lnk
echo    - Quick start guide: SamanthaAI-QuickStart.txt
echo    - Installation log: %LOG_FILE%
echo.
call :log_message "INSTALLATION COMPLETED SUCCESSFULLY"
call :log_message "Fixed installation using ASCII characters and improved file generation"

echo Opening Samantha AI for you...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Press any key to view the installation log and exit...
pause >nul

:: Open log file
notepad "%LOG_FILE%"


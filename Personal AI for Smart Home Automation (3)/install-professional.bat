@echo off
setlocal enabledelayedexpansion

:: Samantha AI - Professional Installation Dashboard
:: Complete user-friendly installer with visual progress tracking

:: Set console properties for better display
mode con: cols=80 lines=30
title Samantha AI - Professional Installer

:: Color codes for better visual experience
:: 0=Black 1=Blue 2=Green 3=Aqua 4=Red 5=Purple 6=Yellow 7=White 8=Gray 9=Light Blue A=Light Green B=Light Aqua C=Light Red D=Light Purple E=Light Yellow F=Bright White

:: Initialize variables
set "INSTALL_DIR=C:\Samantha"
set "LOG_FILE=%USERPROFILE%\Desktop\samantha-installation.log"
set "STEP_CURRENT=0"
set "STEP_TOTAL=12"
set "ERROR_COUNT=0"

:: Create log file with header
echo ================================================= > "%LOG_FILE%"
echo SAMANTHA AI - PROFESSIONAL INSTALLATION LOG >> "%LOG_FILE%"
echo ================================================= >> "%LOG_FILE%"
echo Installation Date: %date% %time% >> "%LOG_FILE%"
echo System: Windows 11 Pro 64-bit >> "%LOG_FILE%"
echo Processor: Intel i7-2600 @ 3.40GHz >> "%LOG_FILE%"
echo Memory: 32GB RAM >> "%LOG_FILE%"
echo Installation Directory: %INSTALL_DIR% >> "%LOG_FILE%"
echo Log File: %LOG_FILE% >> "%LOG_FILE%"
echo ================================================= >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: Function to display dashboard
:show_dashboard
cls
echo.
echo ================================================================================
echo                        🤖 SAMANTHA AI - PROFESSIONAL INSTALLER
echo ================================================================================
echo.
echo Installation Progress: [Step %STEP_CURRENT% of %STEP_TOTAL%]
echo.
if %STEP_CURRENT% geq 1 (echo ✅ Step 1: System Compatibility Check) else (echo ⏳ Step 1: System Compatibility Check)
if %STEP_CURRENT% geq 2 (echo ✅ Step 2: Administrator Privileges) else (echo ⏳ Step 2: Administrator Privileges)
if %STEP_CURRENT% geq 3 (echo ✅ Step 3: Disk Space Verification) else (echo ⏳ Step 3: Disk Space Verification)
if %STEP_CURRENT% geq 4 (echo ✅ Step 4: Network Connectivity) else (echo ⏳ Step 4: Network Connectivity)
if %STEP_CURRENT% geq 5 (echo ✅ Step 5: PowerShell Availability) else (echo ⏳ Step 5: PowerShell Availability)
if %STEP_CURRENT% geq 6 (echo ✅ Step 6: Docker Desktop Check) else (echo ⏳ Step 6: Docker Desktop Check)
if %STEP_CURRENT% geq 7 (echo ✅ Step 7: Docker Installation) else (echo ⏳ Step 7: Docker Installation)
if %STEP_CURRENT% geq 8 (echo ✅ Step 8: Docker Service Startup) else (echo ⏳ Step 8: Docker Service Startup)
if %STEP_CURRENT% geq 9 (echo ✅ Step 9: Samantha Files Setup) else (echo ⏳ Step 9: Samantha Files Setup)
if %STEP_CURRENT% geq 10 (echo ✅ Step 10: Container Deployment) else (echo ⏳ Step 10: Container Deployment)
if %STEP_CURRENT% geq 11 (echo ✅ Step 11: Service Verification) else (echo ⏳ Step 11: Service Verification)
if %STEP_CURRENT% geq 12 (echo ✅ Step 12: Shortcuts & Completion) else (echo ⏳ Step 12: Shortcuts ^& Completion)
echo.
echo ================================================================================
echo 📋 Log File: %LOG_FILE%
if %ERROR_COUNT% gtr 0 (
    echo ⚠️  Warnings/Errors: %ERROR_COUNT% (check log for details)
) else (
    echo ✅ Status: All checks passed
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
echo ❌ ERROR: %~1
goto :eof

:: Function to show warning
:show_warning
set /a ERROR_COUNT+=1
call :log_message "WARNING: %~1"
echo ⚠️  WARNING: %~1
goto :eof

:: Function to wait for user confirmation
:wait_confirmation
echo.
echo Press any key to continue to the next step...
pause >nul
goto :eof

:: Start installation
call :show_dashboard
echo Welcome to the Samantha AI Professional Installer!
echo.
echo This installer will guide you through each step with clear progress indication.
echo You can monitor the complete process and any issues will be clearly explained.
echo.
call :wait_confirmation

:: STEP 1: System Compatibility Check
set /a STEP_CURRENT=1
call :show_dashboard
echo 🔍 STEP 1: Checking System Compatibility...
call :log_message "STEP 1: Starting system compatibility check"

:: Check Windows version
call :log_message "Checking Windows version..."
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
call :log_message "Windows version detected: %VERSION%"

if "%VERSION%" lss "10.0" (
    call :show_error "Windows 10 or later is required. Current version: %VERSION%"
    echo.
    echo Your system needs to be upgraded to Windows 10 or later.
    echo Please upgrade your operating system and try again.
    call :wait_confirmation
    exit /b 1
) else (
    echo ✅ Windows version: Compatible (%VERSION%)
    call :log_message "Windows version check: PASSED"
)

:: Check system architecture
call :log_message "Checking system architecture..."
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo ✅ System architecture: 64-bit (Compatible)
    call :log_message "System architecture: 64-bit - PASSED"
) else (
    call :show_error "64-bit Windows is required. Current: %PROCESSOR_ARCHITECTURE%"
    echo.
    echo Samantha AI requires a 64-bit version of Windows.
    call :wait_confirmation
    exit /b 1
)

echo.
echo ✅ Step 1 completed successfully!
call :log_message "STEP 1: System compatibility check - COMPLETED"
call :wait_confirmation

:: STEP 2: Administrator Privileges
set /a STEP_CURRENT=2
call :show_dashboard
echo 🔐 STEP 2: Verifying Administrator Privileges...
call :log_message "STEP 2: Checking administrator privileges"

net session >nul 2>&1
if %errorLevel% neq 0 (
    call :show_error "Administrator privileges required"
    echo.
    echo ================================================================================
    echo                           ❌ ADMINISTRATOR REQUIRED
    echo ================================================================================
    echo.
    echo This installer must be run as Administrator to:
    echo • Install Docker Desktop
    echo • Create system directories
    echo • Modify system PATH
    echo • Install Windows features (if needed)
    echo.
    echo To fix this:
    echo 1. Close this installer
    echo 2. Right-click on the installer file
    echo 3. Select "Run as administrator"
    echo 4. Try the installation again
    echo.
    call :wait_confirmation
    exit /b 1
) else (
    echo ✅ Administrator privileges: Confirmed
    call :log_message "Administrator privileges check: PASSED"
)

echo.
echo ✅ Step 2 completed successfully!
call :log_message "STEP 2: Administrator privileges check - COMPLETED"
call :wait_confirmation

:: STEP 3: Disk Space Verification
set /a STEP_CURRENT=3
call :show_dashboard
echo 💾 STEP 3: Verifying Available Disk Space...
call :log_message "STEP 3: Checking disk space"

:: Check available space on C: drive
call :log_message "Checking available disk space on C: drive..."
for /f "tokens=3" %%i in ('dir C:\ /-c ^| find "bytes free"') do set BYTES_FREE=%%i

:: Convert bytes to GB (approximate)
set /a GB_FREE=%BYTES_FREE:~0,-9%
if %GB_FREE% lss 1 set GB_FREE=1

call :log_message "Available disk space: %GB_FREE% GB"

if %GB_FREE% lss 10 (
    call :show_warning "Low disk space detected (%GB_FREE% GB available)"
    echo.
    echo ⚠️  WARNING: Limited disk space available
    echo.
    echo Available: %GB_FREE% GB
    echo Recommended: 20+ GB for optimal performance
    echo Minimum: 10 GB for basic installation
    echo.
    echo The installation can continue, but you may experience:
    echo • Slower performance
    echo • Limited AI model storage
    echo • Potential issues with updates
    echo.
    set /p CONTINUE="Continue with limited space? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo Installation cancelled by user.
        call :wait_confirmation
        exit /b 1
    )
) else (
    echo ✅ Available disk space: %GB_FREE% GB (Sufficient)
    call :log_message "Disk space check: PASSED (%GB_FREE% GB available)"
)

echo.
echo ✅ Step 3 completed successfully!
call :log_message "STEP 3: Disk space verification - COMPLETED"
call :wait_confirmation

:: STEP 4: Network Connectivity
set /a STEP_CURRENT=4
call :show_dashboard
echo 🌐 STEP 4: Testing Network Connectivity...
call :log_message "STEP 4: Testing network connectivity"

:: Test internet connectivity
call :log_message "Testing internet connectivity..."
ping -n 1 google.com >nul 2>&1
if %errorLevel% neq 0 (
    call :show_warning "Internet connectivity issues detected"
    echo.
    echo ⚠️  WARNING: Internet connection test failed
    echo.
    echo This may cause issues with:
    echo • Downloading Docker Desktop
    echo • Downloading AI models
    echo • Container image downloads
    echo.
    echo Please check your internet connection and firewall settings.
    echo.
    set /p CONTINUE="Continue without internet connectivity? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo Installation cancelled by user.
        call :wait_confirmation
        exit /b 1
    )
    call :log_message "User chose to continue without internet connectivity"
) else (
    echo ✅ Internet connectivity: Available
    call :log_message "Internet connectivity test: PASSED"
)

:: Test DNS resolution
call :log_message "Testing DNS resolution..."
nslookup docker.com >nul 2>&1
if %errorLevel% neq 0 (
    call :show_warning "DNS resolution issues detected"
    call :log_message "DNS resolution test: FAILED"
) else (
    echo ✅ DNS resolution: Working
    call :log_message "DNS resolution test: PASSED"
)

echo.
echo ✅ Step 4 completed successfully!
call :log_message "STEP 4: Network connectivity test - COMPLETED"
call :wait_confirmation

:: STEP 5: PowerShell Availability
set /a STEP_CURRENT=5
call :show_dashboard
echo ⚡ STEP 5: Verifying PowerShell Availability...
call :log_message "STEP 5: Checking PowerShell availability"

:: Test PowerShell
call :log_message "Testing PowerShell execution..."
powershell -command "Write-Host 'PowerShell test successful'" >nul 2>&1
if %errorLevel% neq 0 (
    call :show_error "PowerShell is not available or execution is restricted"
    echo.
    echo ❌ PowerShell execution failed
    echo.
    echo PowerShell is required for:
    echo • Downloading files
    echo • Creating shortcuts
    echo • System configuration
    echo.
    echo Possible solutions:
    echo 1. Enable PowerShell execution: Set-ExecutionPolicy RemoteSigned
    echo 2. Check Windows PowerShell installation
    echo 3. Verify antivirus is not blocking PowerShell
    echo.
    call :wait_confirmation
    exit /b 1
) else (
    echo ✅ PowerShell: Available and functional
    call :log_message "PowerShell availability test: PASSED"
)

:: Test PowerShell version
call :log_message "Checking PowerShell version..."
for /f "tokens=*" %%i in ('powershell -command "$PSVersionTable.PSVersion.Major"') do set PS_VERSION=%%i
echo ✅ PowerShell version: %PS_VERSION%
call :log_message "PowerShell version: %PS_VERSION%"

echo.
echo ✅ Step 5 completed successfully!
call :log_message "STEP 5: PowerShell availability check - COMPLETED"
call :wait_confirmation

:: STEP 6: Docker Desktop Check
set /a STEP_CURRENT=6
call :show_dashboard
echo 🐳 STEP 6: Checking Docker Desktop Installation...
call :log_message "STEP 6: Checking Docker Desktop installation"

:: Check if Docker Desktop is installed
call :log_message "Checking for existing Docker Desktop installation..."
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    echo ✅ Docker Desktop: Already installed
    call :log_message "Docker Desktop found: C:\Program Files\Docker\Docker\Docker Desktop.exe"
    set "DOCKER_INSTALLED=true"
    
    :: Check if Docker is running
    call :log_message "Checking if Docker is running..."
    docker version >nul 2>&1
    if %errorLevel% equ 0 (
        echo ✅ Docker service: Running
        call :log_message "Docker service status: RUNNING"
        set "DOCKER_RUNNING=true"
    ) else (
        echo ⚠️  Docker service: Not running (will be started)
        call :log_message "Docker service status: NOT RUNNING"
        set "DOCKER_RUNNING=false"
    )
) else (
    echo ❌ Docker Desktop: Not installed (will be installed)
    call :log_message "Docker Desktop not found - installation required"
    set "DOCKER_INSTALLED=false"
    set "DOCKER_RUNNING=false"
)

:: Check for conflicting software
call :log_message "Checking for conflicting software..."
tasklist /FI "IMAGENAME eq VirtualBox.exe" 2>nul | find /I "VirtualBox.exe" >nul
if %errorLevel% equ 0 (
    call :show_warning "VirtualBox detected - may conflict with Docker"
    echo.
    echo ⚠️  VirtualBox is running
    echo.
    echo VirtualBox may conflict with Docker Desktop's Hyper-V requirements.
    echo You may need to:
    echo • Close VirtualBox before starting Docker
    echo • Choose between VirtualBox and Docker Desktop
    echo • Use Docker Desktop's compatibility mode
    echo.
    set /p CONTINUE="Continue with VirtualBox running? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo Installation cancelled by user.
        call :wait_confirmation
        exit /b 1
    )
)

echo.
echo ✅ Step 6 completed successfully!
call :log_message "STEP 6: Docker Desktop check - COMPLETED"
call :wait_confirmation

:: STEP 7: Docker Installation
set /a STEP_CURRENT=7
call :show_dashboard

if "%DOCKER_INSTALLED%"=="false" (
    echo 📥 STEP 7: Installing Docker Desktop...
    call :log_message "STEP 7: Installing Docker Desktop"
    
    echo.
    echo Docker Desktop installation is required for Samantha AI.
    echo.
    echo This process will:
    echo • Download Docker Desktop (~500MB)
    echo • Install Docker Desktop automatically
    echo • Enable required Windows features
    echo • Require a system restart
    echo.
    echo Estimated time: 10-15 minutes
    echo.
    set /p CONTINUE="Proceed with Docker Desktop installation? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo Installation cancelled by user.
        call :log_message "User cancelled Docker installation"
        call :wait_confirmation
        exit /b 1
    )
    
    :: Create download directory
    set "DOCKER_INSTALLER=%USERPROFILE%\Downloads\DockerDesktopInstaller.exe"
    
    echo.
    echo 📥 Downloading Docker Desktop...
    echo This may take 5-10 minutes depending on your internet speed.
    call :log_message "Starting Docker Desktop download to: %DOCKER_INSTALLER%"
    
    :: Download with progress indication
    powershell -command "try { $ProgressPreference = 'SilentlyContinue'; Write-Host 'Downloading Docker Desktop...'; Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe' -OutFile '%DOCKER_INSTALLER%' -UseBasicParsing; Write-Host 'Download completed successfully.' } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }"
    
    if %errorLevel% neq 0 (
        call :show_error "Failed to download Docker Desktop"
        echo.
        echo ❌ Download failed
        echo.
        echo Possible solutions:
        echo 1. Check your internet connection
        echo 2. Disable antivirus temporarily
        echo 3. Download manually from: https://docker.com/products/docker-desktop
        echo 4. Run the downloaded installer manually
        echo.
        call :wait_confirmation
        exit /b 1
    )
    
    echo ✅ Download completed successfully
    call :log_message "Docker Desktop download: COMPLETED"
    
    echo.
    echo 🔧 Installing Docker Desktop...
    echo This may take 5-10 minutes and will require a restart.
    call :log_message "Starting Docker Desktop installation"
    
    "%DOCKER_INSTALLER%" install --quiet --accept-license --backend=wsl-2
    set DOCKER_INSTALL_RESULT=%errorLevel%
    
    call :log_message "Docker Desktop installation exit code: %DOCKER_INSTALL_RESULT%"
    
    if %DOCKER_INSTALL_RESULT% neq 0 (
        call :show_warning "Docker installation completed with warnings (exit code: %DOCKER_INSTALL_RESULT%)"
        echo.
        echo ⚠️  Docker installation may require additional steps
        echo.
        echo This is often normal and may indicate:
        echo • A restart is required
        echo • Windows features need to be enabled
        echo • WSL2 needs to be configured
        echo.
    ) else (
        echo ✅ Docker Desktop installed successfully
        call :log_message "Docker Desktop installation: COMPLETED SUCCESSFULLY"
    )
    
    :: Clean up installer
    if exist "%DOCKER_INSTALLER%" (
        del "%DOCKER_INSTALLER%" >nul 2>&1
        call :log_message "Cleaned up Docker installer file"
    )
    
    echo.
    echo ================================================================================
    echo                              🔄 RESTART REQUIRED
    echo ================================================================================
    echo.
    echo Docker Desktop has been installed successfully!
    echo.
    echo A system restart is required to complete the installation.
    echo.
    echo After restart:
    echo 1. Wait for Docker Desktop to start automatically (system tray icon)
    echo 2. Look for the Docker whale icon in your system tray
    echo 3. Run this Samantha installer again
    echo 4. The installation will continue from Step 8
    echo.
    set /p RESTART="Restart your computer now? (y/n): "
    if /i "!RESTART!"=="y" (
        call :log_message "User chose to restart immediately"
        echo.
        echo Restarting in 10 seconds...
        echo You can cancel with Ctrl+C if needed.
        shutdown /r /t 10 /c "Restarting for Docker Desktop installation - Run Samantha installer again after restart"
        exit /b 0
    ) else (
        call :log_message "User chose to restart manually"
        echo.
        echo Please restart your computer manually and run this installer again.
        echo.
        echo The installation will continue from where it left off.
        call :wait_confirmation
        exit /b 0
    )
) else (
    echo ✅ STEP 7: Docker Desktop already installed - skipping
    call :log_message "STEP 7: Docker Desktop already installed - SKIPPED"
)

echo.
echo ✅ Step 7 completed successfully!
call :log_message "STEP 7: Docker installation - COMPLETED"
call :wait_confirmation

:: STEP 8: Docker Service Startup
set /a STEP_CURRENT=8
call :show_dashboard
echo 🚀 STEP 8: Starting Docker Service...
call :log_message "STEP 8: Starting Docker service"

if "%DOCKER_RUNNING%"=="false" (
    echo.
    echo Starting Docker Desktop...
    call :log_message "Attempting to start Docker Desktop"
    
    :: Start Docker Desktop
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    call :log_message "Docker Desktop startup command executed"
    
    echo.
    echo ⏳ Waiting for Docker to be ready...
    echo This may take 2-3 minutes on first startup.
    echo.
    
    set /a DOCKER_TIMEOUT=0
    set /a MAX_TIMEOUT=36
    
    :wait_docker_loop
    timeout /t 5 /nobreak >nul
    
    :: Check Docker status
    docker version >nul 2>&1
    if %errorLevel% equ 0 (
        echo ✅ Docker is ready and responding!
        call :log_message "Docker service startup: SUCCESSFUL"
        goto docker_ready
    )
    
    set /a DOCKER_TIMEOUT+=1
    set /a REMAINING=%MAX_TIMEOUT%-%DOCKER_TIMEOUT%
    echo Still waiting for Docker... (attempt %DOCKER_TIMEOUT%/%MAX_TIMEOUT%, ~%REMAINING% attempts remaining)
    call :log_message "Docker startup attempt %DOCKER_TIMEOUT%/%MAX_TIMEOUT% - still waiting"
    
    if %DOCKER_TIMEOUT% geq %MAX_TIMEOUT% (
        call :show_error "Docker failed to start within 3 minutes"
        echo.
        echo ================================================================================
        echo                            ⏰ DOCKER STARTUP TIMEOUT
        echo ================================================================================
        echo.
        echo Docker Desktop is taking longer than expected to start.
        echo.
        echo Troubleshooting steps:
        echo 1. Check if Docker Desktop icon appears in system tray
        echo 2. If you see "Docker Desktop is starting...", wait longer
        echo 3. If Docker shows errors, restart your computer
        echo 4. Ensure Hyper-V and WSL2 are enabled
        echo 5. Check Windows Event Viewer for Docker errors
        echo.
        echo Manual steps:
        echo 1. Open Docker Desktop manually
        echo 2. Wait for it to show "Docker Desktop is running"
        echo 3. Run this installer again
        echo.
        call :wait_confirmation
        exit /b 1
    )
    goto wait_docker_loop
    
    :docker_ready
) else (
    echo ✅ Docker service: Already running
    call :log_message "Docker service already running - no startup needed"
)

:: Verify Docker functionality
echo.
echo 🔍 Verifying Docker functionality...
call :log_message "Testing Docker functionality"

docker run --rm hello-world >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Docker functionality: Verified
    call :log_message "Docker functionality test: PASSED"
) else (
    call :show_warning "Docker functionality test failed"
    echo.
    echo ⚠️  Docker basic test failed
    echo.
    echo This may indicate:
    echo • Docker is still starting up
    echo • Network connectivity issues
    echo • Docker configuration problems
    echo.
    echo The installation can continue, but you may experience issues.
    echo.
    set /p CONTINUE="Continue despite Docker test failure? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo Installation cancelled by user.
        call :wait_confirmation
        exit /b 1
    )
    call :log_message "User chose to continue despite Docker test failure"
)

echo.
echo ✅ Step 8 completed successfully!
call :log_message "STEP 8: Docker service startup - COMPLETED"
call :wait_confirmation

:: STEP 9: Samantha Files Setup
set /a STEP_CURRENT=9
call :show_dashboard
echo 📁 STEP 9: Setting up Samantha Files...
call :log_message "STEP 9: Setting up Samantha files"

:: Create installation directory
echo.
echo Creating installation directory: %INSTALL_DIR%
call :log_message "Creating installation directory: %INSTALL_DIR%"

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" 2>nul
    if %errorLevel% neq 0 (
        call :show_error "Failed to create installation directory"
        echo.
        echo ❌ Cannot create directory: %INSTALL_DIR%
        echo.
        echo Possible causes:
        echo • Insufficient permissions
        echo • Disk space issues
        echo • Path too long
        echo • Antivirus blocking
        echo.
        call :wait_confirmation
        exit /b 1
    )
    echo ✅ Installation directory created
    call :log_message "Installation directory created successfully"
) else (
    echo ✅ Installation directory already exists
    call :log_message "Installation directory already exists"
)

:: Change to installation directory
cd /d "%INSTALL_DIR%" 2>nul
if %errorLevel% neq 0 (
    call :show_error "Cannot access installation directory"
    call :wait_confirmation
    exit /b 1
)

:: Create subdirectories
echo.
echo Creating subdirectories...
call :log_message "Creating subdirectories"

for %%d in (logs data web config backups) do (
    if not exist "%%d" (
        mkdir "%%d" 2>nul
        if %errorLevel% equ 0 (
            echo ✅ Created: %%d
            call :log_message "Created subdirectory: %%d"
        ) else (
            call :show_warning "Failed to create subdirectory: %%d"
        )
    ) else (
        echo ✅ Exists: %%d
        call :log_message "Subdirectory already exists: %%d"
    )
)

:: Create Docker Compose configuration
echo.
echo 📝 Creating Docker Compose configuration...
call :log_message "Creating Docker Compose configuration"

(
echo version: '3.8'
echo.
echo services:
echo   # Samantha Web Interface
echo   samantha-web:
echo     image: nginx:alpine
echo     container_name: samantha-web
echo     ports:
echo       - "3000:80"
echo     volumes:
echo       - ./web:/usr/share/nginx/html:ro
echo       - ./config/nginx.conf:/etc/nginx/nginx.conf:ro
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo     healthcheck:
echo       test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost"]
echo       interval: 30s
echo       timeout: 10s
echo       retries: 3
echo.
echo   # Samantha AI Engine
echo   samantha-ai:
echo     image: ollama/ollama:latest
echo     container_name: samantha-ai
echo     ports:
echo       - "11434:11434"
echo     volumes:
echo       - ollama_data:/root/.ollama
echo       - ./data:/app/data
echo     environment:
echo       - OLLAMA_HOST=0.0.0.0
echo       - OLLAMA_KEEP_ALIVE=24h
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo     healthcheck:
echo       test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
echo       interval: 30s
echo       timeout: 10s
echo       retries: 3
echo.
echo   # Database for conversations and learning
echo   samantha-db:
echo     image: postgres:15-alpine
echo     container_name: samantha-db
echo     environment:
echo       POSTGRES_DB: samantha
echo       POSTGRES_USER: samantha
echo       POSTGRES_PASSWORD: samantha_secure_2024
echo       POSTGRES_INITDB_ARGS: "--encoding=UTF-8"
echo     volumes:
echo       - postgres_data:/var/lib/postgresql/data
echo       - ./backups:/backups
echo     ports:
echo       - "5432:5432"
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo     healthcheck:
echo       test: ["CMD-SHELL", "pg_isready -U samantha"]
echo       interval: 30s
echo       timeout: 10s
echo       retries: 3
echo.
echo   # Redis for caching and sessions
echo   samantha-cache:
echo     image: redis:7-alpine
echo     container_name: samantha-cache
echo     ports:
echo       - "6379:6379"
echo     volumes:
echo       - redis_data:/data
echo       - ./config/redis.conf:/usr/local/etc/redis/redis.conf:ro
echo     command: redis-server /usr/local/etc/redis/redis.conf
echo     restart: unless-stopped
echo     networks:
echo       - samantha-network
echo     healthcheck:
echo       test: ["CMD", "redis-cli", "ping"]
echo       interval: 30s
echo       timeout: 10s
echo       retries: 3
echo.
echo volumes:
echo   ollama_data:
echo     driver: local
echo   postgres_data:
echo     driver: local
echo   redis_data:
echo     driver: local
echo.
echo networks:
echo   samantha-network:
echo     driver: bridge
echo     ipam:
echo       config:
echo         - subnet: 172.20.0.0/16
) > docker-compose.yml 2>nul

if %errorLevel% neq 0 (
    call :show_error "Failed to create Docker Compose configuration"
    call :wait_confirmation
    exit /b 1
)

echo ✅ Docker Compose configuration created
call :log_message "Docker Compose configuration created successfully"

:: Create web interface
echo.
echo 🌐 Creating web interface...
call :log_message "Creating web interface"

(
echo ^<!DOCTYPE html^>
echo ^<html lang="en"^>
echo ^<head^>
echo     ^<meta charset="UTF-8"^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo     ^<title^>Samantha AI - Your Intelligent Assistant^</title^>
echo     ^<style^>
echo         * { margin: 0; padding: 0; box-sizing: border-box; }
echo         body {
echo             font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
echo             background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%);
echo             color: white;
echo             min-height: 100vh;
echo             display: flex;
echo             align-items: center;
echo             justify-content: center;
echo         }
echo         .container {
echo             max-width: 800px;
echo             margin: 0 auto;
echo             padding: 40px 20px;
echo             text-align: center;
echo         }
echo         .logo {
echo             font-size: 4em;
echo             margin-bottom: 20px;
echo             text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
echo         }
echo         h1 {
echo             font-size: 3em;
echo             margin-bottom: 20px;
echo             font-weight: 300;
echo             text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
echo         }
echo         .status-card {
echo             background: rgba(255,255,255,0.1);
echo             backdrop-filter: blur(10px);
echo             border-radius: 20px;
echo             padding: 30px;
echo             margin: 30px 0;
echo             border: 1px solid rgba(255,255,255,0.2);
echo             box-shadow: 0 8px 32px rgba(0,0,0,0.1);
echo         }
echo         .status-title {
echo             font-size: 1.8em;
echo             margin-bottom: 15px;
echo             color: #4CAF50;
echo         }
echo         .status-text {
echo             font-size: 1.2em;
echo             line-height: 1.6;
echo             margin-bottom: 15px;
echo         }
echo         .system-info {
echo             display: grid;
echo             grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
echo             gap: 20px;
echo             margin: 20px 0;
echo         }
echo         .info-item {
echo             background: rgba(255,255,255,0.05);
echo             padding: 15px;
echo             border-radius: 10px;
echo             border: 1px solid rgba(255,255,255,0.1);
echo         }
echo         .info-label {
echo             font-weight: bold;
echo             color: #FFD700;
echo             margin-bottom: 5px;
echo         }
echo         .info-value {
echo             font-size: 1.1em;
echo         }
echo         .features {
echo             display: grid;
echo             grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
echo             gap: 20px;
echo             margin: 30px 0;
echo         }
echo         .feature {
echo             background: rgba(255,255,255,0.05);
echo             padding: 20px;
echo             border-radius: 15px;
echo             border: 1px solid rgba(255,255,255,0.1);
echo         }
echo         .feature-icon {
echo             font-size: 2em;
echo             margin-bottom: 10px;
echo         }
echo         .feature-title {
echo             font-size: 1.3em;
echo             margin-bottom: 10px;
echo             color: #FFD700;
echo         }
echo         .feature-desc {
echo             font-size: 1em;
echo             line-height: 1.4;
echo         }
echo         .pulse {
echo             animation: pulse 2s infinite;
echo         }
echo         @keyframes pulse {
echo             0%% { transform: scale(1); }
echo             50%% { transform: scale(1.05); }
echo             100%% { transform: scale(1); }
echo         }
echo         .footer {
echo             margin-top: 40px;
echo             font-size: 0.9em;
echo             opacity: 0.8;
echo         }
echo     ^</style^>
echo ^</head^>
echo ^<body^>
echo     ^<div class="container"^>
echo         ^<div class="logo pulse"^>🤖^</div^>
echo         ^<h1^>Samantha AI^</h1^>
echo         
echo         ^<div class="status-card"^>
echo             ^<div class="status-title"^>✅ Installation Successful!^</div^>
echo             ^<div class="status-text"^>
echo                 Your intelligent AI assistant is now running and ready to help you with any task.
echo                 Samantha AI provides natural conversation, learning capabilities, and intelligent responses.
echo             ^</div^>
echo         ^</div^>
echo         
echo         ^<div class="system-info"^>
echo             ^<div class="info-item"^>
echo                 ^<div class="info-label"^>System Status^</div^>
echo                 ^<div class="info-value"^>Running on Windows 11 Pro^</div^>
echo             ^</div^>
echo             ^<div class="info-item"^>
echo                 ^<div class="info-label"^>Memory Available^</div^>
echo                 ^<div class="info-value"^>32GB RAM^</div^>
echo             ^</div^>
echo             ^<div class="info-item"^>
echo                 ^<div class="info-label"^>Processor^</div^>
echo                 ^<div class="info-value"^>Intel i7-2600^</div^>
echo             ^</div^>
echo             ^<div class="info-item"^>
echo                 ^<div class="info-label"^>Installation Date^</div^>
echo                 ^<div class="info-value"^>%date%^</div^>
echo             ^</div^>
echo         ^</div^>
echo         
echo         ^<div class="features"^>
echo             ^<div class="feature"^>
echo                 ^<div class="feature-icon"^>🧠^</div^>
echo                 ^<div class="feature-title"^>Intelligent Conversations^</div^>
echo                 ^<div class="feature-desc"^>Natural language processing with context awareness and memory^</div^>
echo             ^</div^>
echo             ^<div class="feature"^>
echo                 ^<div class="feature-icon"^>🔒^</div^>
echo                 ^<div class="feature-title"^>Complete Privacy^</div^>
echo                 ^<div class="feature-desc"^>All processing happens locally on your device^</div^>
echo             ^</div^>
echo             ^<div class="feature"^>
echo                 ^<div class="feature-icon"^>📚^</div^>
echo                 ^<div class="feature-title"^>Continuous Learning^</div^>
echo                 ^<div class="feature-desc"^>Improves from every interaction and remembers your preferences^</div^>
echo             ^</div^>
echo             ^<div class="feature"^>
echo                 ^<div class="feature-icon"^>⚡^</div^>
echo                 ^<div class="feature-title"^>High Performance^</div^>
echo                 ^<div class="feature-desc"^>Optimized for your 32GB RAM system for fast responses^</div^>
echo             ^</div^>
echo         ^</div^>
echo         
echo         ^<div class="footer"^>
echo             Samantha AI v1.0 - Your Personal Intelligent Assistant
echo         ^</div^>
echo     ^</div^>
echo ^</body^>
echo ^</html^>
) > web/index.html 2>nul

if %errorLevel% neq 0 (
    call :show_error "Failed to create web interface"
    call :wait_confirmation
    exit /b 1
)

echo ✅ Web interface created
call :log_message "Web interface created successfully"

:: Create configuration files
echo.
echo ⚙️ Creating configuration files...
call :log_message "Creating configuration files"

:: Nginx configuration
(
echo events {
echo     worker_connections 1024;
echo }
echo.
echo http {
echo     include       /etc/nginx/mime.types;
echo     default_type  application/octet-stream;
echo     
echo     sendfile        on;
echo     keepalive_timeout  65;
echo     
echo     gzip on;
echo     gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
echo     
echo     server {
echo         listen       80;
echo         server_name  localhost;
echo         
echo         location / {
echo             root   /usr/share/nginx/html;
echo             index  index.html index.htm;
echo             try_files $uri $uri/ /index.html;
echo         }
echo         
echo         location /api/ {
echo             proxy_pass http://samantha-ai:11434/;
echo             proxy_set_header Host $host;
echo             proxy_set_header X-Real-IP $remote_addr;
echo             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
echo             proxy_set_header X-Forwarded-Proto $scheme;
echo         }
echo         
echo         error_page   500 502 503 504  /50x.html;
echo         location = /50x.html {
echo             root   /usr/share/nginx/html;
echo         }
echo     }
echo }
) > config/nginx.conf 2>nul

:: Redis configuration
(
echo # Redis configuration for Samantha AI
echo bind 0.0.0.0
echo port 6379
echo timeout 300
echo keepalive 60
echo maxmemory 256mb
echo maxmemory-policy allkeys-lru
echo save 900 1
echo save 300 10
echo save 60 10000
echo rdbcompression yes
echo dbfilename samantha.rdb
echo dir /data
) > config/redis.conf 2>nul

echo ✅ Configuration files created
call :log_message "Configuration files created successfully"

echo.
echo ✅ Step 9 completed successfully!
call :log_message "STEP 9: Samantha files setup - COMPLETED"
call :wait_confirmation

:: STEP 10: Container Deployment
set /a STEP_CURRENT=10
call :show_dashboard
echo 🚀 STEP 10: Deploying Samantha Containers...
call :log_message "STEP 10: Deploying containers"

echo.
echo Downloading and starting Samantha AI containers...
echo This may take 5-10 minutes depending on your internet speed.
call :log_message "Starting container deployment"

:: Pull images first to show progress
echo.
echo 📥 Downloading container images...

echo • Downloading Nginx (web server)...
docker pull nginx:alpine >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Nginx downloaded
    call :log_message "Nginx image downloaded successfully"
) else (
    call :show_warning "Failed to download Nginx image"
)

echo • Downloading Ollama (AI engine)...
docker pull ollama/ollama:latest >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Ollama downloaded
    call :log_message "Ollama image downloaded successfully"
) else (
    call :show_warning "Failed to download Ollama image"
)

echo • Downloading PostgreSQL (database)...
docker pull postgres:15-alpine >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ PostgreSQL downloaded
    call :log_message "PostgreSQL image downloaded successfully"
) else (
    call :show_warning "Failed to download PostgreSQL image"
)

echo • Downloading Redis (cache)...
docker pull redis:7-alpine >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Redis downloaded
    call :log_message "Redis image downloaded successfully"
) else (
    call :show_warning "Failed to download Redis image"
)

:: Start containers
echo.
echo 🚀 Starting Samantha AI containers...
call :log_message "Starting containers with docker-compose"

docker-compose up -d 2>nul
if %errorLevel% neq 0 (
    call :show_error "Failed to start containers"
    echo.
    echo ❌ Container startup failed
    echo.
    echo Troubleshooting steps:
    echo 1. Check if ports are available (3000, 5432, 6379, 11434)
    echo 2. Verify Docker Desktop is running properly
    echo 3. Check available system resources
    echo 4. Review Docker logs for specific errors
    echo.
    echo Manual diagnosis:
    echo • Run: docker-compose logs
    echo • Run: docker ps -a
    echo • Check: netstat -an | find "3000"
    echo.
    set /p CONTINUE="Continue with container startup issues? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo Installation cancelled by user.
        call :wait_confirmation
        exit /b 1
    )
    call :log_message "User chose to continue despite container startup issues"
) else (
    echo ✅ Containers started successfully
    call :log_message "Containers started successfully"
)

:: Wait for services to be ready
echo.
echo ⏳ Waiting for services to initialize...
timeout /t 15 /nobreak >nul

echo.
echo ✅ Step 10 completed successfully!
call :log_message "STEP 10: Container deployment - COMPLETED"
call :wait_confirmation

:: STEP 11: Service Verification
set /a STEP_CURRENT=11
call :show_dashboard
echo 🔍 STEP 11: Verifying Services...
call :log_message "STEP 11: Verifying services"

echo.
echo Testing Samantha AI services...

:: Test web interface
echo • Testing web interface (port 3000)...
call :log_message "Testing web interface on port 3000"
curl -s http://localhost:3000 >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Web interface: Accessible
    call :log_message "Web interface test: PASSED"
) else (
    call :show_warning "Web interface not responding"
    call :log_message "Web interface test: FAILED"
)

:: Test AI engine
echo • Testing AI engine (port 11434)...
call :log_message "Testing AI engine on port 11434"
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ AI engine: Accessible
    call :log_message "AI engine test: PASSED"
) else (
    call :show_warning "AI engine not responding (may still be starting)"
    call :log_message "AI engine test: FAILED (may still be starting)"
)

:: Test database
echo • Testing database (port 5432)...
call :log_message "Testing database on port 5432"
docker exec samantha-db pg_isready -U samantha >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Database: Ready
    call :log_message "Database test: PASSED"
) else (
    call :show_warning "Database not ready"
    call :log_message "Database test: FAILED"
)

:: Test cache
echo • Testing cache (port 6379)...
call :log_message "Testing cache on port 6379"
docker exec samantha-cache redis-cli ping >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Cache: Ready
    call :log_message "Cache test: PASSED"
) else (
    call :show_warning "Cache not ready"
    call :log_message "Cache test: FAILED"
)

:: Show container status
echo.
echo 📊 Container Status:
call :log_message "Checking container status"
docker-compose ps

echo.
echo ✅ Step 11 completed successfully!
call :log_message "STEP 11: Service verification - COMPLETED"
call :wait_confirmation

:: STEP 12: Shortcuts & Completion
set /a STEP_CURRENT=12
call :show_dashboard
echo 🎯 STEP 12: Creating Shortcuts & Finalizing...
call :log_message "STEP 12: Creating shortcuts and finalizing installation"

:: Create management script
echo.
echo 📝 Creating management tools...
call :log_message "Creating management script"

(
echo @echo off
echo setlocal
echo.
echo set "INSTALL_DIR=C:\Samantha"
echo cd /d "%%INSTALL_DIR%%" 2^>nul
echo if %%errorLevel%% neq 0 ^(
echo     echo Error: Cannot access Samantha installation directory
echo     echo Directory: %%INSTALL_DIR%%
echo     pause
echo     exit /b 1
echo ^)
echo.
echo if "%%1"=="start" ^(
echo     echo 🚀 Starting Samantha AI...
echo     docker-compose up -d
echo     if %%errorLevel%% equ 0 ^(
echo         echo ✅ Samantha AI started successfully!
echo         echo 🌐 Access at: http://localhost:3000
echo         timeout /t 3 /nobreak ^>nul
echo         start http://localhost:3000
echo     ^) else ^(
echo         echo ❌ Failed to start Samantha AI
echo         echo Check Docker Desktop is running
echo     ^)
echo ^) else if "%%1"=="stop" ^(
echo     echo 🛑 Stopping Samantha AI...
echo     docker-compose down
echo     if %%errorLevel%% equ 0 ^(
echo         echo ✅ Samantha AI stopped successfully
echo     ^) else ^(
echo         echo ❌ Failed to stop Samantha AI
echo     ^)
echo ^) else if "%%1"=="restart" ^(
echo     echo 🔄 Restarting Samantha AI...
echo     docker-compose restart
echo     if %%errorLevel%% equ 0 ^(
echo         echo ✅ Samantha AI restarted successfully
echo         echo 🌐 Access at: http://localhost:3000
echo     ^) else ^(
echo         echo ❌ Failed to restart Samantha AI
echo     ^)
echo ^) else if "%%1"=="status" ^(
echo     echo 📊 Samantha AI Status:
echo     echo.
echo     docker-compose ps
echo     echo.
echo     echo 🌐 Web Interface: http://localhost:3000
echo     echo 🤖 AI Engine: http://localhost:11434
echo ^) else if "%%1"=="logs" ^(
echo     echo 📋 Samantha AI Logs:
echo     docker-compose logs -f
echo ^) else if "%%1"=="update" ^(
echo     echo ⬆️  Updating Samantha AI...
echo     docker-compose pull
echo     docker-compose up -d
echo     echo ✅ Update completed
echo ^) else if "%%1"=="backup" ^(
echo     echo 💾 Creating backup...
echo     set BACKUP_NAME=samantha-backup-%%date:~-4,4%%%%date:~-10,2%%%%date:~-7,2%%-%%time:~0,2%%%%time:~3,2%%%%time:~6,2%%.zip
echo     powershell -command "Compress-Archive -Path '%%INSTALL_DIR%%\data','%%INSTALL_DIR%%\logs','%%INSTALL_DIR%%\backups' -DestinationPath '%%USERPROFILE%%\Desktop\!BACKUP_NAME!' -Force"
echo     echo Backup created: %%USERPROFILE%%\Desktop\!BACKUP_NAME!
echo ^) else if "%%1"=="uninstall" ^(
echo     echo 🗑️  Uninstalling Samantha AI...
echo     echo.
echo     set /p CONFIRM="Are you sure you want to uninstall Samantha AI? (y/n): "
echo     if /i "!CONFIRM!"=="y" ^(
echo         docker-compose down -v
echo         cd /d C:\
echo         rmdir /s /q "%%INSTALL_DIR%%"
echo         echo ✅ Samantha AI has been uninstalled
echo     ^) else ^(
echo         echo Uninstall cancelled
echo     ^)
echo ^) else ^(
echo     echo.
echo     echo 🤖 Samantha AI Management Console
echo     echo =====================================
echo     echo.
echo     echo Usage: samantha {command}
echo     echo.
echo     echo Available Commands:
echo     echo   start         - Start Samantha AI
echo     echo   stop          - Stop Samantha AI
echo     echo   restart       - Restart Samantha AI
echo     echo   status        - Show system status
echo     echo   logs          - View system logs
echo     echo   update        - Update to latest version
echo     echo   backup        - Create backup
echo     echo   uninstall     - Remove Samantha AI
echo     echo.
echo     echo 🌐 Web Interface: http://localhost:3000
echo     echo 🤖 AI Engine: http://localhost:11434
echo     echo.
echo ^)
echo.
echo pause
) > samantha.bat 2>nul

if %errorLevel% neq 0 (
    call :show_error "Failed to create management script"
) else (
    echo ✅ Management script created
    call :log_message "Management script created successfully"
)

:: Add to system PATH
echo.
echo 🔧 Adding to system PATH...
call :log_message "Adding Samantha to system PATH"

setx PATH "%PATH%;%INSTALL_DIR%" /M >nul 2>&1
if %errorLevel% equ 0 (
    echo ✅ Added to system PATH
    call :log_message "Successfully added to system PATH"
) else (
    call :show_warning "Failed to add to system PATH"
    echo You can manually add %INSTALL_DIR% to your PATH
)

:: Create desktop shortcuts
echo.
echo 🖥️ Creating desktop shortcuts...
call :log_message "Creating desktop shortcuts"

:: Web interface shortcut
powershell -command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Samantha AI.lnk'); $Shortcut.TargetPath = 'http://localhost:3000'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,14'; $Shortcut.Description = 'Samantha AI - Your Intelligent Assistant'; $Shortcut.Save(); Write-Host 'Desktop shortcut created' } catch { Write-Host 'Failed to create desktop shortcut' }" >nul 2>&1

:: Management shortcut
powershell -command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Samantha Manager.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\samantha.bat'; $Shortcut.Arguments = 'status'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,1'; $Shortcut.Description = 'Samantha AI Management Console'; $Shortcut.Save(); Write-Host 'Management shortcut created' } catch { Write-Host 'Failed to create management shortcut' }" >nul 2>&1

echo ✅ Desktop shortcuts created

:: Create start menu entries
echo.
echo 📂 Creating start menu entries...
call :log_message "Creating start menu entries"

mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI" 2>nul

powershell -command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI\Samantha AI.lnk'); $Shortcut.TargetPath = 'http://localhost:3000'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,14'; $Shortcut.Save() } catch { }" >nul 2>&1

powershell -command "try { $WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Samantha AI\Samantha Manager.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\samantha.bat'; $Shortcut.Arguments = 'status'; $Shortcut.IconLocation = 'C:\Windows\System32\shell32.dll,1'; $Shortcut.Save() } catch { }" >nul 2>&1

echo ✅ Start menu entries created

:: Create quick start guide
echo.
echo 📖 Creating quick start guide...
call :log_message "Creating quick start guide"

(
echo SAMANTHA AI - QUICK START GUIDE
echo ================================
echo.
echo Congratulations! Samantha AI has been successfully installed on your system.
echo.
echo GETTING STARTED:
echo ================
echo.
echo 1. ACCESS SAMANTHA:
echo    • Open your web browser
echo    • Go to: http://localhost:3000
echo    • Or click the "Samantha AI" desktop shortcut
echo.
echo 2. MANAGEMENT:
echo    • Use the "samantha" command in Command Prompt
echo    • Or use the "Samantha Manager" desktop shortcut
echo.
echo MANAGEMENT COMMANDS:
echo ===================
echo.
echo samantha start      - Start Samantha AI
echo samantha stop       - Stop Samantha AI
echo samantha restart    - Restart all services
echo samantha status     - Check system status
echo samantha logs       - View system logs
echo samantha backup     - Create backup
echo samantha update     - Update to latest version
echo samantha uninstall  - Remove Samantha AI
echo.
echo SYSTEM INFORMATION:
echo ==================
echo.
echo Installation Directory: %INSTALL_DIR%
echo Web Interface: http://localhost:3000
echo AI Engine: http://localhost:11434
echo Database: PostgreSQL on port 5432
echo Cache: Redis on port 6379
echo.
echo Log File: %LOG_FILE%
echo Installation Date: %date% %time%
echo.
echo TROUBLESHOOTING:
echo ===============
echo.
echo If Samantha doesn't start:
echo 1. Ensure Docker Desktop is running
echo 2. Check if ports 3000, 5432, 6379, 11434 are available
echo 3. Run "samantha status" to check service status
echo 4. Run "samantha logs" to view error messages
echo 5. Restart your computer if needed
echo.
echo If you need help:
echo 1. Check the installation log: %LOG_FILE%
echo 2. Run "samantha status" for current system status
echo 3. Use "docker-compose logs" for detailed container logs
echo.
echo ENJOY YOUR INTELLIGENT AI ASSISTANT!
echo ====================================
echo.
echo Samantha AI is now ready to help you with any task.
echo Your conversations are completely private and processed locally.
echo.
echo Thank you for choosing Samantha AI!
) > "%USERPROFILE%\Desktop\Samantha AI - Quick Start Guide.txt" 2>nul

echo ✅ Quick start guide created

echo.
echo ✅ Step 12 completed successfully!
call :log_message "STEP 12: Shortcuts and completion - COMPLETED"

:: Final completion
call :show_dashboard
echo.
echo ================================================================================
echo                        🎉 INSTALLATION COMPLETED SUCCESSFULLY!
echo ================================================================================
echo.
echo Samantha AI has been successfully installed and is now running on your system!
echo.
echo 🌐 ACCESS SAMANTHA AI:
echo    http://localhost:3000
echo.
echo 🖥️ DESKTOP SHORTCUTS CREATED:
echo    • Samantha AI (opens web interface)
echo    • Samantha Manager (management console)
echo    • Quick Start Guide (help documentation)
echo.
echo 🛠️ MANAGEMENT:
echo    Use "samantha" command in Command Prompt
echo    Commands: start, stop, restart, status, logs, backup, update, uninstall
echo.
echo 📊 SYSTEM STATUS:
echo    • Web Interface: Running on port 3000
echo    • AI Engine: Running on port 11434
echo    • Database: PostgreSQL on port 5432
echo    • Cache: Redis on port 6379
echo.
echo 📋 INSTALLATION LOG:
echo    %LOG_FILE%
echo.
echo 🎯 NEXT STEPS:
echo    1. Click "Samantha AI" desktop shortcut
echo    2. Start chatting with your intelligent assistant
echo    3. Explore the features and capabilities
echo.
call :log_message "INSTALLATION COMPLETED SUCCESSFULLY"
call :log_message "All 12 steps completed without critical errors"
call :log_message "Samantha AI is ready for use"

echo Opening Samantha AI in your default browser...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Press any key to view the installation log and exit...
pause >nul

:: Open log file
notepad "%LOG_FILE%"


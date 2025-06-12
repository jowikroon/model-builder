# Samantha AI Windows Installer - Installation Guide

## What You Get

Two Windows installer options have been created:

### 1. SamanthaAI-Installer.exe (Basic - 143 KB)
- Installs the installer framework
- Requires manual completion of Docker/WSL2 setup
- Smaller download size

### 2. SamanthaAI-Complete-Installer.exe (Complete - 177 KB) ⭐ **RECOMMENDED**
- Includes the complete Samantha AI system
- Automated Docker Desktop and WSL2 installation
- One-click setup experience

## Installation Instructions

### For Windows 10/11 Users:

1. **Download** the installer:
   - Choose `SamanthaAI-Complete-Installer.exe` for best experience

2. **Run as Administrator**:
   - Right-click the installer
   - Select "Run as administrator"
   - This is required for Docker and WSL2 installation

3. **Follow the Wizard**:
   - Accept the license agreement
   - Choose installation directory (default: C:\Samantha)
   - Select components to install
   - Click Install

4. **Complete Setup**:
   - The installer will automatically:
     - Install Docker Desktop (if not present)
     - Install WSL2 (if not present)
     - Download AI models (Dolphin, LLaMA, Mistral)
     - Start Samantha AI services

5. **First Launch**:
   - Open your web browser
   - Go to: http://localhost:3000
   - Start chatting with Samantha!

## System Requirements

- **OS**: Windows 10 (version 2004+) or Windows 11
- **Architecture**: 64-bit (x64)
- **Memory**: 8GB+ RAM (recommended)
- **Storage**: 20GB+ free disk space
- **Internet**: Required for initial setup and model downloads

## What Gets Installed

### Automatic Dependencies:
- Docker Desktop (if not present)
- WSL2 (Windows Subsystem for Linux 2)
- Required Windows features

### Samantha AI Components:
- Ollama (Local AI model server)
- PostgreSQL (Learning and memory database)
- Redis (Session management)
- Samantha Backend (AI logic and API)
- Samantha Frontend (Web interface)

### AI Models:
- Dolphin LLaMA 3 (8B parameters)
- LLaMA 3.1 (8B parameters)
- Mistral (7B parameters)

## Management Commands

After installation, use these commands in Command Prompt:

```cmd
samantha start      # Start Samantha AI
samantha stop       # Stop Samantha AI
samantha restart    # Restart all services
samantha status     # Check service status
samantha logs       # View system logs
samantha models     # List available AI models
samantha backup     # Create backup
samantha update     # Update to latest version
```

## Shortcuts Created

### Desktop:
- **Samantha AI** - Opens web interface

### Start Menu (Samantha AI folder):
- **Samantha AI** - Opens web interface
- **Samantha Manager** - Shows system status
- **Quick Start Guide** - Installation and usage tips
- **README** - Complete documentation
- **Uninstall** - Remove Samantha AI

## Troubleshooting

### Installation Issues:
- **"Must run as administrator"**: Right-click installer, select "Run as administrator"
- **"Insufficient disk space"**: Free up at least 20GB on C: drive
- **"Windows version not supported"**: Upgrade to Windows 10 version 2004 or later

### Runtime Issues:
- **Samantha won't start**: Restart computer, ensure Docker Desktop is running
- **Web interface not loading**: Wait 2-3 minutes after startup, check `samantha status`
- **AI not responding**: Models may still be downloading, check `samantha logs`

### Performance Issues:
- **Slow responses**: Ensure 8GB+ RAM available, close unnecessary applications
- **High CPU usage**: Normal during first-time model loading

## Uninstallation

To completely remove Samantha AI:

1. **Use Windows Settings**:
   - Go to Settings > Apps
   - Find "Samantha AI"
   - Click Uninstall

2. **Or use Start Menu**:
   - Go to Start Menu > Samantha AI
   - Click "Uninstall"

3. **Manual cleanup** (if needed):
   - Delete C:\Samantha folder
   - Remove Docker containers: `docker system prune -a`

## Privacy & Security

- **100% Local Processing**: All AI runs on your device
- **No Data Collection**: Your conversations stay private
- **Isolated Environment**: Docker containers provide security
- **No Internet Required**: After initial setup, works offline

## Support

- **Documentation**: See README.txt in installation folder
- **Quick Start**: See Quick-Start.txt for common tasks
- **Logs**: Use `samantha logs` command for troubleshooting

---

**Enjoy your intelligent AI assistant! 🤖✨**


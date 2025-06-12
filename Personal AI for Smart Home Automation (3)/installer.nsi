; Samantha AI - Windows Installer Script
; NSIS (Nullsoft Scriptable Install System) script
; Creates a professional Windows installer

!define APP_NAME "Samantha AI"
!define APP_VERSION "1.0.0"
!define APP_PUBLISHER "Samantha AI Team"
!define APP_URL "https://samantha-ai.local"
!define APP_DESCRIPTION "Advanced Personal AI Assistant"

; Installer settings
Name "${APP_NAME}"
OutFile "SamanthaAI-Setup.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; Modern UI
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "WinVer.nsh"

; Interface settings
!define MUI_ABORTWARNING
!define MUI_ICON "samantha.ico"
!define MUI_UNICON "samantha.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "wizard.bmp"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\samantha.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch Samantha AI"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
!insertmacro MUI_LANGUAGE "English"

; Version information
VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "ProductVersion" "${APP_VERSION}"
VIAddVersionKey "CompanyName" "${APP_PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_DESCRIPTION}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"

; Installer sections
Section "Samantha AI Core" SecCore
    SectionIn RO ; Read-only section
    
    SetOutPath "$INSTDIR"
    
    ; Check Windows version
    ${IfNot} ${AtLeastWin10}
        MessageBox MB_ICONSTOP "Windows 10 or later is required!"
        Abort
    ${EndIf}
    
    ; Check if running as admin
    UserInfo::GetAccountType
    Pop $0
    ${If} $0 != "admin"
        MessageBox MB_ICONSTOP "Administrator privileges required!"
        Abort
    ${EndIf}
    
    DetailPrint "Installing Samantha AI Core..."
    
    ; Copy main files
    File "samantha.exe"
    File "samantha.bat"
    File "docker-compose.yml"
    File "samantha.ico"
    File "README.txt"
    
    ; Create data directories
    CreateDirectory "$INSTDIR\data"
    CreateDirectory "$INSTDIR\logs"
    CreateDirectory "$INSTDIR\config"
    
    ; Install WSL2 if needed
    DetailPrint "Checking WSL2..."
    nsExec::ExecToStack 'wsl --status'
    Pop $0
    ${If} $0 != 0
        DetailPrint "Installing WSL2..."
        nsExec::ExecToLog 'dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart'
        nsExec::ExecToLog 'dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart'
        
        ; Download WSL2 kernel update
        inetc::get "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" "$TEMP\wsl_update_x64.msi"
        ExecWait 'msiexec /i "$TEMP\wsl_update_x64.msi" /quiet'
        
        nsExec::ExecToLog 'wsl --set-default-version 2'
        nsExec::ExecToLog 'wsl --install -d Ubuntu-22.04 --no-launch'
    ${EndIf}
    
    ; Install Docker Desktop if needed
    DetailPrint "Checking Docker Desktop..."
    IfFileExists "C:\Program Files\Docker\Docker\Docker Desktop.exe" docker_exists docker_install
    
    docker_install:
        DetailPrint "Installing Docker Desktop..."
        inetc::get "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" "$TEMP\DockerDesktopInstaller.exe"
        ExecWait '"$TEMP\DockerDesktopInstaller.exe" install --quiet --accept-license'
        Sleep 30000 ; Wait 30 seconds for installation
        
    docker_exists:
        DetailPrint "Starting Docker Desktop..."
        Exec '"C:\Program Files\Docker\Docker\Docker Desktop.exe"'
        Sleep 60000 ; Wait 60 seconds for Docker to start
    
    ; Download Samantha containers
    DetailPrint "Downloading Samantha AI containers..."
    SetOutPath "$INSTDIR"
    nsExec::ExecToLog 'docker-compose pull'
    
    ; Start Samantha
    DetailPrint "Starting Samantha AI..."
    nsExec::ExecToLog 'docker-compose up -d'
    
    ; Install default AI model
    DetailPrint "Installing default AI model..."
    Sleep 30000 ; Wait for containers to start
    nsExec::ExecToLog 'docker exec samantha-ollama ollama pull dolphin-llama3:8b'
    
    ; Write registry keys
    WriteRegStr HKLM "Software\${APP_NAME}" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "Software\${APP_NAME}" "Version" "${APP_VERSION}"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Add to Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\samantha.ico"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${APP_PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
    
SectionEnd

Section "Desktop Shortcut" SecDesktop
    CreateShortCut "$DESKTOP\Samantha AI.lnk" "$INSTDIR\samantha.exe" "" "$INSTDIR\samantha.ico"
SectionEnd

Section "Start Menu Shortcuts" SecStartMenu
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Samantha AI.lnk" "$INSTDIR\samantha.exe" "" "$INSTDIR\samantha.ico"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Add to PATH" SecPath
    ; Add installation directory to system PATH
    EnVar::SetHKLM
    EnVar::AddValue "PATH" "$INSTDIR"
SectionEnd

; Component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Core Samantha AI files and Docker containers"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Create a desktop shortcut"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} "Create Start Menu shortcuts"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPath} "Add Samantha to system PATH"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller
Section "Uninstall"
    ; Stop Samantha
    SetOutPath "$INSTDIR"
    nsExec::ExecToLog 'docker-compose down -v'
    
    ; Remove files
    Delete "$INSTDIR\samantha.exe"
    Delete "$INSTDIR\samantha.bat"
    Delete "$INSTDIR\docker-compose.yml"
    Delete "$INSTDIR\samantha.ico"
    Delete "$INSTDIR\README.txt"
    Delete "$INSTDIR\Uninstall.exe"
    
    ; Remove directories
    RMDir /r "$INSTDIR\data"
    RMDir /r "$INSTDIR\logs"
    RMDir /r "$INSTDIR\config"
    RMDir "$INSTDIR"
    
    ; Remove shortcuts
    Delete "$DESKTOP\Samantha AI.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Samantha AI.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    
    ; Remove from PATH
    EnVar::SetHKLM
    EnVar::DeleteValue "PATH" "$INSTDIR"
    
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${APP_NAME}"
    
SectionEnd


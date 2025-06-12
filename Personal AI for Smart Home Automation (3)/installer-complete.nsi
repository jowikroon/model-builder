; Complete Samantha AI Windows Installer
; Includes the full Samantha system with all components

!define PRODUCT_NAME "Samantha AI"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "Samantha AI Team"

; Modern UI
!include "MUI2.nsh"

; General
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "SamanthaAI-Complete-Installer.exe"
InstallDir "C:\Samantha"
ShowInstDetails show
RequestExecutionLevel admin

; Interface Settings
!define MUI_ABORTWARNING

; Welcome page
!define MUI_WELCOMEPAGE_TITLE "Welcome to Samantha AI Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will install Samantha AI - your intelligent local assistant.$\r$\n$\r$\nSamantha AI includes:$\r$\n• Local AI models (Dolphin, LLaMA, Mistral)$\r$\n• Complete privacy and security$\r$\n• Natural conversation capabilities$\r$\n• Learning and memory system$\r$\n$\r$\nClick Next to continue."
!insertmacro MUI_PAGE_WELCOME

; License page
!insertmacro MUI_PAGE_LICENSE "license.txt"

; Components page
!insertmacro MUI_PAGE_COMPONENTS

; Directory page
!insertmacro MUI_PAGE_DIRECTORY

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\install.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Complete Samantha AI Installation"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!insertmacro MUI_PAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English"

; Installation Sections
Section "Samantha AI Core" SecCore
  SectionIn RO
  SetOutPath "$INSTDIR"
  
  ; Copy main files
  File "docker-compose.yml"
  File "samantha.bat"
  File "README.txt"
  File "license.txt"
  File "install.bat"
  File "samantha-local-complete.tar.gz"
  
  ; Create directories
  CreateDirectory "$INSTDIR\logs"
  CreateDirectory "$INSTDIR\data"
  CreateDirectory "$INSTDIR\models"
  CreateDirectory "$INSTDIR\temp"
  
  ; Extract complete system
  DetailPrint "Extracting Samantha AI system..."
  nsExec::ExecToLog 'tar -xzf "$INSTDIR\samantha-local-complete.tar.gz" -C "$INSTDIR\temp"'
  
  ; Copy extracted files
  CopyFiles "$INSTDIR\temp\samantha-local\*" "$INSTDIR"
  
  ; Cleanup
  RMDir /r "$INSTDIR\temp"
  Delete "$INSTDIR\samantha-local-complete.tar.gz"
SectionEnd

Section "Desktop Shortcuts" SecShortcuts
  ; Desktop shortcut
  CreateShortCut "$DESKTOP\Samantha AI.lnk" "$INSTDIR\install.bat" "" "$INSTDIR\samantha.ico"
  
  ; Start menu shortcuts
  CreateDirectory "$SMPROGRAMS\Samantha AI"
  CreateShortCut "$SMPROGRAMS\Samantha AI\Install Samantha AI.lnk" "$INSTDIR\install.bat" "" "$INSTDIR\samantha.ico"
  CreateShortCut "$SMPROGRAMS\Samantha AI\Samantha Manager.lnk" "$INSTDIR\samantha.bat" "status" "$INSTDIR\samantha.ico"
  CreateShortCut "$SMPROGRAMS\Samantha AI\README.lnk" "$INSTDIR\README.txt"
SectionEnd

Section "Quick Start Guide" SecGuide
  ; Create quick start guide
  FileOpen $0 "$INSTDIR\Quick-Start.txt" w
  FileWrite $0 "Samantha AI - Quick Start Guide$\r$\n"
  FileWrite $0 "================================$\r$\n$\r$\n"
  FileWrite $0 "1. FIRST TIME SETUP:$\r$\n"
  FileWrite $0 "   - Double-click 'Install Samantha AI' on your desktop$\r$\n"
  FileWrite $0 "   - This will install Docker, WSL2, and start Samantha$\r$\n"
  FileWrite $0 "   - Installation takes 15-30 minutes (downloads AI models)$\r$\n$\r$\n"
  FileWrite $0 "2. DAILY USE:$\r$\n"
  FileWrite $0 "   - Open browser and go to: http://localhost:3000$\r$\n"
  FileWrite $0 "   - Start chatting with Samantha!$\r$\n$\r$\n"
  FileWrite $0 "3. MANAGEMENT:$\r$\n"
  FileWrite $0 "   - Use 'samantha start' to start$\r$\n"
  FileWrite $0 "   - Use 'samantha stop' to stop$\r$\n"
  FileWrite $0 "   - Use 'samantha status' to check status$\r$\n$\r$\n"
  FileWrite $0 "4. TROUBLESHOOTING:$\r$\n"
  FileWrite $0 "   - If Samantha won't start, restart your computer$\r$\n"
  FileWrite $0 "   - Check that Docker Desktop is running$\r$\n"
  FileWrite $0 "   - Run 'samantha logs' to see error messages$\r$\n$\r$\n"
  FileWrite $0 "Enjoy your intelligent AI assistant!$\r$\n"
  FileClose $0
  
  CreateShortCut "$SMPROGRAMS\Samantha AI\Quick Start Guide.lnk" "$INSTDIR\Quick-Start.txt"
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninstall.exe"
  CreateShortCut "$SMPROGRAMS\Samantha AI\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Installs Samantha AI core system with all AI models and components"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Creates desktop and start menu shortcuts for easy access"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGuide} "Installs quick start guide and troubleshooting tips"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller
Section "Uninstall"
  ; Stop Samantha if running
  nsExec::ExecToLog '"$INSTDIR\samantha.bat" stop'
  
  ; Remove Docker containers and volumes
  nsExec::ExecToLog 'docker-compose -f "$INSTDIR\docker-compose.yml" down -v'
  
  ; Remove files
  Delete "$INSTDIR\docker-compose.yml"
  Delete "$INSTDIR\samantha.bat"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\install.bat"
  Delete "$INSTDIR\Quick-Start.txt"
  Delete "$INSTDIR\uninstall.exe"
  
  ; Remove directories
  RMDir /r "$INSTDIR\logs"
  RMDir /r "$INSTDIR\data"
  RMDir /r "$INSTDIR\models"
  RMDir /r "$INSTDIR\backend"
  RMDir /r "$INSTDIR\frontend"
  RMDir "$INSTDIR"
  
  ; Remove shortcuts
  Delete "$DESKTOP\Samantha AI.lnk"
  RMDir /r "$SMPROGRAMS\Samantha AI"
SectionEnd


; Samantha AI - Fixed Installation Package
; Addresses all issues identified in Claude's review
; Uses the corrected installer script

!define PRODUCT_NAME "Samantha AI"
!define PRODUCT_VERSION "1.1"
!define PRODUCT_PUBLISHER "Samantha AI Team"
!define PRODUCT_WEB_SITE "https://samantha-ai.local"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\samantha.bat"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; Modern UI
!include "MUI2.nsh"

; General
Name "${PRODUCT_NAME}"
OutFile "SamanthaAI-Fixed-Installer.exe"
InstallDir "C:\Samantha"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

; Compression
SetCompressor /SOLID lzma

; Request admin privileges
RequestExecutionLevel admin

; Interface Settings
!define MUI_ABORTWARNING

; Welcome page
!define MUI_WELCOMEPAGE_TITLE "Welcome to Samantha AI Fixed Installation"
!define MUI_WELCOMEPAGE_TEXT "This installer will install Samantha AI on your computer.$\r$\n$\r$\nThis is a FIXED installation that addresses all coding issues:$\r$\n• No Unicode/emoji characters (ASCII only)$\r$\n• Improved file generation using PowerShell$\r$\n• Fixed shortcut creation$\r$\n• Better error handling$\r$\n$\r$\nPrerequisites:$\r$\n• Docker Desktop installed and running$\r$\n• Modern web browser$\r$\n$\r$\nClick Next to continue."
!insertmacro MUI_PAGE_WELCOME

; License page
!insertmacro MUI_PAGE_LICENSE "license.txt"

; Directory page
!insertmacro MUI_PAGE_DIRECTORY

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\install-fixed.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Complete Samantha AI Installation and Start Services"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Show README"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

Section "Core Files" SecCore
  SectionIn RO
  
  DetailPrint "Installing Samantha AI core files..."
  
  SetOutPath "$INSTDIR"
  
  ; Core installation files
  File "install-fixed.bat"
  File "samantha.bat"
  File "README.txt"
  File "license.txt"
  
  ; Create directories
  CreateDirectory "$INSTDIR\logs"
  CreateDirectory "$INSTDIR\data"
  CreateDirectory "$INSTDIR\config"
  CreateDirectory "$INSTDIR\backend"
  CreateDirectory "$INSTDIR\frontend"
  
  ; Registry entries
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\samantha.bat"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\samantha.bat"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Desktop Shortcuts" SecShortcuts
  DetailPrint "Creating shortcuts..."
  
  ; Desktop shortcut for web interface (fixed filename without spaces)
  CreateShortCut "$DESKTOP\SamanthaAI.lnk" "http://localhost:3000" "" "C:\Windows\System32\shell32.dll" 14
  
  ; Desktop shortcut for management (fixed filename without spaces)
  CreateShortCut "$DESKTOP\SamanthaManager.lnk" "$INSTDIR\samantha.bat" "status" "C:\Windows\System32\shell32.dll" 1
  
  ; Start menu shortcuts (fixed filenames)
  CreateDirectory "$SMPROGRAMS\Samantha AI"
  CreateShortCut "$SMPROGRAMS\Samantha AI\SamanthaAI.lnk" "http://localhost:3000" "" "C:\Windows\System32\shell32.dll" 14
  CreateShortCut "$SMPROGRAMS\Samantha AI\SamanthaManager.lnk" "$INSTDIR\samantha.bat" "status" "C:\Windows\System32\shell32.dll" 1
  CreateShortCut "$SMPROGRAMS\Samantha AI\Start-Samantha.lnk" "$INSTDIR\samantha.bat" "start" "C:\Windows\System32\shell32.dll" 1
  CreateShortCut "$SMPROGRAMS\Samantha AI\Stop-Samantha.lnk" "$INSTDIR\samantha.bat" "stop" "C:\Windows\System32\shell32.dll" 1
  CreateShortCut "$SMPROGRAMS\Samantha AI\README.lnk" "$INSTDIR\README.txt"
  CreateShortCut "$SMPROGRAMS\Samantha AI\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "Core Samantha AI files and configuration (fixed version)"
  !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Desktop and Start Menu shortcuts (fixed filenames)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section Uninstall
  DetailPrint "Stopping Samantha AI services..."
  
  ; Stop services before uninstalling
  ExecWait '"$INSTDIR\samantha.bat" stop' $0
  
  ; Remove registry keys
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  
  ; Remove files
  Delete "$INSTDIR\install-fixed.bat"
  Delete "$INSTDIR\samantha.bat"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\uninstall.exe"
  
  ; Remove directories (only if empty)
  RMDir "$INSTDIR\logs"
  RMDir "$INSTDIR\config"
  RMDir "$INSTDIR\backend"
  RMDir "$INSTDIR\frontend"
  
  ; Remove data directory (ask user)
  MessageBox MB_YESNO "Do you want to remove all Samantha AI data (conversations, settings)?" IDNO skip_data
  RMDir /r "$INSTDIR\data"
  skip_data:
  
  ; Remove shortcuts (fixed filenames)
  Delete "$DESKTOP\SamanthaAI.lnk"
  Delete "$DESKTOP\SamanthaManager.lnk"
  RMDir /r "$SMPROGRAMS\Samantha AI"
  
  ; Remove installation directory
  RMDir "$INSTDIR"
  
  SetAutoClose true
SectionEnd


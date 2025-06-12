; Samantha AI - Simple Installer (Krug-Inspired)
; ONE installer that just works - no choices, no thinking required
; Based on Steve Krug's "Don't Make Me Think" principles

!define PRODUCT_NAME "Samantha AI"
!define PRODUCT_VERSION "2.0"
!define PRODUCT_PUBLISHER "Samantha AI Team"
!define PRODUCT_WEB_SITE "https://samantha-ai.local"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\samantha.bat"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; Modern UI
!include "MUI2.nsh"

; General
Name "${PRODUCT_NAME}"
OutFile "SamanthaAI-Installer.exe"
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

; Simplified Welcome page (Krug principle: Self-explanatory)
!define MUI_WELCOMEPAGE_TITLE "Install Samantha AI"
!define MUI_WELCOMEPAGE_TEXT "This will install Samantha AI - your intelligent assistant.$\r$\n$\r$\nNo choices needed - everything is automatic!$\r$\n$\r$\nClick Next to install."
!insertmacro MUI_PAGE_WELCOME

; Skip license page (Krug principle: Minimize steps)
; Skip directory page (Krug principle: Mindless choices - use default)

; Instfiles page with clear progress
!insertmacro MUI_PAGE_INSTFILES

; Simplified finish page (Krug principle: Clear next action)
!define MUI_FINISHPAGE_RUN "$INSTDIR\install-simple.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Start Samantha AI now"
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; Single section (Krug principle: No choices)
Section "Samantha AI" SecMain
  SectionIn RO
  
  DetailPrint "Installing Samantha AI..."
  
  SetOutPath "$INSTDIR"
  
  ; Core files only
  File "install-simple.bat"
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
  
  ; Auto-create desktop shortcut (Krug principle: Mindless choices)
  CreateShortCut "$DESKTOP\SamanthaAI.lnk" "http://localhost:3000" "" "C:\Windows\System32\shell32.dll" 14
  
  ; Auto-create start menu entry
  CreateDirectory "$SMPROGRAMS\Samantha AI"
  CreateShortCut "$SMPROGRAMS\Samantha AI\Samantha AI.lnk" "http://localhost:3000" "" "C:\Windows\System32\shell32.dll" 14
  CreateShortCut "$SMPROGRAMS\Samantha AI\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  
SectionEnd

Section Uninstall
  DetailPrint "Removing Samantha AI..."
  
  ; Stop services before uninstalling
  ExecWait '"$INSTDIR\samantha.bat" stop' $0
  
  ; Remove registry keys
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  
  ; Remove files
  Delete "$INSTDIR\install-simple.bat"
  Delete "$INSTDIR\samantha.bat"
  Delete "$INSTDIR\README.txt"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\uninstall.exe"
  
  ; Remove directories (only if empty)
  RMDir "$INSTDIR\logs"
  RMDir "$INSTDIR\config"
  RMDir "$INSTDIR\backend"
  RMDir "$INSTDIR\frontend"
  
  ; Ask about data (Krug principle: Clear choices when necessary)
  MessageBox MB_YESNO "Remove all Samantha AI data and conversations?" IDNO skip_data
  RMDir /r "$INSTDIR\data"
  skip_data:
  
  ; Remove shortcuts
  Delete "$DESKTOP\SamanthaAI.lnk"
  RMDir /r "$SMPROGRAMS\Samantha AI"
  
  ; Remove installation directory
  RMDir "$INSTDIR"
  
  SetAutoClose true
SectionEnd


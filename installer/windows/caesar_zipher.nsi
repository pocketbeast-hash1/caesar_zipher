!include "MUI2.nsh"

!define MUI_ICON "icon.ico"

RequestExecutionLevel admin

Name "Caesar Zipher"
OutFile "caesar_zipher.exe"
InstallDir "$PROGRAMFILES64\caesar_zipher"
InstallDirRegKey HKCU "Software\caesar_zipher" ""

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Russian"

Section "Основная установка"
    SetOutPath "$INSTDIR"
    
    File /r "..\..\build\windows\x64\runner\Release\*.*"
    
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    CreateShortcut "$SMPROGRAMS\Caesar Zipher.lnk" "$INSTDIR\caesar_zipher.exe"
    CreateShortcut "$DESKTOP\Caesar Zipher.lnk" "$INSTDIR\caesar_zipher.exe"
    
    WriteRegStr HKCU "Software\CaesarZipher" "Install_Dir" "$INSTDIR"
    
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CaesarZipher" \
                     "DisplayName" "Caesar Zipher"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CaesarZipher" \
                     "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CaesarZipher" \
                     "DisplayIcon" "$INSTDIR\caesar_zipher.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CaesarZipher" \
                     "DisplayVersion" "1.3.1"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CaesarZipher" \
                     "Publisher" "PK Bejitsky"
SectionEnd

Section "Uninstall"
    RMDir /r "$INSTDIR"
    RMDir /r "$APPDATA\caesar_zipher"
    RMDir /r "$LOCALAPPDATA\caesar_zipher"
    
    Delete "$SMPROGRAMS\Caesar Zipher.lnk"
    Delete "$DESKTOP\Caesar Zipher.lnk"
    
    DeleteRegKey HKCU "Software\CaesarZipher"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CaesarZipher"
SectionEnd
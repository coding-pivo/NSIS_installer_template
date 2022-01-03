; This script can be successfully compiled with NSIS 3.08

;-------------------------------------------------------------------------------
; Includes
!include MUI2.nsh                                ; Add support for modern user interface
!include LogicLib.nsh                            ; Add support for easy logic flow control
!include StrFunc.nsh                             ; Add string functions e.g. to parse command line results
!include nsDialogs.nsh                           ; Add support for custom pages
;!include sections.nsh                            ; Add better section handling

;-------------------------------------------------------------------------------
; Constants
!define PRODUCT_NAME "Test Installer"
!define PRODUCT_DESCRIPTION "Just an installer"
!define COPYRIGHT "Copyright (c) 2022 Ivo Pischner"
!define PRODUCT_VERSION "1.0.0.0"                               ; Version of the installer content
!define SETUP_VERSION "0.1.0.0"                                 ; Version of the install script itself

;-------------------------------------------------------------------------------
; Attributes
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"        ; Name to be used for the GUI title
OutFile "Test_${PRODUCT_VERSION}.exe" ; Name of the installer executable
RequestExecutionLevel admin                      ; Request administrator rights to be able to write to registry
;RequestExecutionLevel user                       ; Request standard user rights; Just for debugging to be able to run the installer on Citrix Desktop
ManifestSupportedOS Win7                         ; Declare that the installer is compatible with Win 7 only
XPStyle on                                       ;
ShowInstDetails show                             ; Show installation details by default

;-------------------------------------------------------------------------------
; Version Info
VIProductVersion "${SETUP_VERSION}"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "FileDescription" "${PRODUCT_DESCRIPTION}"
VIAddVersionKey "LegalCopyright" "${COPYRIGHT}"
VIAddVersionKey "FileVersion" "${PRODUCT_VERSION}"

;-------------------------------------------------------------------------------
; Modern UI Appearance
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\orange.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange.bmp"
!define MUI_FINISHPAGE_NOAUTOCLOSE

;-------------------------------------------------------------------------------
; Finish page
!define MUI_FINISHPAGE_TEXT_REBOOT "The installation is not yet completed! Your computer must be restarted in order to make security changes to be effective. Please run the installer again after reboot. Do you want to reboot now?"
!define MUI_FINISHPAGE_TEXT_REBOOTNOW "Reboot now"
!define MUI_FINISHPAGE_TEXT_REBOOTLATER "I want to manually reboot later"

;-------------------------------------------------------------------------------
; Installer Pages
!insertmacro MUI_PAGE_WELCOME
;!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
!insertmacro MUI_PAGE_COMPONENTS
Page custom nsDialogsPage nsDialogsPageLeave
;!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;-------------------------------------------------------------------------------
; Languages
!insertmacro MUI_LANGUAGE "English"

;-------------------------------------------------------------------------------
; Init string functions
${StrLoc}

;-------------------------------------------------------------------------------
; Define global variables
Var Dialog
Var Label
Var Para1_DropList
Var Para2_DropList
Var Para3_DropList
Var Para1_Script
Var Para2_Script
Var Para3_Script

;-------------------------------------------------------------------------------
; Installer Sections
Section ""
  ; Create directories
  CreateDirectory C:\Temp
  
  ; Check if creation was successful
SectionEnd

Section "Disable UAC" SEC_UAC
  Var /GLOBAL ELUA_BEFORE
  Var /GLOBAL POSD_BEFORE
  Var /GLOBAL CPBA_BEFORE
  Var /GLOBAL ELUA_AFTER
  Var /GLOBAL POSD_AFTER
  Var /GLOBAL CPBA_AFTER
  Var /GLOBAL UAC_CHANGED
  
  ; Read UAC setting
  DetailPrint "Read current UAC registry settings"
  ReadRegDWORD $ELUA_BEFORE "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA"
  ReadRegDWORD $POSD_BEFORE "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop"
  ReadRegDWORD $CPBA_BEFORE "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin"
  
  DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [EnableLUA] = $ELUA_BEFORE"
  DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [PromptOnSecureDesktop] = $POSD_BEFORE"
  DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [ConsentPromptBehaviorAdmin] = $CPBA_BEFORE"
  
  ; Change UAC if needed
  StrCpy $UAC_CHANGED 0
  
  ${If} $ELUA_BEFORE != 0
    DetailPrint "Change HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [EnableLUA] to <0>"
    WriteRegDWORD "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 0
    ReadRegDWORD $ELUA_AFTER "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA"
    DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [EnableLUA] = $ELUA_AFTER"
    ; Check for success
    ${If} $ELUA_AFTER == 0
      DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [EnableLUA] successfully changed to <$ELUA_AFTER>"
      StrCpy $UAC_CHANGED 1
    ${Else}
      DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [EnableLUA] couldn't be changed to <0>"
      Abort
    ${EndIf}
  ${Else}
    DetailPrint "No change needed for HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [EnableLUA]"
  ${EndIf}
  
  ${If} $POSD_BEFORE != 0
    DetailPrint "Change HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [PromptOnSecureDesktop] to <0>"
    WriteRegDWORD "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" 0
    ReadRegDWORD $POSD_AFTER "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop"
    DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [PromptOnSecureDesktop] = $POSD_AFTER"
    ; Check for success
    ${If} $POSD_AFTER == 0
      DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [PromptOnSecureDesktop] successfully changed to <$POSD_AFTER>"
      StrCpy $UAC_CHANGED 1
    ${Else}
      DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [PromptOnSecureDesktop] couldn't be changed to <0>"
      Abort
    ${EndIf}
  ${Else}
    DetailPrint "No change needed for HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [PromptOnSecureDesktop]"
  ${EndIf}
  
  ${If} $CPBA_BEFORE != 0
    DetailPrint "Change HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [ConsentPromptBehaviorAdmin] to <0>"
    WriteRegDWORD "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 0
    ReadRegDWORD $CPBA_AFTER "HKLM" "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin"
    DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [ConsentPromptBehaviorAdmin] = $CPBA_AFTER"
    ; Check for success
    ${If} $CPBA_AFTER == 0
      DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [ConsentPromptBehaviorAdmin] successfully changed to <$CPBA_AFTER>"
      StrCpy $UAC_CHANGED 1
    ${Else}
      DetailPrint "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [ConsentPromptBehaviorAdmin] couldn't be changed to <0>"
      Abort
    ${EndIf}
  ${Else}
    DetailPrint "No change needed for HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System [ConsentPromptBehaviorAdmin]"
  ${EndIf}
  
  ; Trigger reboot if UAC was changed
  ${If} $UAC_CHANGED = 1
    DetailPrint "Trigger reboot"
    SetRebootFlag true
  ${EndIf}
SectionEnd

Section "Setup Windows Security" SEC_SECURITY
  Var /GLOBAL WIN_SEC_BEFORE
  Var /GLOBAL WIN_SEC_AFTER
  
  ; Read setting
  DetailPrint "Read current Windows security settings"
  ReadRegDWORD $WIN_SEC_BEFORE "HKCU" "SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" "1806"
  
  DetailPrint "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3 [1806] = $WIN_SEC_BEFORE"
  
  ${If} $WIN_SEC_BEFORE != 0
    ; If registry value is not existing or not 0 create the value and set to 0
    DetailPrint "Need to change Windows security settings"
    WriteRegDWORD "HKCU" "SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" "1806" 0
    ReadRegDWORD $WIN_SEC_AFTER "HKCU" "SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" "1806"
    ${If} $WIN_SEC_AFTER != 0
      ; Setting could not be changed - Raise an error
      DetailPrint "Windows security settings couldn't be changed"
      Abort
    ${Else}
      DetailPrint "Windows security settings successfully changed"
      SetRebootFlag true
    ${EndIf}
  ${Else}
    DetailPrint "Windows security settings already set properly"
  ${EndIf}
SectionEnd

Section "Set Power-Button" SEC_PWR_BTN
  Var /GLOBAL PWR_BTN_BEFORE
  Var /GLOBAL PWR_BTN_AFTER
  
  ; Read setting
  DetailPrint "Read current Power-Button default state"
  ReadRegDWORD $PWR_BTN_BEFORE "HKCU" "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_PowerButtonAction"
  
  DetailPrint "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced [Start_PowerButtonAction] = $PWR_BTN_BEFORE"
  
  ${If} $PWR_BTN_BEFORE != 4
    #;If registry value is not existing or not 0 create the value and set to 0
    DetailPrint "Need to change Power-Button default state"
    WriteRegDWORD "HKCU" "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_PowerButtonAction" 4
    ReadRegDWORD $PWR_BTN_AFTER "HKCU" "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_PowerButtonAction"
    ${If} $PWR_BTN_AFTER != 4
      ; Setting could not be changed
      DetailPrint "Power-Button default state couldn't be changed"
      Abort
    ${Else}
      DetailPrint "Power-Button default state successfully changed"
      SetRebootFlag true
    ${EndIf}
  ${Else}
    DetailPrint "Power-Button default state already set properly"
  ${EndIf}
SectionEnd

Section "Install Python" SEC_PYTHON
  ; Skip section if reboot is required due to windows security changes that need to take effect before this section can run
  IfRebootFlag Reboot
  
  ; Check if Python is already installed and skip installation in case it is
  nsExec::ExecToStack 'C:\Python27\python.exe --version'
  Pop $0
  Pop $1
  ${StrLoc} $2 $1 "Python 2.7.18" ">"
  ${If} $2 != ""
    DetailPrint "Python 2.7.18 already installed"
    Goto Reboot
  ${EndIf}
  
  CreateDirectory "C:\Temp"
  SetOutPath "C:\Temp"
  File python-2.7.18.amd64.msi
  nsExec::Exec 'msiexec /i C:\Temp\python-2.7.18.amd64.msi  /l*v C:\Temp\python_install.log /qn ALLUSERS=1 TARGETDIR=C:\Python27'
  Pop $0
  ${If} $0 != 0
    DetailPrint "Python installation failed"
    Abort
  ${EndIf}
  
  ; Check if install was successful
  nsExec::ExecToStack 'C:\Python27\python.exe --version'
  Pop $0
  Pop $1
  ${StrLoc} $2 $1 "Python 2.7.18" ">"
  ${If} $2 != ""
    DetailPrint "Python 2.7.18 installed successfully"
  ${Else}
    DetailPrint "Python 2.7.18 installation failed"
    Abort
  ${EndIf}
  
  Reboot:
SectionEnd

Section "Install pywin32" SEC_PYWIN32
  ; Skip section if reboot is required due to windows security changes that need to take effect before this section can run
  IfRebootFlag Reboot
  
  ; Check if pywin32 is already installed and skip installation in case it is
  nsExec::ExecToStack 'C:\Python27\python.exe -m pip freeze'
  Pop $0
  Pop $1
  ${StrLoc} $2 $1 "pywin32==228" ">"
  ${If} $2 != ""
    DetailPrint "Pywin32 package already installed"
	Goto Reboot
  ${EndIf}
  
  CreateDirectory "C:\Temp"
  SetOutPath "C:\Temp"
  File pywin32-228-cp27-cp27m-win_amd64.whl
  nsExec::Exec 'C:\Python27\Scripts\pip install C:\Temp\pywin32-228-cp27-cp27m-win_amd64.whl'
  Pop $0
  ${If} $0 != 0
    DetailPrint "Installation of pywin32 package failed"
    Abort
  ${EndIf}
  
  ; Check if install was successful
  nsExec::ExecToStack 'C:\Python27\python.exe -m pip freeze'
  Pop $0
  Pop $1
  ${StrLoc} $2 $1 "pywin32==228" ">"
  ${If} $2 != ""
    DetailPrint "Pywin32 package installed successfully"
  ${Else}
    DetailPrint "Installation of pywin32 package failed"
    Abort
  ${EndIf}
  
  Reboot:
SectionEnd

Section "-Update VB6 Runtime"
  ; Skip section if reboot is required due to windows security changes that need to take effect before this section can run
  IfRebootFlag Reboot
  
  Reboot:
SectionEnd

Section "Run Install Script" SEC_RUN_SCRIPT
  ; Skip section if reboot is required due to windows security changes that need to take effect before this section can run
  IfRebootFlag Reboot
  
  CreateDirectory "C:\Temp"
  SetOutPath "C:\Temp"
  File test.py
  nsExec::Exec 'py test.py $Para1_Script $Para2_Script $Para3_Script'
  
  Reboot:
SectionEnd

;-------------------------------------------------------------------------------
;Descriptions
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_UAC} "Disable UAC completely"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SECURITY} "Enable <Launching applications and unsafe files> for Security Settings in Internet Zone"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_PWR_BTN} "Set Power Button default action to <Restart>"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_PYTHON} "Install Python 2.7.18 (64Bit)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_PYWIN32} "Install python package pywin32-228"
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_RUN_SCRIPT} "Run Python script..."
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;-------------------------------------------------------------------------------
; Functions
Function nsDialogsPage
  nsDialogs::Create 1018
  Pop $Dialog

  ${If} $Dialog == error
    Abort
  ${EndIf}

  ${NSD_CreateLabel} 0 0 100% 12u "Please select script parameter..."
  Pop $Label

  ${NSD_CreateLabel} 0 24u 20% 12u "Parameter 1:"
  Pop $Label

  ${NSD_CreateLabel} 0 45u 20% 12u "Parameter 2:"
  Pop $Label

  ${NSD_CreateLabel} 0 65u 20% 12u "Parameter 3:"
  Pop $Label

  ${NSD_CreateDropList} 60u 20u 30% 12u ""
  Pop $Para1_DropList
  ${NSD_CB_AddString} $Para1_DropList "Hello"
  ${NSD_CB_AddString} $Para1_DropList "Hallo"
  ${NSD_CB_SelectString} $Para1_DropList "Hello"

  ${NSD_CreateDropList} 60u 40u 30% 12u ""
  Pop $Para2_DropList
  ${NSD_CB_AddString} $Para2_DropList "Mr"
  ${NSD_CB_AddString} $Para2_DropList "Herr"
  ${NSD_CB_SelectString} $Para2_DropList "Mr"

  ${NSD_CreateDropList} 60u 60u 30% 12u ""
  Pop $Para3_DropList
  ${NSD_CB_AddString} $Para3_DropList "Doe"
  ${NSD_CB_AddString} $Para3_DropList "Mustermann"
  ${NSD_CB_SelectString} $Para3_DropList "Doe"

  ${If} ${SectionIsSelected} ${SEC_RUN_SCRIPT}
    nsDialogs::Show
  ${EndIf}
FunctionEnd

Function nsDialogsPageLeave
  ${NSD_GetText} $Para1_DropList $Para1_Script
  ${NSD_GetText} $Para2_DropList $Para2_Script
  ${NSD_GetText} $Para3_DropList $Para3_Script
FunctionEnd

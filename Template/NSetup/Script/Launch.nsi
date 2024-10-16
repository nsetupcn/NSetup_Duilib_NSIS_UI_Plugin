/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
!define FILE_VERSION "4.0.2.0"
; 引入的头文件
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "StdUtils.nsh"
!include "nsPublic.nsh"

Var varLocalVersion
Var varOldLocalVersion
Var varUpdateType
;Request application privileges for Windows Vista
RequestExecutionLevel admin
;文件版本声明-开始
VIProductVersion ${FILE_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=2052 "Comments" "${PRODUCT_COMMENTS}"
VIAddVersionKey /LANG=2052 "CompanyName" "${PRODUCT_COMMENTS}"
VIAddVersionKey /LANG=2052 "LegalTrademarks" "${PRODUCT_NAME_EN}"
VIAddVersionKey /LANG=2052 "LegalCopyright" "${PRODUCT_LegalCopyright}"
VIAddVersionKey /LANG=2052 "FileDescription" "${PRODUCT_NAME}引导程序"
VIAddVersionKey /LANG=2052 "FileVersion" ${FILE_VERSION}
VIAddVersionKey /LANG=2052 "ProductVersion" ${PRODUCT_VERSION}
!define MUI_ICON "..\Resource\Package\appm.ico"

;Languages 
!insertmacro MUI_LANGUAGE "SimpChinese"
RequestExecutionLevel user
SilentInstall silent
OutFile "..\..\..\Temp\Temp\Launch.exe"

Function getLocalVersion
    ClearErrors
    ReadINIStr $varLocalVersion "$EXEDIR\version.ini" "LocalVersion" "UpdateVersion"
    IfErrors 0 +2
    ReadINIStr $varLocalVersion "$EXEDIR\version.ini" "LocalVersion" "ProductVersion"
    ;
    
    ClearErrors
    ReadINIStr $varUpdateType "$EXEDIR\version.ini" "LocalVersion" "UpdateType"
    IfErrors 0 +4
    StrCpy $varUpdateType 0
    WriteIniStr "$EXEDIR\version.ini" "LocalVersion" "UpdateType" 0
    FlushINI "$EXEDIR\version.ini"
    ;
FunctionEnd

Section InstallAppDataFiles
    ClearErrors
    ReadINIStr $R0 "$EXEDIR\version.ini" "LocalVersion" "UpdateOldVersion"
    IfErrors 0 +2
    Goto +8
    ${If} $R0 != ""
    IfFileExists "$EXEDIR\update\*" 0 +2
    RMDir /r /REBOOTOK "$EXEDIR\update"
    IfFileExists "$EXEDIR\$R0\*" 0 +4
    nsProcess::KillProcessByPath "$EXEDIR\$R0"
    RMDir /r /REBOOTOK "$EXEDIR\$R0"
    ${EndIf}
    IfFileExists "$EXEDIR\$R0\*" 0 +2
    Goto +2
    DeleteINIStr "$EXEDIR\version.ini" "LocalVersion" "UpdateOldVersion"
    ;
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    Call getLocalVersion
    SetOutPath "$EXEDIR\$varLocalVersion"
    Exec '"$EXEDIR\$varLocalVersion\${MAIN_APP_NAME}" $R0'
    ${If} $varUpdateType == 0
        Exec '"$EXEDIR\AutoUpdate.exe" /Auto'
    ${Endif}
    
    IfFileExists $EXEDIR\AutoUpdateSelf.exe 0 +2
    Delete $EXEDIR\AutoUpdateSelf.exe
    ;
SectionEnd

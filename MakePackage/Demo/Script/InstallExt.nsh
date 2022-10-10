 /*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
!include "x64.nsh"
!include "WinVer.nsh" 
!include "nsPublic.nsh"
!include "nsInstallSettings.nsh"
!include "nsInstallDependSettings.nsh"
!include "nsCustomVariables.nsh"
!include "nsAutoUpdate.nsh"

;多语言 
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

LangString LANG_MESSAGE ${LANG_SIMPCHINESE} "zh-CN"
LangString LANG_MESSAGE ${LANG_ENGLISH} "en"

LangString MUTEX_MESSAGE ${LANG_SIMPCHINESE} "有一个${PRODUCT_NAME}安装向导已经运行！"
LangString VERSION_COMPARE_MESSAGE ${LANG_SIMPCHINESE} "已安装的版本高于当前版本，是否继续安装？"
LangString APP_RUNNING_MESSAGE ${LANG_SIMPCHINESE} "当前程序正在运行，是否强制结束，继续安装？"
LangString APP_EXIT_MESSAGE ${LANG_SIMPCHINESE} "您确认退出安装过程？"
LangString SELECT_FOLD_MESSAGE ${LANG_SIMPCHINESE} "请选择文件夹"
LangString SPACE_NOT_AMPLE_MESSAGE ${LANG_SIMPCHINESE} "当前选择磁盘空间不足，请重新选择安装目录"
LangString DOWNLOADING_MESSAGE ${LANG_SIMPCHINESE} "正在下载"

LangString MUTEX_MESSAGE ${LANG_ENGLISH} "There is a ${PRODUCT_NAME} installation wizard already running!"
LangString VERSION_COMPARE_MESSAGE ${LANG_ENGLISH} "The installed version is higher than the current version. Do you want to continue the installation?"
LangString APP_RUNNING_MESSAGE ${LANG_ENGLISH} "The current program is running, is it forced to end, continue to install?"
LangString APP_EXIT_MESSAGE ${LANG_ENGLISH} "Are you sure to exit the installation process?"
LangString SELECT_FOLD_MESSAGE ${LANG_ENGLISH} "Please select a folder"
LangString SPACE_NOT_AMPLE_MESSAGE ${LANG_ENGLISH} "The currently selected disk space is insufficient"
LangString DOWNLOADING_MESSAGE ${LANG_ENGLISH} "downloading"

Var varShowInstTimerId
Var needReboot
Var varCurrentStep
Var needDownload
Var installStep
;onInit扩展操作
Function OnInitExt
    Delete "$oldInstallPath\install.log"
FunctionEnd
;初始化界面扩展操作
Function InstallProgressExt
    ${If} ${PRODUCT_INSTALL_MODEL_TYPE} == 3
        GetFunctionAddress $varShowInstTimerId InitUpdate
        nsSkinEngine::NSISCreatTimer $varShowInstTimerId 1
    ${EndIf}
FunctionEnd
;下一步扩展操作
Function InstallNextTabExt
FunctionEnd

;安装过程中扩展操作
Function InstallingExt
    nsSkinEngine::NSISInitAnimationBkControl "installTopBg" "$varResourceDir$(LANG_MESSAGE)" "4" "1" "1" "1" "0" 0 0
    nsSkinEngine::NSISStartAnimationBkControl "installTopBg" "1" "5000"
    ${If} ${PRODUCT_INSTALL_MODEL_TYPE} == 3
        Call InstallNextTab
        CreateDirectory "$TEMP\${PRODUCT_NAME}Depend" 
        Delete "$TEMP\${PRODUCT_NAME}Depend\${PRODUCT_INSTALL_ONLINE_EXE_NAME}"
        nsAutoUpdate::AddOneDownloadFileTask ${PRODUCT_INSTALL_ONLINE_MAIN_URL} ${PRODUCT_INSTALL_ONLINE_SPARE_URL} "$TEMP\${PRODUCT_NAME}Depend" "${PRODUCT_INSTALL_ONLINE_NAME_TIP}"
        nsAutoUpdate::SatrtDownloadUpdateFiles
    ${Else}
        nsSkinEngine::NSISStartInstall "true"
    ${EndIf}
FunctionEnd

Function InitUpdate
    nsSkinEngine::NSISKillTimer $varShowInstTimerId
    CreateDirectory "$APPDATA\${PRODUCT_NAME_EN}"
    nsAutoUpdate::SetAppServerSettings "${PRODUCT_UPDATE_ID}" "65B70DE7540C42759156483165E35215" "${PRODUCT_UPDATE_ADDRESS}"
    nsAutoUpdate::InitLog "false" "${PRODUCT_NAME_EN}"
    nsAutoUpdate::SetAppSettings "${UPDATE_NAME}" "$EXEDIR" "${PRODUCT_NAME_EN}" "${PRODUCT_UPDATE_KEY}"
    GetFunctionAddress $0 UpdateEventChangeCallback 
    nsAutoUpdate::SetUpdateEventChangeCallback $0
    GetFunctionAddress $0 ProgressChangeCallback 
    nsAutoUpdate::SetProgressChangeCallback $0
FunctionEnd

;开始安装扩展操作
Function InstallPageFuncExt
FunctionEnd
;自定义安装扩展操作
Function CustomInstallFuncExt
	Call InstallNextTab
FunctionEnd
;注册信息扩展操作
Function RegistKeysExt
FunctionEnd
;安装释放文件前
Function BeforeInstallFiles
    ${If} $oldInstallPath != ""
        SetOutPath "$oldInstallPath"
        File "..\..\..\Temp\Temp\uninst.exe"
    ${EndIf}
FunctionEnd
;安装释放文件后
Function LaterInstallFiles
    ${If} ${PRODUCT_INSTALL_MODEL_TYPE} != 3
        SetOverwrite try
    ${EndIf}
FunctionEnd
;扩展Sectipn
Function SectionFuncExt
   Call SectionInstallDependFuncExt
FunctionEnd
;点击完成后的附加动作
Function OnCompleteBtnFuncExt
    Exec '"$INSTDIR\${MAIN_LAUNCHAPP_NAME}"'
FunctionEnd
;安装完成阶段扩展操作
Function InstallCompleteExt
   nsSkinEngine::NSISStopAnimationBkControl "installTopBg"
   nsSkinEngine::NSISSetControlData "installTopBg"  "$varResourceDir$(LANG_MESSAGE)/installComplete.png"  "bkimage"
FunctionEnd

Function UpdateEventChangeCallback
    Pop $varCurrentStep
    ${If} $varCurrentStep == '${EVENT_DOWNLOAD_FILES_SUCCESS}'
        nsSkinEngine::NSISGetControlData "autoRunCheckBox" "Checked" ;
        Pop $0
        ${If} $0 == "${CHECKED}"
            StrCpy $R0 "/D $INSTDIR /Install /AutoRun"
        ${Else}
            StrCpy $R0 "/D $INSTDIR /Install"
        ${EndIf}
        
        Exec '"$TEMP\${PRODUCT_NAME}Depend\${PRODUCT_INSTALL_ONLINE_EXE_NAME}" $R0'
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function ProgressChangeCallback
    Pop $R1
    Pop $R2
    Pop $R3
    nsSkinEngine::NSISSetControlData "progressText"  "$R1%"  "text"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1"  "ProgressInt"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1" "TaskBarProgress"
    nsSkinEngine::NSISSetControlData "progressDetail"  "280"  "width"
    nsSkinEngine::NSISSetControlData "progressDetail"  "$(DOWNLOADING_MESSAGE)：$R2"  "text"
    DetailPrint '进度：$R1  下载文件名：$R2  是否完成：$R3'
FunctionEnd

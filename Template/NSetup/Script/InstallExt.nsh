/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
!include "x64.nsh"
!include "nsPublic.nsh"
!include "nsInstallSettings.nsh"
!include "nsInstallDependSettings.nsh"
!include "nsCustomVariables.nsh"
;初始化变量
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


LangString MUTEX_MESSAGE ${LANG_ENGLISH} "There is a ${PRODUCT_NAME} installation wizard already running!"
LangString VERSION_COMPARE_MESSAGE ${LANG_ENGLISH} "The installed version is higher than the current version. Do you want to continue the installation?"
LangString APP_RUNNING_MESSAGE ${LANG_ENGLISH} "The current program is running, is it forced to end, continue to install?"
LangString APP_EXIT_MESSAGE ${LANG_ENGLISH} "Are you sure to exit the installation process?"
LangString SELECT_FOLD_MESSAGE ${LANG_ENGLISH} "Please select a folder"

;onInit扩展操作
Function OnInitExt
FunctionEnd
;初始化界面扩展操作
Function InstallProgressExt
FunctionEnd
;下一步扩展操作
Function InstallNextTabExt
FunctionEnd

;安装过程中扩展操作
Function InstallingExt
   nsSkinEngine::NSISInitAnimationBkControl "installTopBg" "$varResourceDir$(LANG_MESSAGE)" "4" "1" "1" "1" "0" 0 0
   nsSkinEngine::NSISStartAnimationBkControl "installTopBg" "1" "5000"
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
FunctionEnd
;安装释放文件后
Function LaterInstallFiles
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

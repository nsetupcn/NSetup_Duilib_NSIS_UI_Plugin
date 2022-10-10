/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
;自定义宏
!include "nsInstallSettings.nsh"
!include "nsUnInstallFiles.nsh"
;多语言 
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

LangString LANG_MESSAGE ${LANG_SIMPCHINESE} "zh-CN"
LangString LANG_MESSAGE ${LANG_ENGLISH} "en"

LangString MUTEX_MESSAGE ${LANG_SIMPCHINESE} "有一个${PRODUCT_NAME_EN}卸载向导已经运行！"
LangString APP_RUNNING_MESSAGE ${LANG_SIMPCHINESE} "检测到您正在运行${PRODUCT_NAME}？"
LangString APP_RUNNING_MESSAGE_TXT ${LANG_SIMPCHINESE} "您可以：强制退出后安装，或取消安装"
LangString APP_EXIT_MESSAGE ${LANG_SIMPCHINESE} "是否退出卸载程序？"

LangString MUTEX_MESSAGE ${LANG_ENGLISH} "A ${PRODUCT_NAME_EN} uninstall wizard is running!"
LangString APP_RUNNING_MESSAGE ${LANG_ENGLISH} "We have detected Leigod Accelerator is currently open. Would you like to continue with the uninstallation?"
LangString APP_RUNNING_MESSAGE_TXT ${LANG_ENGLISH} "You can either force the installation after exit or cancel the installation"
LangString APP_EXIT_MESSAGE ${LANG_ENGLISH} "Do you exit the uninstall program?"

;onInit扩展操作
Function OnInitExt
FunctionEnd
;初始化界面扩展操作
Function UninstallProgressExt
	;最小化按钮绑定函数
	nsSkinEngine::NSISFindControl "InstallTab_sysMinBtn"
	Pop $0
	${If} $0 == "-1"
	MessageBox MB_OK "Do not have InstallTab_sysMinBtn"
	${Else}
	GetFunctionAddress $0 OnInstallMinFunc
	nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_sysMinBtn" $0
	${EndIf}
FunctionEnd
;开始卸载扩展操作
Function UnInstallPageFuncExt
FunctionEnd
;删除目录文件
Function UninstallAppFuncExt
    Delete "$varOldFileDir\uninst.exe"
    Delete "$varOldFileDir\version.ini"
    Delete "$varOldFileDir\install.log"
    ${If} ${PRODUCT_UNINSTALL_RMDIR_TYPE} == 0
        RMDir /r /REBOOTOK "$varOldFileDir"
    ${EndIf}
FunctionEnd
;卸载完成阶段扩展操作
Function UnInstallCompleteExt
	nsSkinEngine::NSISSetControlData "installTopBg"  "$varResourceDir$(LANG_MESSAGE)/unInstallCompleteTopBg.png"  "bkimage"
    Call OnNextBtnFunc
FunctionEnd
;卸载按钮点击扩展操作
Function OnCompleteBtnFuncExt
    !ifdef UNINSTALL_OPEN_URL
      ExecShell "open" ${UNINSTALL_OPEN_URL}
    !endif
FunctionEnd
;私有方法，非通用


/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
;自定义宏
!define MUI_ICON "..\Resource\Update\app.ico"
!define FILE_VERSION "1.3.1.2"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
LangString LANG_MESSAGE ${LANG_SIMPCHINESE} "zh-CN"
LangString LANG_MESSAGE ${LANG_ENGLISH} "en"

LangString CURRENT_VERSION_MESSAGE ${LANG_SIMPCHINESE} "当前版本"
LangString CURRENT_VERSION_MESSAGE ${LANG_ENGLISH} "current version"
LangString UPGRADE_PROCEDURE_MESSAGE ${LANG_SIMPCHINESE} "升级程序"
LangString UPGRADE_PROCEDURE_MESSAGE ${LANG_ENGLISH} "Upgrade procedure"
LangString RUN_MUTEX_MESSAGE ${LANG_SIMPCHINESE} "有一个升级已经运行！"
LangString RUN_MUTEX_MESSAGE ${LANG_ENGLISH} "There is an upgrade already running!"
LangString DOWNLOADING_MESSAGE ${LANG_SIMPCHINESE} "正在下载"
LangString DOWNLOADING_MESSAGE ${LANG_ENGLISH} "downloading"
LangString UPGRADABLE_VERSION_MESSAGE ${LANG_SIMPCHINESE} "可升版本"
LangString UPGRADABLE_VERSION_MESSAGE ${LANG_ENGLISH} "Latest version"
LangString CANCEL_UPDATE_MESSAGE ${LANG_SIMPCHINESE} "正在进行更新，是否确认取消"
LangString CANCEL_UPDATE_MESSAGE ${LANG_ENGLISH} "Update is in progress. Are you sure to cancel?"
LangString COMPARING_FILES_MESSAGE ${LANG_SIMPCHINESE} "正在对比文件，请稍后..."
LangString COMPARING_FILES_MESSAGE ${LANG_ENGLISH} "Comparing files, please wait..."
LangString DOWNLOADING_VERSION_FILE ${LANG_SIMPCHINESE} "正在下载版本文件列表..."
LangString DOWNLOADING_VERSION_FILE ${LANG_ENGLISH} "Downloading version file list ..."
LangString COPYING_LOCAL_FILES ${LANG_SIMPCHINESE} "正在复制本地文件到新版本..."
LangString COPYING_LOCAL_FILES ${LANG_ENGLISH} "Copying local files to new version ..."
LangString COMPARING_FILE_VERSION ${LANG_SIMPCHINESE} "开始比对文件版本差异，请稍后..."
LangString COMPARING_FILE_VERSION ${LANG_ENGLISH} "Start comparing file version diff..."
LangString SKIP_UPDATE_INFO ${LANG_SIMPCHINESE} "确定忽略本次版本的更新吗？点击确定将不再提示本次版本更新，忽略后可在“帮助 -> 检查更新”菜单下检测更新"
LangString SKIP_UPDATE_INFO ${LANG_ENGLISH} "Are you sure to skip this version? If yes, the automatic update window will no longer pop out for this version, but you can still use the 'Help->Check for Updates' function to upgrade"
;初始化界面扩展操作
Function InstallProgressExt
   ;最小化按钮绑定函数
   nsSkinEngine::NSISFindControl "minbtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have minbtn"
   ${Else}
    GetFunctionAddress $0 OnInstallMinFunc
    nsSkinEngine::NSISOnControlBindNSISScript "minbtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "CancelDownloadBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have CancelDownloadBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelDownloadBtn" $0
   ${EndIf}
FunctionEnd
;需要更新阶段扩展处理
Function NeedUpdateStepExt
    nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_use.png"  "bkimage"
FunctionEnd
;升级无效或者不需要更新阶段扩展处理
Function NoNeedUpdateStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_Latest_version.png"  "bkimage"
FunctionEnd
;网络错误阶段扩展处理
Function NetErrorStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_error_network.png"  "bkimage"
FunctionEnd
;升级成功阶段扩展处理
Function UpdateSuccessStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_upgrade_completed.png"  "bkimage"
FunctionEnd
;升级错误阶段扩展处理
Function UpdateErrorStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_error_upgrade.png"  "bkimage"
FunctionEnd
;检查替换文件失败
Function ReplaceStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_error_upgrade.png"  "bkimage"
FunctionEnd
;下载文件阶段扩展处理
Function DownloadUpdateStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_updating.png"  "bkimage"
FunctionEnd
;替换文件阶段扩展处理
Function ReplaceFilesStepExt
	nsSkinEngine::NSISSetControlData "WizardTab"  "$varResourceDirBG_replace_data.png"  "bkimage"
FunctionEnd

Function DoReplaceSuccess
FunctionEnd

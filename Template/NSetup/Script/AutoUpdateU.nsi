/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
; 安装程序初始定义常量
!define UPDATE_TEMP_NAME "AutoUpdateSelf.exe"
!define UPDATE_NAME "AutoUpdate.exe"

; 引入的头文件
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "StdUtils.nsh"
!include "nsPublic.nsh"
!include "nsSkinEngine.nsh"
!include "nsUtils.nsh"
!include "nsProcess.nsh"
!include "nsAutoUpdate.nsh"

;定义变量
Var Dialog
Var MessageBoxHandle
Var IsUpdateSelf
Var IsUpdateOther
Var IsAuto
Var IsForced
Var IsManual
Var IsBackstage
Var IsBanDisturb
Var IsHasUpdateMark
Var IsRunAs
Var IsAutoDown
Var IsRetry

Var varShowInstTimerId
Var varCurrentStep
Var varCurrentVersion
Var varLocalVersion
Var varCurrentParameters
Var varUpdateTempVersion
Var varUpdateTestIndex
Var varResourceDir
Var varKipVersion

!include "AutoUpdateExt.nsh"

;Request application privileges for Windows Vista
RequestExecutionLevel user
;文件版本声明-开始
VIProductVersion ${PRODUCT_UPDATE_FILE_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=2052 "Comments" "${PRODUCT_COMMENTS}"
VIAddVersionKey /LANG=2052 "CompanyName" "${PRODUCT_COMMENTS}"
VIAddVersionKey /LANG=2052 "LegalTrademarks" "${PRODUCT_NAME_EN}"
VIAddVersionKey /LANG=2052 "LegalCopyright" "${PRODUCT_LegalCopyright}"
VIAddVersionKey /LANG=2052 "FileDescription" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_UPDATE_FILE_VERSION}
VIAddVersionKey /LANG=2052 "ProductVersion" ${PRODUCT_VERSION}

OutFile "..\..\..\Temp\Temp\AutoUpdate.exe"

;初始化数据

; 安装和卸载页面
Page         custom     InstallProgress

;刷新关联图标
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function KillAllProcess
	Pop $R1
	nsProcess::FindProcessByName "${MAIN_APP_NAME}"
	Pop $R0
	${If} $R0 == "${FINDPROCESS}"
	${AndIf} $R1 != ""
		nsProcess::KillProcessByPath "$EXEDIR\$R1"
	${Endif}
FunctionEnd

Function .onInit
   SetOutPath "${UNINSTALL_DIR}\Update"
   SetOverwrite try
   ${If} ${PRODUCT_RESOURCE_ENCRYPT_TYPE} == 0
     File /r /x *.db "..\Resource\Update\*.*"
     StrCpy $R0 "${UNINSTALL_DIR}\Update"
     StrCpy $varResourceDir "${UNINSTALL_DIR}\Update\"
   ${Else}
    File /nonfatal "..\..\..\Temp\Resource\Update${PRODUCT_VERSION}.dat"
	StrCpy $R0 "${UNINSTALL_DIR}\Update\Update${PRODUCT_VERSION}.dat"
    StrCpy $varResourceDir ""
  ${EndIf}
   ;初始化数据  安装目录
   nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "$R0" "Update_$(LANG_MESSAGE).xml" "WizardTab" "false" "${PRODUCT_NAME_EN}" "${PRODUCT_KEY}" "$R0\app.ico" "true"
   Pop $Dialog
   ;初始化MessageBox窗口
   nsSkinEngine::NSISInitMessageBox "MessageBox_$(LANG_MESSAGE).xml" "TitleLabl" "TextLabl" "CloseBtn" "OkBtn" "YESBtn" "NOBtn" "AbortBtn" "RetryBtn" "IgnoreBtn" "cancelBtn"
   Pop $MessageBoxHandle
FunctionEnd

Function InstallProgress

   ;关闭按钮绑定函数
   nsSkinEngine::NSISFindControl "closebtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    nsSkinEngine::NSISMessageBox ${MB_OKCANCEL} "" "Do not have closebtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "closebtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "CancelCheckBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelCheckBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelCheckBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "KipUpdateBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have KipUpdateBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallKipFunc
    nsSkinEngine::NSISOnControlBindNSISScript "KipUpdateBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "CancelUpdateBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelUpdateBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelUpdateBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkUpdateBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkUpdateBtn"
   ${Else}
    GetFunctionAddress $0 DoUpdateFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkUpdateBtn" $0
   ${EndIf}
   ;第四页面
   nsSkinEngine::NSISFindControl "CancelReplaceBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelReplaceBtn"
   ${Else}
    GetFunctionAddress $0 OnCancelReplaceFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelReplaceBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkReplaceBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkReplaceBtn"
   ${Else}
    GetFunctionAddress $0 DoReplaceFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkReplaceBtn" $0
   ${EndIf}
   ;第五页面
   nsSkinEngine::NSISFindControl "CancelReplaceingBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelReplaceingBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelReplaceingBtn" $0
   ${EndIf}
   ;第六页面
   nsSkinEngine::NSISFindControl "OkLatestVersionBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkLatestVersionBtn"
   ${Else}
    GetFunctionAddress $0 DoNoNeedUpdate
    nsSkinEngine::NSISOnControlBindNSISScript "OkLatestVersionBtn" $0
   ${EndIf}
   ;第七页面
   nsSkinEngine::NSISFindControl "CancelNetErrorBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelNetErrorBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelNetErrorBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkNetErrorBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkNetErrorBtn"
   ${Else}
    GetFunctionAddress $0 DoNetErrorFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkNetErrorBtn" $0
   ${EndIf}
   ;第八页面
    nsSkinEngine::NSISFindControl "OkSuccessedBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkSuccessedBtn"
   ${Else}
    GetFunctionAddress $0 DoSuccessedFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkSuccessedBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "RunLatterBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have RunLatterBtn"
   ${Else}
    GetFunctionAddress $0 DoRunLatterFunc
    nsSkinEngine::NSISOnControlBindNSISScript "RunLatterBtn" $0
   ${EndIf}
   
   ;升级过程出错
   nsSkinEngine::NSISFindControl "CancelUpdateErrorBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelUpdateErrorBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelUpdateErrorBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkUpdateErrorBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkUpdateErrorBtn"
   ${Else}
    GetFunctionAddress $0 DoNetErrorFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkUpdateErrorBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkRetryReplaceBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkRetryReplaceBtn"
   ${Else}
    GetFunctionAddress $0 DoRetryReplaceFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkRetryReplaceBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "CancelRetryReplaceBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelRetryReplaceBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelRetryReplaceBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "OkRetryUnzipBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have OkRetryUnzipBtn"
   ${Else}
    GetFunctionAddress $0 DoRetryUnzipFunc
    nsSkinEngine::NSISOnControlBindNSISScript "OkRetryUnzipBtn" $0
   ${EndIf}
   
   nsSkinEngine::NSISFindControl "CancelRetryUnzipBtn"
   Pop $0
   ${If} $0 == "${NOFIND}"
    MessageBox MB_OK "Do not have CancelRetryUnzipBtn"
   ${Else}
    GetFunctionAddress $0 OnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "CancelRetryUnzipBtn" $0
   ${EndIf}
   
   GetFunctionAddress $varShowInstTimerId InitUpdate
   nsSkinEngine::NSISCreatTimer $varShowInstTimerId 1
   Call InstallProgressExt
   nsSkinEngine::NSISRunSkinEngine "false"
FunctionEnd

Function InitUpdate
    nsSkinEngine::NSISKillTimer $varShowInstTimerId
    Call CheckUpdateMark
    ${GetParameters} $varCurrentParameters # 获得命令行
    ;MessageBox MB_OK "$varCurrentParameters"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/UpdateVersion" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +4
    Call getUpdateTempVersion
    StrCpy $varCurrentVersion $varUpdateTempVersion
    Goto +2
    StrCpy $varCurrentVersion "$R1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/TestIndex" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +2
    Goto +2
    StrCpy $varUpdateTestIndex "$R1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/Auto" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsAuto "0"
    Goto +2
    StrCpy $IsAuto "1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/Backstage" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsBackstage "0"
    Goto +2
    StrCpy $IsBackstage "1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/BanDisturb" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsBanDisturb "0"
    Goto +2
    StrCpy $IsBanDisturb "1"
    ClearErrors
    ${GetOptions} $R0 "/UpdateSelf" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsUpdateSelf "0"
    Goto +3
    StrCpy $IsUpdateSelf "1"
    nsProcess::KillProcessByPath "$EXEDIR\${UPDATE_NAME}"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/UpdateOther" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsUpdateOther "0"
    Goto +4
    StrCpy $IsUpdateOther "1"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_REPLACE_FILES}"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_REPLACE_FILES}"
    Call getLocalVersion
    nsSkinEngine::NSISSetControlData "currentVersionTextStep1"  "$(CURRENT_VERSION_MESSAGE)：$varLocalVersion"  "text"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/AutoDown" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsAutoDown "0"
    Goto +2
    StrCpy $IsAutoDown "1"
    ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/RunAs" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $IsRunAs "0"
    Goto +2
    StrCpy $IsRunAs "1"
    ;处理mutex
    nsUtils::NSISCreateMutex "${PRODUCT_NAME_EN}AutoUpdate$varUpdateTestIndex"
    Pop $R0
    ${If} $R0 == 1
		${If} $IsRunAs == "0"
			${If} $IsAuto == "0"
				nsSkinEngine::NSISMessageBox ${MB_OK} "" "$(RUN_MUTEX_MESSAGE)"
			${EndIf}
			nsSkinEngine::NSISExitSkinEngine "false"
		${EndIf}
	${EndIf}
    ${If} $IsAuto == 0
    nsSkinEngine::NSISShowSkinEngine
    ${ElseIf} $IsAuto == 1
    ${AndIf} $IsUpdateSelf == 1
    ${AndIf} $IsBackstage == 0
    nsSkinEngine::NSISShowLowerRight
    ${EndIf}
    CreateDirectory "$APPDATA\${PRODUCT_NAME_EN}"
    nsAutoUpdate::SetAppServerSettings "${PRODUCT_UPDATE_ID}" "65B70DE7540C42759156483165E35215" "${PRODUCT_UPDATE_ADDRESS}"
    ${If} $IsUpdateSelf == 0
    nsAutoUpdate::InitLog "false" "${PRODUCT_NAME_EN}$varUpdateTestIndex"
    ${Else}
    nsAutoUpdate::InitLog "true" "${PRODUCT_NAME_EN}$varUpdateTestIndex"
    ${EndIf}
    nsAutoUpdate::SetAppSettings "${UPDATE_NAME}" "$EXEDIR" "${PRODUCT_NAME_EN}" "${PRODUCT_UPDATE_KEY}"
    GetFunctionAddress $0 UpdateEventChangeCallback 
    nsAutoUpdate::SetUpdateEventChangeCallback $0
    GetFunctionAddress $0 ProgressChangeCallback 
    nsAutoUpdate::SetProgressChangeCallback $0
    ${If} $IsHasUpdateMark == 1
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_REPLACE_FILES}"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_REPLACE_FILES}"
        nsSkinEngine::NSISShowSkinEngine
        GetFunctionAddress $0 ReplaceFiles
        BgWorker::CallAndWait
    ${Else}
        ${If} $IsUpdateOther == 0
        nsAutoUpdate::SetLocalVersion "$varLocalVersion"
        nsAutoUpdate::RequestUpdateInfo
        ${EndIf}
        ${If} $IsUpdateSelf == 1
        nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_NAME}"
        ${EndIf}
        ${If} $IsUpdateOther == 1
        GetFunctionAddress $0 ReplaceOtherFiles
        BgWorker::CallAndWait
        ${EndIf}
    ${EndIf}
FunctionEnd

Function OnInstallMinFunc
    nsSkinEngine::NSISMinSkinEngine
FunctionEnd

Function ReplaceFiles
    nsProcess::FindProcessByName "${MAIN_APP_NAME}"
    Pop $R1
    ${If} $R1 == 0
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_FILES_DOWNLOADED}"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_FILES_DOWNLOADED}"
	Call ReplaceFilesStepExt
    ${Else}
    nsAutoUpdate::ReplaceFiles
    ${Endif}
FunctionEnd

Function ReplaceOtherFiles
   nsAutoUpdate::ReplaceOtherFiles
FunctionEnd

Function getLocalVersion
   ClearErrors
   ReadINIStr $varLocalVersion "$EXEDIR\version.ini" "LocalVersion" "UpdateVersion"
   IfErrors 0 +2
   ReadINIStr $varLocalVersion "$EXEDIR\version.ini" "LocalVersion" "ProductVersion"
   ;
FunctionEnd

Function getUpdateTempVersion
   ClearErrors
   ReadINIStr $varUpdateTempVersion "$EXEDIR\version.ini" "LocalVersion" "UpdateTempVersion"
FunctionEnd

Function WriteUpdateMark
    WriteIniStr "$EXEDIR\version.ini" "LocalVersion" "UpdateTempVersion" "$varCurrentVersion"
    WriteIniStr "$EXEDIR\version.ini" "LocalVersion" "ReplaceTag" "1"
    FlushINI "$EXEDIR\version.ini"
FunctionEnd

Function removeUpdateMark
    DeleteINIStr "$EXEDIR\version.ini" "LocalVersion" "ReplaceTag"
    DeleteINIStr "$EXEDIR\version.ini" "LocalVersion" "UpdateTempVersion"
    FlushINI "$EXEDIR\version.ini"
FunctionEnd

Function CheckUpdateMark
    ClearErrors
    ReadINIStr $IsHasUpdateMark "$EXEDIR\version.ini" "LocalVersion" "ReplaceTag"
    IfErrors 0 +2
    StrCpy $IsHasUpdateMark "0"
    ;
FunctionEnd

Function ProgressChangeCallback
    Pop $R1
    Pop $R2
    Pop $R3
    nsSkinEngine::NSISSetControlData "progressText"  "$R1%"  "text"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1"  "ProgressInt"
    nsSkinEngine::NSISSetControlData "InstallProgressBar"  "$R1" "TaskBarProgress"
    nsSkinEngine::NSISSetControlData "progressTip"  "$(DOWNLOADING_MESSAGE)：$R2"  "text"
    DetailPrint '进度：$R1  下载文件名：$R2  是否完成：$R3'
FunctionEnd

Function UpdateEventChangeCallback
    Pop $varCurrentStep
    ${If} $varCurrentStep == '${EVENT_CHECK_UPDATE}'
    DetailPrint '检查更新'
    ${ElseIf} $varCurrentStep == '${EVENT_CHECK_UPDATE_SUCCESS}'
    DetailPrint '检查更新成功'
    ${ElseIf} $varCurrentStep == '${EVENT_INIT_LOG_SUCCESS}'
    DetailPrint '初始化log成功'

    ${ElseIf} $varCurrentStep == '${EVENT_UPDATE_EFFECTIVE}'
    DetailPrint '升级有效'
    ${ElseIf} $varCurrentStep == '${EVENT_UPDATE_NO_EFFECTIVE}'
    DetailPrint '升级无效'
    Call NoNeedUpdate
    Call NoNeedUpdateStepExt
    ${ElseIf} $varCurrentStep == '${EVENT_UPDATE_NEED}'
    DetailPrint '需要更新'
        Call NeedUpdateStepExt
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_SHOW_UPDATE_INFO}"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_SHOW_UPDATE_INFO}"
        nsAutoUpdate::CurrentVersion
        Pop $varCurrentVersion
        DetailPrint '可升版本:$varCurrentVersion'
        nsSkinEngine::NSISSetControlData "newVersionTextStep2"  "$(UPGRADABLE_VERSION_MESSAGE)：$varCurrentVersion"  "text"
	${If} $(LANG_MESSAGE) == "zh-CN"
	  nsAutoUpdate::UpdateInfo
	${ElseIf} $(LANG_MESSAGE) == "en"
	  nsAutoUpdate::UpdateInfoEn
	${EndIf}
	Pop $R0
        DetailPrint '升级信息:$R0'
        nsSkinEngine::NSISSetControlData "updateInfo"  $R0  "text"
        nsAutoUpdate::IsBackstage
        Pop $IsBackstage
        ${If} $IsBackstage == 1
         StrCpy $varCurrentParameters "$varCurrentParameters /Backstage"
        ${EndIf}
        DetailPrint '是否后台:$R0'
        nsAutoUpdate::IsManual
        Pop $IsManual
        DetailPrint '是否手动:$R0'
        nsAutoUpdate::IsForced
        Pop $IsForced
        ${If} $IsForced == 1
            nsSkinEngine::NSISSetControlData "minbtn"  "false"  "visible"
            nsSkinEngine::NSISSetControlData "closebtn"  "false"  "visible"
            nsSkinEngine::NSISSetControlData "CancelUpdateBtn"  "false"  "visible"
            nsSkinEngine::NSISSetControlData "KipUpdateBtn"  "false"  "visible"
			nsSkinEngine::NSISSetControlData "CancelReplaceBtn"  "false"  "visible"
			nsSkinEngine::NSISSetControlData "CancelDownloadBtn"  "false"  "visible"
        ${EndIf}
        DetailPrint '是否强制:$R0'
        ClearErrors
        ReadINIStr $varKipVersion "$EXEDIR\version.ini" "LocalVersion" "KipVersion"
        ${If} $IsAuto == 1
            ${If} $IsBanDisturb == 1
            ${AndIf} $IsForced != 1
            ${OrIf} $IsManual == 1
            ${OrIf} $varKipVersion == $varCurrentVersion
                nsSkinEngine::NSISExitSkinEngine "false"
            ${ElseIf} $IsBackstage == 1
                nsAutoUpdate::DownloadUpdateFileListIni
            ${ElseIf} $IsBackstage == 0
                nsSkinEngine::NSISShowLowerRight
            ${EndIf}
        ${EndIf}
        ${If} $IsAutoDown == 1
        ${OrIf} $IsRetry == 1
            nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_DOWNLOAD_FILES}"
            nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_DOWNLOAD_FILES}"
            nsSkinEngine::NSISSetControlData "newVersionTextStep3"  "$(UPGRADABLE_VERSION_MESSAGE)：$varCurrentVersion"  "text"
            nsAutoUpdate::DownloadUpdateFileListIni
        ${EndIf}
        nsSkinEngine::NSISSetControlData "progressText"  "0%"  "text"
        nsSkinEngine::NSISSetControlData "InstallProgressBar"  "0"  "ProgressInt"
        nsSkinEngine::NSISSetControlData "InstallProgressBar"  "0" "TaskBarProgress"
    ${ElseIf} $varCurrentStep == '${EVENT_UPDATE_NO_NEED}'
     Call NoNeedUpdate
     Call NoNeedUpdateStepExt
    DetailPrint '不需要更新'
    ${ElseIf} $varCurrentStep == '${EVENT_DOWNLOAD_FILELIST}'
    Call DownloadUpdateStepExt
    DetailPrint '下载filelist.ini'
    nsSkinEngine::NSISSetControlData "progressTip"  "$(DOWNLOADING_VERSION_FILE)"  "text"
    ${ElseIf} $varCurrentStep == '${EVENT_DOWNLOAD_FILELIST_SUCCESS}'
    DetailPrint '下载filelist.ini成功'
    nsSkinEngine::NSISSetControlData "progressTip"  "$(COPYING_LOCAL_FILES)"  "text"
	${If} ${PRODUCT_VERSION_LEVEL} == 0
        IfFileExists $EXEDIR\$varCurrentVersion\* 0 +2
        Goto +3
        GetFunctionAddress $0 CopyOldFiles 
        BgWorker::CallAndWait
	${EndIf}
    GetFunctionAddress $0 DownloadFiles
    BgWorker::CallAndWait
    ${ElseIf} $varCurrentStep == '${EVENT_COMPARE_FILES}'
    nsSkinEngine::NSISSetControlData "progressTip"  "$(COMPARING_FILES_MESSAGE)"  "text"
    DetailPrint '比对文件'
    nsSkinEngine::NSISSetControlData "progressTip"  "$(COMPARING_FILE_VERSION)"  "text"
    ${ElseIf} $varCurrentStep == '${EVENT_COMPARE_FILES_SUCCESS}'
    DetailPrint '比对文件成功'
    ${ElseIf} $varCurrentStep == '${EVENT_DOWNLOAD_FILES}'
    DetailPrint '下载文件'
    ${ElseIf} $varCurrentStep == '${EVENT_DOWNLOAD_FILES_SUCCESS}'
    DetailPrint '下载文件成功'
    Call DoUnzipFunc
    ${ElseIf} $varCurrentStep == '${EVENT_UNZIP_FILES}'
    DetailPrint '解压文件'
    ${ElseIf} $varCurrentStep == '${EVENT_UNZIP_FILES_SUCCESS}'
    DetailPrint '解压文件成功'
    GetFunctionAddress $0 ReplaceFiles
    BgWorker::CallAndWait
    ${ElseIf} $varCurrentStep == '${EVENT_REPLACE_FILES}'
    DetailPrint '替换文件'
    Call removeUpdateMark
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_REPLACE_FILES}"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_REPLACE_FILES}"
    Call ReplaceFilesStepExt
    ${ElseIf} $varCurrentStep == '${EVENT_REPLACE_FILES_SUCCESS}'
    DetailPrint '替换文件成功'
    Call DoReplaceSuccess
    ${ElseIf} $varCurrentStep == '${EVENT_NEED_REPLACE_SELF_FILE}'
    DetailPrint '替换自身'
    nsAutoUpdate::ReplaceUzipDirFileToCurrentDir "${UPDATE_NAME}" "${UPDATE_TEMP_NAME}"
    Pop $R1
        ${If} $R1 == 1
        DetailPrint '运行${UPDATE_TEMP_NAME}'
        nsSkinEngine::NSISHideSkinEngine
        Exec '"$EXEDIR\${UPDATE_TEMP_NAME}" /UpdateSelf /UpdateOther $varCurrentParameters /UpdateVersion $varCurrentVersion /TestIndex $varUpdateTestIndex'
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
            Call UpdateError
        ${EndIf}
    ${ElseIf} $varCurrentStep == '${EVENT_UPDATE_SUCCESS}'
    DetailPrint '升级成功'
        ${If} ${PRODUCT_VERSION_LEVEL} == 0
            Call createOldVersion
        ${EndIf}
        WriteIniStr "$EXEDIR\version.ini" "LocalVersion" "UpdateVersion" "$varCurrentVersion"
        FlushINI "$EXEDIR\version.ini"
        IfFileExists "$EXEDIR\UpdatePatch.exe" 0 +1
        Exec '"$EXEDIR\UpdatePatch.exe"'
        ${If} $IsAuto == 1
        ${AndIf} $IsBackstage == 1
        ${If} $EXEFILE == ${UPDATE_TEMP_NAME}
            SelfDel::del
        ${EndIf}
        nsSkinEngine::NSISExitSkinEngine "false"
        ${Else}
        Call UpdateSuccess
        ${EndIf}
        Call RefreshShellIcons
        DeleteRegValue HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}AutoUpdate"
    ${ElseIf} $varCurrentStep > '${EVENT_UPDATE_SUCCESS}' ;EVENT_SOME_ERROR
    DetailPrint "出错了 代号：$varCurrentStep"
        ${If} $varCurrentStep == '${EVENT_INIT_DIR_ERROR}'
        DetailPrint "需要提升权限"
        nsAutoUpdate::RunAsProcessByFilePath "$EXEPATH" "/RunsAs /AutoDown $varCurrentParameters"
        Pop $R0
            ${If} $R0 == 0
                Call UpdateError
            ${Else}
                nsSkinEngine::NSISExitSkinEngine "false"
            ${EndIf}
        ${ElseIf} $varCurrentStep == '${EVENT_CHECK_UPDATE_ERROR}'
        ${OrIf} $varCurrentStep == '${EVENT_DOWNLOAD_FILES_ERROR}'
         Call NetError
         Call NetErrorStepExt
         ${ElseIf} $varCurrentStep == '${EVENT_UNZIP_FILES_ERROR}'
         Call UnzipError
         Call UnzipStepExt
        ${ElseIf} $varCurrentStep == '${EVENT_REPLACE_FILES_ERROR}'
         Call ReplaceError
         Call ReplaceStepExt
        ${Else}
         Call UpdateError
         Call UpdateErrorStepExt
        ${EndIf}
    ${EndIf}
FunctionEnd

Function CopyOldFiles
    CreateDirectory $EXEDIR\$varCurrentVersion
    CopyFiles /SILENT $EXEDIR\$varLocalVersion\*.* $EXEDIR\$varCurrentVersion
FunctionEnd

Function DownloadFiles
    nsAutoUpdate::DownloadNeedUpdateFiles
FunctionEnd

Function NoNeedUpdate
    ${If} $IsAuto == 0
		ClearErrors
		ReadINIStr $R0 "$EXEDIR\version.ini" "LocalVersion" "UpdateOldVersion"
		IfErrors 0 +2
		Goto +4
		${If} $R0 != ""
			Call UpdateSuccess
		${Else}
			nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_NO_NEED}"
			nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_NO_NEED}"
			nsSkinEngine::NSISSetControlData "currentVersionTextStep5"  "$(CURRENT_VERSION_MESSAGE)：$varLocalVersion"  "text"
		${EndIf}
    ${Else}
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function NetError
    ${If} $IsAuto == 0 
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_NET_ERROR}"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_NET_ERROR}"
    ${Else}
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function UnzipError
    ${If} $IsAuto == 0 
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_UNZIP_FILES_ERROR}"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_UNZIP_FILES_ERROR}"
    ${Else}
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function ReplaceError
	${If} $IsAuto == 0 
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_REPLACE_FILES_ERROR}"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_REPLACE_FILES_ERROR}"
    ${Else}
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function DoRetryUnzipFunc
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_REPLACE_FILES}"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_REPLACE_FILES}"
    Call DoUnzipFunc
FunctionEnd

Function DoRetryReplaceFunc
	WriteRegStr HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}AutoUpdate" "$EXEDIR\$EXEFILE /UpdateOther /UpdateVersion $varCurrentVersion"
	Call DoReplaceFunc
FunctionEnd

Function UpdateSuccess
	Call getLocalVersion
	nsSkinEngine::NSISSetControlData "currentVersionTextStep4"  "$(CURRENT_VERSION_MESSAGE)：$varLocalVersion"  "text"
	nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_UPDATE_SUCCESS}"
	nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_UPDATE_SUCCESS}"
    Call UpdateSuccessStepExt
FunctionEnd

Function UpdateError
    ${If} $IsBackstage == 0 
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_UPDATE_ERROR}"
        nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_UPDATE_ERROR}"
    ${Else}
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function DoUpdateFunc
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_DOWNLOAD_FILES}"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_DOWNLOAD_FILES}"
    nsSkinEngine::NSISSetControlData "newVersionTextStep3"  "$(UPGRADABLE_VERSION_MESSAGE)：$varCurrentVersion"  "text"
    nsAutoUpdate::DownloadUpdateFileListIni
FunctionEnd

Function UnzipFiles
    nsAutoUpdate::UnzipNeedUpdateFiles
FunctionEnd

Function DoUnzipFunc
    GetFunctionAddress $0 UnzipFiles
    BgWorker::CallAndWait
FunctionEnd

Function DoReplaceFunc
	nsProcess::KillProcessByName "${MAIN_APP_NAME}"
	GetFunctionAddress $0 ReplaceFiles
    BgWorker::CallAndWait
FunctionEnd

Function DoNoNeedUpdate
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function DoNetErrorFunc
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "WizardTab" "${STEP_CHECK_UPDATE}"
    nsSkinEngine::NSISSetTabLayoutCurrentIndex "BottomWizardTab" "${STEP_CHECK_UPDATE}"
    Call ReCheckNetStepExt
    nsAutoUpdate::RequestUpdateInfo
    StrCpy $IsRetry "1"
FunctionEnd

Function DoRunLatterFunc
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function DoSuccessedFunc
    nsSkinEngine::NSISHideSkinEngine
    nsProcess::KillProcessByName "${MAIN_APP_NAME}"
    Exec '"$EXEDIR\${MAIN_LAUNCHAPP_NAME}"'
    ${If} $EXEFILE == ${UPDATE_TEMP_NAME}
        SelfDel::del
    ${EndIf}
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function OnCancelReplaceFunc
    nsSkinEngine::NSISMessageBox ${MB_OKCANCEL} "" "$(CANCEL_UPDATE_MESSAGE)"
    Pop $0
    ${If} $0 == "1"
        Call WriteUpdateMark
        nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function OnInstallCancelFunc
    ${If} $varCurrentStep == '${EVENT_UPDATE_SUCCESS}'
    ${OrIf} $varCurrentStep == '${EVENT_UPDATE_NO_NEED}'
    ${OrIf} $varCurrentStep == '${EVENT_UPDATE_NO_EFFECTIVE}'
        nsSkinEngine::NSISExitSkinEngine "false"
    ${Else}
        nsSkinEngine::NSISMessageBox ${MB_OKCANCEL} "" "$(CANCEL_UPDATE_MESSAGE)"
        Pop $0
        ${If} $0 == "${ON_OK}"
            nsSkinEngine::NSISExitSkinEngine "false"
        ${EndIf}
    ${EndIf}
FunctionEnd

Function OnInstallKipFunc
    nsSkinEngine::NSISMessageBox ${MB_OKCANCEL} "" "$(SKIP_UPDATE_INFO)"
    Pop $0
    ${If} $0 == "${ON_OK}"
        WriteIniStr "$EXEDIR\version.ini" "LocalVersion" "KipVersion" "$varCurrentVersion"
        FlushINI "$EXEDIR\version.ini"
	nsSkinEngine::NSISExitSkinEngine "false"
    ${EndIf}
FunctionEnd

Function createOldVersion
    Call getLocalVersion
    WriteIniStr "$EXEDIR\version.ini" "LocalVersion" "UpdateOldVersion" "$varLocalVersion"
    FlushINI "$EXEDIR\version.ini"
FunctionEnd

Section InstallFiles
SectionEnd

Function .onInstSuccess
FunctionEnd
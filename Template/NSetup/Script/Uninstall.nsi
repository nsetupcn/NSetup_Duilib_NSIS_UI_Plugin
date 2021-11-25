/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
Var Dialog
Var MessageBoxHandle
Var isSilence
Var varLocalVersion
Var varOldLocalVersion
Var varOldFileDir
Var varResourceDir
Var varAsynTimerId

!define MUI_ICON "..\Resource\Package\appu.ico"

; 引入的头文件
!include "MUI.nsh"
!include "x64.nsh"
!include "FileFunc.nsh"
!include "StdUtils.nsh"
!include "nsPublic.nsh"
!include "nsSkinEngine.nsh"
!include "nsUtils.nsh"
!include "nsProcess.nsh"
!include "UninstallExt.nsh"
;Request application privileges for Windows Vista
RequestExecutionLevel admin
;文件版本声明-开始
VIProductVersion ${FILE_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=2052 "Comments" "${PRODUCT_COMMENTS}"
VIAddVersionKey /LANG=2052 "CompanyName" "${PRODUCT_COMMENTS}"
VIAddVersionKey /LANG=2052 "LegalTrademarks" "${PRODUCT_NAME_EN}"
VIAddVersionKey /LANG=2052 "LegalCopyright" "${PRODUCT_LegalCopyright}"
VIAddVersionKey /LANG=2052 "FileDescription" "${PRODUCT_NAME}卸载程序"
VIAddVersionKey /LANG=2052 "FileVersion" ${FILE_VERSION}
VIAddVersionKey /LANG=2052 "ProductVersion" ${PRODUCT_VERSION}

OutFile "..\..\..\Temp\Temp\uninst.exe"

; 安装和卸载页面
Page         custom     UninstallProgress
Page         instfiles  "" UninstallNow

;刷新关联图标
Function RefreshShellIcons
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function KillAllProcess
	${If} ${PRODUCT_SUPPORT_UPDATE} == 1
		Call getLocalVersion
		nsProcess::KillProcessByPath "$varOldFileDir\$varLocalVersion"
	${Else}
		nsProcess::KillProcessByPath "$varOldFileDir"
	${EndIf}
FunctionEnd

Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
  
  ClearErrors
  ${GetParameters} $R0 # 获得命令行
  ${GetOptions} $R0 "/UnInstall" $varOldFileDir # 在命令行里查找是否存在/T选项
  IfErrors 0 +4
  CopyFiles /SILENT "$EXEPATH" "$TEMP\${PRODUCT_NAME_EN}\$EXEFILE"
  Exec '"$TEMP\${PRODUCT_NAME_EN}\$EXEFILE" /UnInstall $EXEDIR $R0'
  Abort
  ClearErrors
    ${GetParameters} $R0 # 获得命令行
    ${GetOptions} $R0 "/S" $R1 # 在命令行里查找是否存在/T选项
    IfErrors 0 +3
    StrCpy $isSilence "0"
    Goto +2
    StrCpy $isSilence "1"
  SetOutPath "${UNINSTALL_DIR}\UnInstall"
  SetOverwrite try
  ${If} ${PRODUCT_RESOURCE_ENCRYPT_TYPE} == 0
    File /r /x *.db "..\Resource\Package\UnInstall\*.*"
    File /r /x *.db "..\Resource\Package\Common\*.*"
    StrCpy $R0 "${UNINSTALL_DIR}\UnInstall"
    StrCpy $varResourceDir "${UNINSTALL_DIR}\UnInstall\"
  ${Else}
    File /nonfatal "..\..\..\Temp\Resource\UnInstall${PRODUCT_VERSION}.dat"
	StrCpy $R0 "${UNINSTALL_DIR}\UnInstall\UnInstall${PRODUCT_VERSION}.dat"
    StrCpy $varResourceDir ""
  ${EndIf}
  ;初始化数据  安装目录
  nsSkinEngine::NSISInitSkinEngine /NOUNLOAD "$R0" "Uninstall_$(LANG_MESSAGE).xml" "WizardTab" "false" "${PRODUCT_NAME_EN}" "${PRODUCT_KEY}" "$R0\app.ico" "true"
   Pop $Dialog
   ;初始化MessageBox窗口
   nsSkinEngine::NSISInitMessageBox "MessageBox_$(LANG_MESSAGE).xml" "TitleLabl" "TextLabl" "CloseBtn" "OkBtn" "YESBtn" "NOBtn" "AbortBtn" "RetryBtn" "IgnoreBtn" "cancelBtn"
   Pop $MessageBoxHandle

   ;创建互斥防止重复运行
  nsUtils::NSISCreateMutex "${PRODUCT_NAME_EN}UnInstall"
  Pop $R0
  ${If} $R0 == 1
    nsSkinEngine::NSISMessageBox ${MB_OK} "" "$(MUTEX_MESSAGE)"
    Abort
  ${EndIf}

  Call OnInitExt
FunctionEnd

Function OnProgressChangeCallback
Pop $0
${If} $0 == 100
	GetFunctionAddress $varAsynTimerId OnCompleteDo
	nsSkinEngine::NSISCreatTimer $varAsynTimerId 1
${EndIf}
nsSkinEngine::NSISSetControlData "UnInstallProgressBar"  "$0"  "ProgressInt"
nsSkinEngine::NSISSetControlData "progressText"  "$0%"  "text"
FunctionEnd

Function UninstallProgress
   ;关闭按钮绑定函数
   nsSkinEngine::NSISFindControl "InstallTab_sysCloseBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have InstallTab_sysCloseBtn"
   ${Else}
    GetFunctionAddress $0 OnUnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "InstallTab_sysCloseBtn" $0
   ${EndIf}
   
   ;------------------------安装界面 1-----------------------
   
   ;取消按钮绑定函数
   nsSkinEngine::NSISFindControl "unInstallCancelBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have unInstallCancelBtn"
   ${Else}
    GetFunctionAddress $0 OnUnInstallCancelFunc
    nsSkinEngine::NSISOnControlBindNSISScript "unInstallCancelBtn" $0
   ${EndIf}
 
   ;残忍卸载 
   nsSkinEngine::NSISFindControl "unInstallBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have unInstallBtn"
   ${Else}
    GetFunctionAddress $0 UnInstallPageFunc
    nsSkinEngine::NSISOnControlBindNSISScript "unInstallBtn" $0
   ${EndIf}
   
   ;卸载完成
   nsSkinEngine::NSISFindControl "unInstallOkBtn"
   Pop $0
   ${If} $0 == "-1"
    MessageBox MB_OK "Do not have unInstallOkBtn"
   ${Else}
    GetFunctionAddress $0 OnCompleteBtnFunc
    nsSkinEngine::NSISOnControlBindNSISScript "unInstallOkBtn" $0
   ${EndIf}
   ;--------------------------------------窗体显示-----------------------------------
   Call UninstallProgressExt
   nsSkinEngine::NSISRunSkinEngine "true"
FunctionEnd

Function OnInstallMinFunc
    nsSkinEngine::NSISMinSkinEngine
FunctionEnd

Function OnUnInstallCancelFunc
     nsSkinEngine::NSISMessageBox ${MB_OKCANCEL} "" "$(APP_EXIT_MESSAGE)"
   Pop $0
    ${If} $0 == "1"
     nsSkinEngine::NSISExitSkinEngine "false"
   ${EndIf} 
FunctionEnd

Function OnNextBtnFunc
   nsSkinEngine::NSISNextTab "WizardTab"
   nsSkinEngine::NSISNextTab "settings"
FunctionEnd

Function UnInstallPageFunc
  nsProcess::FindProcessByName "${MAIN_APP_NAME}"
  Pop $R0
  ${If} $R0 == 0
    ${If} $isSilence == "0"
		nsSkinEngine::NSISMessageBox ${MB_OKCANCEL} "" "$(APP_RUNNING_MESSAGE)"
		Pop $1
		${If} $1 == 1
			Call KillAllProcess
		${Else}
			nsSkinEngine::NSISExitSkinEngine "false"
		${EndIf}
	${Else}
		Call KillAllProcess
	${EndIf}
  ${EndIf}
    Call UnInstallPageFuncExt
	Call OnNextBtnFunc
    nsSkinEngine::NSISStartUnInstall "false"
FunctionEnd

Function UninstallNow
    GetFunctionAddress $0 OnProgressChangeCallback
    nsSkinEngine::SetProgressChangeCallback $0
FunctionEnd

Function getLocalVersion
   ClearErrors
   ReadRegStr $varLocalVersion HKCU "${PRODUCT_REG_KEY}" "UpdateVersion"
   IfErrors 0 +2
   ReadRegStr $varLocalVersion HKCU "${PRODUCT_REG_KEY}" "ProductVersion"
   ;
FunctionEnd

Section UninstallApp
    ${If} $isSilence == "1"
        Call KillAllProcess
    ${EndIf}
	SetShellVarContext all
    ;${StdUtils.InvokeShellVerb} $0 "$varOldFileDir" "${MAIN_LAUNCHAPP_NAME}" ${StdUtils.Const.ShellVerb.UnpinFromTaskbar}
    Delete "$SMPROGRAMS\${PRODUCT_NAME_EN}\*.lnk"
    Delete "$SMPROGRAMS\${PRODUCT_NAME_EN}\Uninstall.lnk"
    Delete "$SMPROGRAMS\${PRODUCT_NAME_EN}\Website.lnk"
    Delete "$SMPROGRAMS\${PRODUCT_NAME_EN}\${PRODUCT_NAME}.lnk"
    Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
    RMDir /r /REBOOTOK  "$SMPROGRAMS\${PRODUCT_NAME_EN}"
    IfFileExists "$varOldFileDir\*" 0 +1
    RMDir /r /REBOOTOK "$varOldFileDir" 
    DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
    DeleteRegKey HKCU "${PRODUCT_REG_KEY}"
    DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}"
    DeleteRegValue HKCU "${PRODUCT_AUTORUN_KEY}" "${PRODUCT_NAME}"
    ${If} $isSilence == "1"
        SelfDel::del /RMDIR
    ${EndIf}
SectionEnd

Function OnCompleteDo
    nsSkinEngine::NSISKillTimer $varAsynTimerId
    Call UnInstallCompleteExt
FunctionEnd

Function OnCompleteBtnFunc
    nsSkinEngine::NSISHideSkinEngine
    Call OnCompleteBtnFuncExt
    Call RefreshShellIcons
    ${If} ${PRODUCT_SUPPORT_STATISTICS} == 1
        nsStatistics::InitCommonStatistics
        nsStatistics::AddOneAttribute "step" "1"
        nsStatistics::AddOneAttribute "currentversion" "${PRODUCT_VERSION}"
        nsStatistics::AddOneAttribute "channelid" "$EXEFILE"
        nsStatistics::SendStatisticsInfo "${PRODUCT_STATISTICS_ADDRESS}" "65B70DE7540C42759156483165E35215" "${PRODUCT_UPDATE_ID}"
    ${EndIf}   
    SelfDel::del /RMDIR
    nsSkinEngine::NSISExitSkinEngine "false"
FunctionEnd

Function .onInstSuccess
	${If} $isSilence == "1"
		SelfDel::del /RMDIR
	${EndIf}
FunctionEnd
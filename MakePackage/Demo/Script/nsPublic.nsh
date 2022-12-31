/*
    Compile the script to use the Unicode version of NSIS
    The producers：www.nsetup.cn 
*/
; 安装程序初始定义常量
!include "nsCurrentVersion.nsh"
!include "nsProjectSettings.nsh"
;常量
;产品对应nsSkinEngine授权码 请勿更改
!define PRODUCT_PUBLISHER "${PRODUCT_NAME_EN}"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_NAME}"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME_EN}"
!define PRODUCT_AUTORUN_KEY "Software\Microsoft\Windows\CurrentVersion\Run"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define UNINSTALL_DIR "$TEMP\${PRODUCT_NAME_EN}\${PRODUCT_NAME_EN}Step"
!define PRODUCT_REG_KEY "SOFTWARE\${PRODUCT_NAME_EN}"
!define DEFAULT_DIR "$APPDATA\${PRODUCT_NAME_EN}"

;刷新关联图标
!define SHCNE_ASSOCCHANGED 0x08000000
!define SHCNF_IDLIST 0
; 安装不需要重启
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
; 设置文件覆盖标记
SetOverwrite on
; 设置数据块优化
SetDatablockOptimize on
; 设置在数据中写入文件时间
SetDateSave on
; 是否允许安装在根目录下
AllowRootDirInstall false
Name "${PRODUCT_NAME}"

LicenseName "${PRODUCT_NAME_EN}"
LicenseKey "${PRODUCT_KEY}"

InstallDir "$APPDATA\${PRODUCT_NAME_EN}"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"

OutFileMode auto


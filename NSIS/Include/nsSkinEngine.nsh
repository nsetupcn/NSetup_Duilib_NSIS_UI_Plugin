;nsSkinEngine::NSISMessageBox 
!define MB_OK 0x00000000L
!define MB_OKCANCEL 0x00000001L
!define MB_ABORTRETRYIGNORE 0x00000002L
!define MB_YESNOCANCEL 0x00000003L
!define MB_YESNO 0x00000004L
!define MB_RETRYCANCEL 0x00000005L

!define ON_OK 1
!define ON_CANCEL 0
!define ON_YES 1
!define ON_NO 0
;nsSkinEngine::NSISFindControl
!define NOFIND "-1"

;nsSkinEngine::NSISGetControlData->CheckBox
!define CHECKED "1"
!define NOCHECKED "0"

;nsSkinEngine::NSISSelectFolderDialog
!define SELECT_CANCEL "-1"

!macro InstallOnReboot Source Destination
  SetFileAttributes `${Destination}` NORMAL
  File `/oname=${Destination}.new` `${Source}`
  Delete /rebootok `${Destination}`
  Rename /rebootok `${Destination}.new` `${Destination}`
!macroend
!define InstallOnReboot `!insertmacro InstallOnReboot`
 
!macro DeleteOnReboot Path
  IfFileExists `${Path}` 0 +3
    SetFileAttributes `${Path}` NORMAL
    Delete /rebootok `${Path}`
!macroend
!define DeleteOnReboot `!insertmacro DeleteOnReboot`
;升级事件
!define EVENT_CHECK_UPDATE  0               ;检查更新
!define EVENT_CHECK_UPDATE_SUCCESS 1        ;检查更新成功
!define EVENT_INIT_LOG_SUCCESS 2			;初始化log成功
!define EVENT_UPDATE_EFFECTIVE 3			;升级有效
!define EVENT_UPDATE_NO_EFFECTIVE 4			;升级无效
!define EVENT_UPDATE_NEED 5					;需要更新
!define EVENT_UPDATE_NO_NEED 6				;不需要更新
!define EVENT_DOWNLOAD_FILELIST 7			;下载filelist.ini
!define EVENT_DOWNLOAD_FILELIST_SUCCESS 8	;下载filelist.ini成功
!define EVENT_COMPARE_FILES 9				;比对文件
!define EVENT_COMPARE_FILES_SUCCESS 10		;比对文件成功
!define EVENT_DOWNLOAD_FILES 11				;下载文件
!define EVENT_DOWNLOAD_FILES_SUCCESS 12	    ;下载文件成功
!define EVENT_UNZIP_FILES 13				;解压文件
!define EVENT_UNZIP_FILES_SUCCESS 14		;解压文件成功
!define EVENT_REPLACE_FILES 15				;替换文件
!define EVENT_REPLACE_FILES_SUCCESS 16		;替换文件成功
!define EVENT_NEED_REPLACE_SELF_FILE 17     ;替换自身
!define EVENT_UPDATE_SUCCESS 18				;升级成功
; >18 为出错部分
!define EVENT_CHECK_UPDATE_ERROR 19			;连接出错
!define EVENT_INIT_LOG_ERROR 20			    ;初始化log出错
!define EVENT_INIT_DIR_ERROR 21             ;初始化目录出错
!define EVENT_DOWNLOAD_FILELIST_ERROR 22	;下载filelist.ini出错
!define EVENT_COMPARE_FILES_ERROR 23		;比对文件出错
!define EVENT_DOWNLOAD_FILES_ERROR 24		;下载文件出错
!define EVENT_UNZIP_FILES_ERROR 25			;解压文件出错
!define EVENT_REPLACE_FILES_ERROR 26		;替换文件出错

;AutoUpdate 9 tab
!define STEP_CHECK_UPDATE 0                 ;检查更新等待页面
!define STEP_SHOW_UPDATE_INFO 1             ;显示更新内容页面
!define STEP_DOWNLOAD_FILES 2               ;开始下载升级文件页面
!define STEP_FILES_DOWNLOADED 3             ;更新文件下载完成页面
!define STEP_REPLACE_FILES 4                ;开始替换升级文件页面
!define STEP_UPDATE_SUCCESS 5               ;升级成功页面
!define STEP_NO_NEED 6                      ;无需更新已是最新页面
!define STEP_NET_ERROR 7                    ;网络连接错误页面
!define STEP_UPDATE_ERROR 8                 ;升级失败页面
!define STEP_REPLACE_FILES_ERROR 9          ;检查替换文件失败页面
!define STEP_UNZIP_FILES_ERROR 10           ;检查解压文件失败页面
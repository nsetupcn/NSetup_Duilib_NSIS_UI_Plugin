;nsUtils::NSISCreateMutex
!define HASRUN "1"

;nsUtils::CompareVersion "版本A" "版本B" "版本C"
!define RANGE_EQUAL_LARGE 2 ;"版本A" > "版本B" > "版本C"
!define RANGE_MIDDLE 1 ;"版本B" > "版本A" > "版本C"
!define RANGE_LOWER 0 ;"版本B" > "版本C" > "版本A"

;nsUtils::ExecShellAsUser
!define SHELL_EXEC_AS_USER_SUCCESS 0
!define SHELL_EXEC_AS_USER_FAILED 1
!define SHELL_EXEC_AS_USER_TIMEOUT 2
!define SHELL_EXEC_AS_USER_UNSUPPORTED 3
!define SHELL_EXEC_AS_USER_NOT_FOUND 4
!define SHELL_EXEC_AS_USER_FALLBACK 5
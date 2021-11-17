cd %~dp0
md list
if exist %~dp0list\listStep.txt (
del /q %~dp0list\listStep.txt
)
for /r "..\..\..\Temp\Output" %%i in (*.exe) do echo %%~fi>>%~dp0\list\listStep.txt

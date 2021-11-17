cd %~dp0
md list
if exist %~dp0list\list.txt (
del /q %~dp0list\list.txt
)
for /r "..\..\..\Temp\Temp" %%i in (*.exe *.dll *.cab *.ocx *.mui *.vbs *.msi) do echo %%~fi>>%~dp0\list\list.txt
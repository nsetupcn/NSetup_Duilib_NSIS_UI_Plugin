set "pfxfilesource=%~dp0tools\BuildShell\pfx\sha256.pfx"
set "pfxpasswd=rLrmRIUmTA#jJ6LGH"
set "signtoolPath=%~dp0tools\BuildShell\Tools\signtool.exe"
::if not exist %~dp0list\list.txt (
call %~dp0list.bat
::)
if exist %~dp0list\list.txt (
for /f "delims=" %%1 in (%~dp0list\list.txt) do "%signtoolPath%" sign /f "%pfxfilesource%" /p "%pfxpasswd%" /t "http://timestamp.VeriSign.com/scripts/timstamp.dll" "%%~1"
for /f "delims=" %%1 in (%~dp0list\list.txt) do "%signtoolPath%" sign /fd sha256 /as /f "%pfxfilesource%" /p "%pfxpasswd%" /tr http://timestamp.comodoca.com "%%~1"
)

@echo off
@REM This script finds the latest Debug build nupkg file for the given project and then publishes
set projectPath=%~dp0
set releaseFolder=%projectPath%\bin\Debug
@REM Finding latest nupkg

@echo:

FOR /F "eol=| delims=" %%I IN ('DIR "%releaseFolder%\*.nupkg" /A-D /B /O-D /TW 2^>nul') DO SET "NewestFile=%%I" & GOTO FoundFile
ECHO No *.nupkg file found
GOTO :EOF

:FoundFile
ECHO Latest *.nupkg file is:
ECHO %NewestFile%

nuget add "%releaseFolder%\%NewestFile%" -source "D:\users\SpawnDevPackages"
pause

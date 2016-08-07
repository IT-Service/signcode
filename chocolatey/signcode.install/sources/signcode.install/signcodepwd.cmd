REM @echo off
setlocal enableextensions enabledelayedexpansion
set SIGNCODEPWD=signcode-pwd.exe
set SIGNCODE=signcode.exe
set CODE_TIMESTAMP_URL=http://timestamp.verisign.com/scripts/timstamp.dll
set CODE_SIGNING_DLL=mssipotf.dll
set SIGNCODEPASSWORD=%CODE_SIGNING_CERTIFICATE_PASSWORD%

:parseargs
if "%~1"=="" goto endparseargs
if "%~1"=="-spc" (
  set CODE_SIGNING_CERTIFICATE_SPC=%~2
  shift
  shift
  goto parseargs
)
if "%~1"=="-v" (
  set CODE_SIGNING_CERTIFICATE_PVK=%~2
  shift
  shift
  goto parseargs
)
if "%~1"=="-t" (
  set CODE_TIMESTAMP_URL=%~2
  shift
  shift
  goto parseargs
)
if "%~1"=="-j" (
  set CODE_SIGNING_DLL=%~2
  shift
  shift
  goto parseargs
)
if "%~1"=="-p" (
  set SIGNCODEPASSWORD=%~2
  shift
  shift
  goto parseargs
)
set FILEFORSIGNING=%~1
shift
goto parseargs
:endparseargs

for %%A in ("%FILEFORSIGNING%") do set TMPFILE="%TMP%\%%~nxA"

copy /Y "%FILEFORSIGNING%" "%TMPFILE%"
"%SIGNCODEPWD%" -m %SIGNCODEPASSWORD%
set /a i=10
:signingloopbegin
  "%SIGNCODE%" ^
    -spc "%CODE_SIGNING_CERTIFICATE_SPC%" ^
    -v "%CODE_SIGNING_CERTIFICATE_PVK%" ^
    -j "%CODE_SIGNING_DLL%" ^
    "%FILEFORSIGNING%"
  set exitcode=%errorlevel%
  if %errorlevel%==0 goto :beforetimestamp
  copy /Y "%TMPFILE%" "%FILEFORSIGNING%"
  set /a i-=1
  if %i% gtr 0 goto :signingloopbegin
:signingloopend
goto :beforeexit

:beforetimestamp
copy /Y "%FILEFORSIGNING%" "%TMPFILE%"
set /a i=10
:timestamploopbegin
  "%SIGNCODE%" ^
    -x ^
    -t "%CODE_TIMESTAMP_URL%" ^
    "%FILEFORSIGNING%"
  set exitcode=%errorlevel%
  if %errorlevel%==0 goto :timestamploopend
  copy /Y "%TMPFILE%" "%FILEFORSIGNING%"
  set /a i-=1
  if %i% gtr 0 goto :timestamploopbegin
:timestamploopend

:beforeexit
"%SIGNCODEPWD%" -t
REM del /F /Q "%TMPFILE%"
exit /b %exitcode%

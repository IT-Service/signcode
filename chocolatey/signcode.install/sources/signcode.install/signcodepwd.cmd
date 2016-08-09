@echo off
setlocal enableextensions enabledelayedexpansion
set SIGNCODEPWD=signcode-pwd.exe
set SIGNCODE=signcode.exe
set CODE_TIMESTAMP_URL=http://timestamp.verisign.com/scripts/timstamp.dll
set CODE_SIGNING_DLL=mssipotf.dll
set SIGNCODEPASSWORD=%CODE_SIGNING_CERTIFICATE_PASSWORD%

:parseargs
if "%~1"=="" goto :endparseargs
if "%~1"=="-h" (
:help
  echo Parameters -spc, -v, -t, -j, -p and filename for signing expected.
  exit /b -1
)
if "%~1"=="/?" goto :help
if "%~1"=="-?" goto :help
if "%~1"=="-help" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-spc" (
  set CODE_SIGNING_CERTIFICATE_SPC=%~2
  shift
  shift
  goto :parseargs
)
if "%~1"=="-v" (
  set CODE_SIGNING_CERTIFICATE_PVK=%~2
  shift
  shift
  goto :parseargs
)
if "%~1"=="-t" (
  set CODE_TIMESTAMP_URL=%~2
  shift
  shift
  goto :parseargs
)
if "%~1"=="-j" (
  set CODE_SIGNING_DLL=%~2
  shift
  shift
  goto :parseargs
)
if "%~1"=="-p" (
  set SIGNCODEPASSWORD=%~2
  shift
  shift
  goto :parseargs
)
set FILEFORSIGNING=%~1
shift
goto :parseargs
:endparseargs

if "%CODE_SIGNING_CERTIFICATE_SPC%"=="" goto :help
if "%CODE_SIGNING_CERTIFICATE_PVK%"=="" goto :help
if "%CODE_TIMESTAMP_URL%"=="" goto :help
if "%CODE_SIGNING_DLL%"=="" goto :help
if "%SIGNCODEPASSWORD%"=="" goto :help
if "%FILEFORSIGNING%"=="" goto :help

for %%A in ("%FILEFORSIGNING%") do set TMPFILE="%TMP%\%%~nxA"

copy /Y "%FILEFORSIGNING%" "%TMPFILE%" 1>NUL
@REM echo on
"%SIGNCODEPWD%" -m %SIGNCODEPASSWORD%
@echo off
set /a i=30
:signingloopbegin
  @echo on
  "%SIGNCODE%" ^
    -spc "%CODE_SIGNING_CERTIFICATE_SPC%" ^
    -v "%CODE_SIGNING_CERTIFICATE_PVK%" ^
    -j "%CODE_SIGNING_DLL%" ^
    "%FILEFORSIGNING%"
  @set exitcode=%errorlevel%
  @echo off
  if %exitcode%==0 goto :beforetimestamp
  copy /Y "%TMPFILE%" "%FILEFORSIGNING%" 1>NUL
  set /a i-=1
  if %i% gtr 0 goto :signingloopbegin
:signingloopend
goto :beforeexit

:beforetimestamp
copy /Y "%FILEFORSIGNING%" "%TMPFILE%" 1>NUL
set /a i=30
:timestamploopbegin
  @echo on
  "%SIGNCODE%" ^
    -x ^
    -t "%CODE_TIMESTAMP_URL%" ^
    "%FILEFORSIGNING%"
  @set exitcode=%errorlevel%
  @echo off
  if %exitcode%==0 goto :timestamploopend
  copy /Y "%TMPFILE%" "%FILEFORSIGNING%" 1>NUL
  set /a i-=1
  if %i% gtr 0 goto :timestamploopbegin
:timestamploopend

:beforeexit
@REM echo on
"%SIGNCODEPWD%" -t
@REM @del /F /Q "%TMPFILE%"
@exit /b %exitcode%

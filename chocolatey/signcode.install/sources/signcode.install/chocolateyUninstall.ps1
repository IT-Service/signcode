$ErrorActionPreference = 'Stop';

$packageName = 'signcode.install';
$toolsDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition);

$exitCode = Start-ChocolateyProcessAsAdmin `
    -statements @"
        `$DsigDllInstallFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86);
        & `$DsigDllInstallFolder\regsvr32 /u /s mssipotf.dll | Out-String | Write-Verbose;
        Remove-Item -LiteralPath ( Join-Path -Path '$toolsDir' -ChildPath 'mssipotf.dll' ) -Force;
"@ `
    -noSleep `
;

Uninstall-BinFile `
    -name 'signcodepwd' `
    -path ( Join-Path -Path $toolsDir -ChildPath 'signcodepwd.cmd' ) `
;

$packageArgs = @{
  packageName   = $packageName;
  zipFileName   = 'Dsig.EXE';
}
#Uninstall-ChocolateyZipPackage @packageArgs;

$packageArgs.zipFileName = 'signcode-pwd_1_02.zip';
#Uninstall-ChocolateyZipPackage @packageArgs;

$ErrorActionPreference = 'Stop';

$packageName = 'signcode.install';
$toolsDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition);

$DSigUrl = 'http://download.microsoft.com/download/4/7/e/47e8e7fb-9441-4887-988f-e259a443052d/Dsig.EXE';
$signcodePwdUrl = 'http://www.stephan-brenner.com/downloads/signcode-pwd/signcode-pwd_1_02.zip';

$packageArgs = @{
  packageName   = $packageName;
  unzipLocation = $toolsDir;
  url           = $DSigUrl;
}
Install-ChocolateyZipPackage @packageArgs;

$packageArgs.url = $signcodePwdUrl;
Install-ChocolateyZipPackage @packageArgs;

## Main helper functions - these have error handling tucked into them already
## see https://github.com/chocolatey/choco/wiki/HelpersReference

# Runs processes asserting UAC, will assert administrative rights - used by Install-ChocolateyInstallPackage
#Start-ChocolateyProcessAsAdmin 'STATEMENTS_TO_RUN' 'Optional_Application_If_Not_PowerShell' -validExitCodes $validExitCodes

# add specific folders to the path - any executables found in the chocolatey package folder will already be on the path. This is used in addition to that or for cases when a native installer doesn't add things to the path.
#Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights

# outputs the bitness of the OS (either "32" or "64")
#$osBitness = Get-ProcessorBits

<#
switch ( $env:PROCESSOR_ARCHITECTURE ) {
    'amd64' { $ArchPath = 'x64'; }
    'x86'   { $ArchPath = 'x86'; }
    default { Write-Error 'Unsupported processor architecture.'}
};

Execute-ExternalInstaller `
    -LiteralPath $DsigFile `
    -ArgumentList "/Q /T:`"$DsigFolder`"" `
;
$DsigDllInstallFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86);
@( 'mssipotf.dll' ) `
| % { Get-Item -LiteralPath ( Join-Path -Path $DsigFolder -ChildPath $_ ) } `
| Copy-Item -Destination $DsigDllInstallFolder -Force `
;
& $DsigDllInstallFolder\regsvr32 /s mssipotf.dll `
| Out-String | Write-Verbose;
#>
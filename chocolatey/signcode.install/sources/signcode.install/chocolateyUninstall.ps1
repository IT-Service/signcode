$ErrorActionPreference = 'Stop';

$packageName = 'signcode.install';
$toolsDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition);

$packageArgs = @{
  packageName   = $packageName;
  zipFileName   = 'Dsig.EXE';
}
#Uninstall-ChocolateyZipPackage @packageArgs;

$packageArgs.zipFileName = 'signcode-pwd_1_02.zip';
#Uninstall-ChocolateyZipPackage @packageArgs;

<#
## OTHER HELPERS
## https://github.com/chocolatey/choco/wiki/HelpersReference
#Uninstall-BinFile # Only needed if you added one in the installer script, choco will remove the ones it added automatically.
#remove any shortcuts you added
#>
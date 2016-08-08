$ErrorActionPreference = 'Stop';

$packageName = 'signcode.install';
$toolsDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition);

$DSigUrl = 'http://download.microsoft.com/download/4/7/e/47e8e7fb-9441-4887-988f-e259a443052d/Dsig.EXE';
$signcodePwdUrl = 'http://www.stephan-brenner.com/downloads/signcode-pwd/signcode-pwd_1_02.zip';

$chocTempDir = $env:TEMP;
$tempDir = Join-Path -Path $chocTempDir -ChildPath $env:chocolateyPackageName;
if ( $env:chocolateyPackageVersion -ne $null ) {
    $tempDir = Join-Path -Path $tempDir -ChildPath $env:chocolateyPackageVersion;
};
if ( ![System.IO.Directory]::Exists($tempDir) ) { [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null; };
$filePath = Join-Path -Path $tempDir -ChildPath 'Dsig.zip';
  
$filePath = Get-ChocolateyWebFile `
    -packageName $packageName `
    -fileFullPath $filePath `
    -url $DSigUrl `
;
Get-ChocolateyUnzip `
    -packageName $packageName `
    -fileFullPath "$filePath" `
    -destination $toolsDir `
;

Install-ChocolateyZipPackage `
    -packageName $packageName `
    -unzipLocation $toolsDir `
    -url $signcodePwdUrl `
;

$exitCode = Start-ChocolateyProcessAsAdmin `
    -statements @"
        `$DsigDllInstallFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86);
        Copy-Item -LiteralPath ( Join-Path -Path '$toolsDir' -ChildPath 'mssipotf.dll' ) -Destination `$DsigDllInstallFolder -Force;
        & `$DsigDllInstallFolder\regsvr32 /s mssipotf.dll | Out-String | Write-Verbose;
"@ `
    -noSleep `
;

Install-BinFile `
    -name 'signcodepwd' `
    -path ( Join-Path -Path $toolsDir -ChildPath 'signcodepwd.cmd' ) `
;

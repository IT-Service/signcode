$ErrorActionPreference = 'Stop';
$fileHashAlgorithm = 'md5';

$packageName = 'signcode.install';
$toolsDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition);

$DSigUrl = 'http://download.microsoft.com/download/4/7/e/47e8e7fb-9441-4887-988f-e259a443052d/Dsig.EXE';
$signcodePwdUrl = 'http://www.stephan-brenner.com/downloads/signcode-pwd/signcode-pwd_1_02.zip';

$dsigMetadata = ( Select-Xml `
    -LiteralPath ( Join-Path -Path $toolsDir -ChildPath 'dsig.externalfile.xml' ) `
    -XPath '/package/files/file[@fileid="dsig"]'
).Node;
Install-ChocolateyPackage `
    -packageName 'DSig' `
    -url ( $dsigMetadata.url ) `
    -silentArgs "/Q /T:`"$toolsDir`"" `
    -checksum ( Get-Content -LiteralPath ( Join-Path -Path $toolsDir -ChildPath "dsig.$fileHashAlgorithm.checksum.txt" ) ) `
    -checksumType $fileHashAlgorithm `
;

$signcodepwdMetadata = ( Select-Xml `
    -LiteralPath ( Join-Path -Path $toolsDir -ChildPath 'signcodepwd.externalfile.xml' ) `
    -XPath '/package/files/file[@fileid="signcodepwd"]'
).Node;
Install-ChocolateyZipPackage `
    -packageName 'signcode-pwd' `
    -unzipLocation $toolsDir `
    -url ( $signcodepwdMetadata.url ) `
    -checksum ( Get-Content -LiteralPath ( Join-Path -Path $toolsDir -ChildPath "signcodepwd.$fileHashAlgorithm.checksum.txt" ) ) `
    -checksumType $fileHashAlgorithm `
;

$exitCode = Start-ChocolateyProcessAsAdmin `
    -statements @"
        `$DsigDllInstallFolder = [Environment]::GetFolderPath([Environment+SpecialFolder]::SystemX86);
        Copy-Item -LiteralPath ( Join-Path -Path '$toolsDir' -ChildPath 'mssipotf.dll' ) -Destination `$DsigDllInstallFolder -Force;
        & `$DsigDllInstallFolder\regsvr32 /s mssipotf.dll | Out-String | Write-Verbose;
"@ `
    -noSleep `
;

#Install-BinFile
Generate-BinFile `
    -name 'signcodepwd' `
    -path ( Join-Path -Path $toolsDir -ChildPath 'signcodepwd.cmd' ) `
;

﻿<# 
.Synopsis 
    Скрипт подготовки среды сборки и тестирования проекта
.Description 
    Скрипт подготовки среды сборки и тестирования проекта.
    Используется в том числе и для подготовки среды на серверах appveyor.
.Link 
    https://github.com/IT-Service/signcode
.Example 
    .\install.ps1 -GUI;
    Устанавливаем необходимые пакеты, в том числе - и графические среды.
#> 
[CmdletBinding(
    SupportsShouldProcess = $true
    , ConfirmImpact = 'Medium'
    , HelpUri = 'https://github.com/IT-Service/signcode'
)]
 
param (
    # Ключ, определяющий необходимость установки визуальных средств.
    # По умолчанию устанавливаются только средства для командной строки.
    [Switch]
    $GUI
) 

Function Execute-ExternalInstaller {
    [CmdletBinding(
        SupportsShouldProcess = $true
        , ConfirmImpact = 'Medium'
    )]
    param (
        [String]
        $LiteralPath
        ,
        [String]
        $ArgumentList
    )

    $pinfo = [System.Diagnostics.ProcessStartInfo]::new();
    $pinfo.FileName = $LiteralPath;
    $pinfo.RedirectStandardError = $true;
    $pinfo.RedirectStandardOutput = $true;
    $pinfo.UseShellExecute = $false;
    $pinfo.Arguments = $ArgumentList;
    $p = [System.Diagnostics.Process]::new();
    try {
        $p.StartInfo = $pinfo;
        $p.Start() | Out-Null;
        $p.WaitForExit();
        $LASTEXITCODE = $p.ExitCode;
        $p.StandardOutput.ReadToEnd() `
        | Write-Verbose `
        ;
        if ( $p.ExitCode -ne 0 ) {
            $p.StandardError.ReadToEnd() `
            | Write-Error `
            ;
        };
    } finally {
        $p.Close();
    };
}

switch ( $env:PROCESSOR_ARCHITECTURE ) {
    'amd64' { $ArchPath = 'x64'; }
    'x86'   { $ArchPath = 'x86'; }
    default { Write-Error 'Unsupported processor architecture.'}
};
$ToPath = @();

Import-Module -Name PackageManagement;

$null = Install-PackageProvider -Name NuGet -Force;
$null = Import-PackageProvider -Name NuGet -Force;
$null = (
    Get-PackageSource -ProviderName NuGet `
    | Set-PackageSource -Trusted `
);
$null = Install-PackageProvider -Name Chocolatey -Force;
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = (
    Get-PackageSource -ProviderName Chocolatey `
    | Set-PackageSource -Trusted `
);
if ( -not ( $env:APPVEYOR -eq 'True' ) ) {
    $null = Install-Package -Name chocolatey -MinimumVersion 0.9.10.3 -ProviderName Chocolatey;
};
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = (
    Get-PackageSource -ProviderName Chocolatey `
    | Set-PackageSource -Trusted `
);

& choco install GitVersion.Portable --confirm --failonstderr | Out-String -Stream | Write-Verbose;
& choco install GitReleaseNotes.Portable --confirm --failonstderr | Out-String -Stream | Write-Verbose;

if ( -not ( $env:APPVEYOR -eq 'True' ) ) {

    & choco install git --confirm --failonstderr | Out-String -Stream | Write-Verbose;

};

& choco install checksum --confirm --failonstderr | Out-String -Stream | Write-Verbose;

& choco install cygwin --confirm --failonstderr | Out-String -Stream | Write-Verbose;
$env:CygWin = Get-ItemPropertyValue `
    -Path HKLM:\SOFTWARE\Cygwin\setup `
    -Name rootdir `
;
Write-Verbose "CygWin root directory: $env:CygWin";
# исправляем проблемы совместимости chocolatey, cyg-get и cygwin
If ( Test-Path "$env:CygWin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:CygWin\cygwinsetup.exe";
} ElseIf ( Test-Path "$env:CygWin\setup-x86_64.exe" ) {
    $cygwinsetup = "$env:CygWin\setup-x86_64.exe";
} ElseIf ( Test-Path "$env:CygWin\setup-x86.exe" ) {
    $cygwinsetup = "$env:CygWin\setup-x86.exe";
} ElseIf ( Test-Path "$env:ChocolateyPath\lib\Cygwin\tools\cygwin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:ChocolateyPath\lib\Cygwin\tools\cygwin\cygwinsetup.exe";
} ElseIf ( Test-Path "$env:ChocolateyPath\lib\Cygwin.$(( Get-Package -Name CygWin -ProviderName Chocolatey ).Version)\tools\cygwin\cygwinsetup.exe" ) {
    $cygwinsetup = "$env:ChocolateyPath\lib\Cygwin.$(( Get-Package -Name CygWin -ProviderName Chocolatey ).Version)\tools\cygwin\cygwinsetup.exe";
} Else {
    Write-Error 'I can not find CygWin setup!';
};
Write-Verbose "CygWin setup: $cygwinsetup";
if ($PSCmdLet.ShouldProcess('CygWin', 'Установить переменную окружения')) {
    [System.Environment]::SetEnvironmentVariable( 'CygWin', $env:CygWin, [System.EnvironmentVariableTarget]::Machine );
};
$ToPath += "$env:CygWin\bin";

Write-Verbose 'Install CygWin tools...';
if ($PSCmdLet.ShouldProcess('make, mkdir, touch, zip', 'Установить пакет CygWin')) {
    Execute-ExternalInstaller `
        -LiteralPath $cygwinsetup `
        -ArgumentList '--packages make,mkdir,touch,zip,ttfautohint --quiet-mode --no-desktop --no-startmenu --site http://mirrors.kernel.org/sourceware/cygwin/' `
    ;
};

if ( $GUI ) {
    $null = Install-Package -Name SourceTree -ProviderName Chocolatey;
    $null = Install-Package -Name notepadplusplus -ProviderName Chocolatey;
};

Write-Verbose 'Preparing PATH environment variable...';
if ($PSCmdLet.ShouldProcess('PATH', 'Установить переменную окружения')) {
    $Path = `
        ( `
            ( $env:Path -split ';' ) `
            + $ToPath `
            | Sort-Object -Unique `
        ) `
    ;
    Write-Verbose 'Path variable:';
    $Path | % { Write-Verbose "    $_" };
    $env:Path = $Path -join ';';
    [System.Environment]::SetEnvironmentVariable( 'PATH', $env:Path, [System.EnvironmentVariableTarget]::User );
};

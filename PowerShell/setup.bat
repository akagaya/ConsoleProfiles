<# :
@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:BAT_DIR='%~dp0'; Invoke-Expression $([System.IO.File]::ReadAllText('%~f0'))"
pause
goto :EOF
#>

$psDir = $env:BAT_DIR.TrimEnd('\')
$repoProfile = Join-Path $psDir "Microsoft.PowerShell_profile.ps1"

$docPath = [Environment]::GetFolderPath('MyDocuments')
$ps5Profile = Join-Path $docPath "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$ps7Profile = Join-Path $docPath "PowerShell\Microsoft.PowerShell_profile.ps1"

function Set-Profile {
    param($Path, $Target)
    $dir = Split-Path $Path
    if (-not (Test-Path $dir)) { 
        New-Item -ItemType Directory -Path $dir | Out-Null 
    }
    
    $content = ". `"$Target`""
    Set-Content -Path $Path -Value $content -Encoding UTF8
    Write-Host "プロファイルを設定しました: $Path"
}

Write-Host "PowerShell プロファイルのセットアップを開始します..."
Set-Profile -Path $ps5Profile -Target $repoProfile
Set-Profile -Path $ps7Profile -Target $repoProfile
Write-Host "すべての処理が完了しました。"

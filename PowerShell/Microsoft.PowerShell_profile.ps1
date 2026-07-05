# scripts フォルダ内のすべての .ps1 ファイルをまとめて読み込む
$scriptsDir = Join-Path $PSScriptRoot "scripts"
if (Test-Path $scriptsDir) {
    Get-ChildItem -Path $scriptsDir -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

function Get-PSVersion {
    param (
        [Boolean]$Full = $false
    )
    $version = ""
    if ($Full) {
        $version = $PSVersionTable.PSVersion.ToString()
    } else {
        $version = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
    }
    return $version
}

$global:LastHistoryId = 0

function Prompt {
    # カレントディレクトリのパスを取得
    $currentPath = Get-Location

    # ブランチ名を取得
    $branch = Get-GitBranch

    # 直前コマンドの実行時間を取得
    $lastCmd = Get-History -Count 1
    $durationStr = ""
    if ($lastCmd -and $lastCmd.Id -ne $global:LastHistoryId) {
        $global:LastHistoryId = $lastCmd.Id
        $duration = $lastCmd.EndExecutionTime - $lastCmd.StartExecutionTime
        if ($duration.TotalSeconds -ge 1) {
            $durationStr = " [{0:N2}s]" -f $duration.TotalSeconds
        }
    }

    Write-Host "$($currentPath)" -ForegroundColor Blue -NoNewline
    if ($durationStr) {
        Write-Host $durationStr -ForegroundColor Yellow
    } else {
        Write-Host ""
    }

    if($branch){
        Write-Host "$([char]0xE0A0)" -NoNewline
        if (Test-GitDirty) {
            Write-Host "*" -NoNewline -ForegroundColor Red
        }
        Write-Host "[" -NoNewline
        Write-Host $branch -NoNewline -ForegroundColor Cyan
        Write-Host "] " -NoNewline
    }

    return "PS$(Get-PSVersion) > "
}

# エイリアス

Set-Alias vim nvim

function dc(){
    docker compose $args
}


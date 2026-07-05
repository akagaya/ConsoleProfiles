function Get-GitBranch {
    try {
        # 現在のブランチ名を取得
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) {
            return $branch.Trim()
        }
    } catch {
        # Gitコマンドが失敗した場合、空文字列を返す
        return ""
    }
}

function Test-GitDirty {
    try {
        # 変更（未コミット）があるか確認（高速化のため未追跡ファイルは除外）
        $status = git status --porcelain -uno 2>$null
        return [bool]$status
    } catch {
        return $false
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

Set-Alias vim nvim

function dc(){
    docker compose $args
}

function sudo {
    param (
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [String[]]$Command
    )
    if ($Command.Length -eq 1) {
        Start-Process -FilePath $Command[0] -Verb RunAs -Wait
    } else {
        $argsList = $Command[1..($Command.Length - 1)] -join ' '
        Start-Process -FilePath $Command[0] -ArgumentList $argsList -Verb RunAs -Wait
    }
}

$global:Bookmarks = @{
    "work" = "C:\Git"
    "profile" = "C:\Git\ConsoleProfiles"
}
function g {
    param([string]$name)
    if ($global:Bookmarks.ContainsKey($name)) {
        Set-Location $global:Bookmarks[$name]
    } else {
        Write-Host "Bookmark '$name' not found." -ForegroundColor Red
        Write-Host "Available bookmarks:"
        $global:Bookmarks.Keys | ForEach-Object { Write-Host "  $_ -> $($global:Bookmarks[$_])" }
    }
}

function google {
    $query = $args -join " "
    if ($query) {
        Start-Process "https://www.google.com/search?q=$([uri]::EscapeDataString($query))"
    }
}

function git-clean-branches {
    git branch --merged | Where-Object { $_ -notmatch '^\*|^\s*(main|master|develop)\s*$' } | ForEach-Object { git branch -d $_.Trim() }
}

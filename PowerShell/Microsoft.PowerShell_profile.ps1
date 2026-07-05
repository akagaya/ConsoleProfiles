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

function Prompt {
    # カレントディレクトリのパスを取得
    $currentPath = Get-Location

    # ブランチ名を取得
    $branch = Get-GitBranch

    Write-Host "$($currentPath)" -ForegroundColor Blue

    if($branch){
        Write-Host "$([char]0xE0A0)[" -NoNewline
        Write-Host $branch -NoNewline -ForegroundColor Cyan
        Write-Host "] " -NoNewline
    }

    return "PS$(Get-PSVersion) > "
}

Set-Alias vim nvim

function dc(){
    docker compose $args
}

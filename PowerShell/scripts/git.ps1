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

function git-clean-branches {
    git branch --merged | Where-Object { $_ -notmatch '^\*|^\s*(main|master|develop)\s*$' } | ForEach-Object { git branch -d $_.Trim() }
}

function g {
    param(
        [Parameter(Position=0)]
        [string]$Name,
        
        [Parameter(Position=1)]
        [string]$Path,

        [switch]$Add,
        [switch]$Delete,
        [switch]$List
    )

    $docPath = [System.Environment]::GetFolderPath('MyDocuments')
    $bookmarksDir = Join-Path $docPath "PowerShell"
    $bookmarksFile = Join-Path $bookmarksDir "bookmarks.json"

    # JSONから読み込むヘルパー
    function Get-Bookmarks {
        if (Test-Path $bookmarksFile) {
            try {
                $content = Get-Content $bookmarksFile -Raw -ErrorAction SilentlyContinue
                if ($content) {
                    return ConvertFrom-Json $content
                }
            } catch {
                # JSONパース失敗時はデフォルト値にフォールバック
            }
        }
        return [PSCustomObject]@{
            "work" = "C:\Git"
            "profile" = "C:\Git\ConsoleProfiles"
        }
    }

    # JSONへ書き込むヘルパー
    function Save-Bookmarks($bookmarks) {
        if (-not (Test-Path $bookmarksDir)) {
            New-Item -ItemType Directory -Path $bookmarksDir -Force | Out-Null
        }
        $bookmarks | ConvertTo-Json | Set-Content $bookmarksFile -Encoding UTF8
    }

    $bookmarks = Get-Bookmarks

    if ($Add) {
        if (-not $Name) {
            Write-Host "Error: Name required to add a bookmark." -ForegroundColor Red
            return
        }
        $targetPath = if ($Path) { Resolve-Path $Path } else { Get-Location }
        $targetPathStr = $targetPath.ToString()

        if (-not (Test-Path $targetPathStr)) {
            Write-Host "Error: Path '$targetPathStr' does not exist." -ForegroundColor Red
            return
        }

        $bookmarks | Add-Member -MemberType NoteProperty -Name $Name -Value $targetPathStr -Force
        Save-Bookmarks $bookmarks
        Write-Host "Added bookmark: $Name -> $targetPathStr" -ForegroundColor Green
        return
    }

    if ($Delete) {
        if (-not $Name) {
            Write-Host "Error: Name required to delete a bookmark." -ForegroundColor Red
            return
        }
        if ($bookmarks.psobject.properties[$Name]) {
            $bookmarks.psobject.properties.Remove($Name)
            Save-Bookmarks $bookmarks
            Write-Host "Deleted bookmark: $Name" -ForegroundColor Green
        } else {
            Write-Host "Bookmark '$Name' not found." -ForegroundColor Yellow
        }
        return
    }

    if ($List -or -not $Name) {
        Write-Host "Available bookmarks:"
        $bookmarks.psobject.properties | ForEach-Object {
            Write-Host "  $($_.Name) -> $($_.Value)"
        }
        return
    }

    # 移動処理
    if ($bookmarks.psobject.properties[$Name]) {
        Set-Location $bookmarks.psobject.properties[$Name].Value
    } else {
        Write-Host "Bookmark '$Name' not found." -ForegroundColor Red
        Write-Host "Use 'g -add <name> [path]' to add a bookmark."
    }
}

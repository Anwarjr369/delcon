# Auto-Push-Daemon.ps1 — Background File Watcher for Real-Time GitHub Sync
param (
    [int]$DebounceSeconds = 10
)

$gitExe = "C:\Users\ASUS\AppData\Local\github-copilot-git-2.53.0-4\cmd\git.exe"
if (-not (Test-Path $gitExe)) {
    $whereGit = (Get-Command git -ErrorAction SilentlyContinue).Source
    if ($whereGit) { $gitExe = $whereGit } else { Write-Error "Git not found!"; exit 1 }
}

$siteDir = $PSScriptRoot
Write-Host ">>> Delcon Real-Time GitHub Auto-Push Watcher active." -ForegroundColor Cyan
Write-Host ">>> Monitoring folder: $siteDir" -ForegroundColor Cyan
Write-Host ">>> Any code edits or new files will be pushed automatically." -ForegroundColor Green
Write-Host ">>> Press Ctrl+C to terminate auto-push daemon." -ForegroundColor Yellow

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $siteDir
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.Filter = "*.*"

$lastTrigger = [DateTime]::MinValue

while ($true) {
    Start-Sleep -Seconds 5
    # Check git status for modifications or untracked files
    $status = & $gitExe status --porcelain
    if ($status) {
        $now = [DateTime]::Now
        Write-Host "[$($now.ToString('HH:mm:ss'))] Detected local file changes / additions:" -ForegroundColor Yellow
        $status | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }

        Write-Host "[$($now.ToString('HH:mm:ss'))] Auto-staging, committing and pushing to GitHub..." -ForegroundColor Cyan
        & $gitExe add -A
        $commitMsg = "Auto-push update: $($now.ToString('yyyy-MM-dd HH:mm:ss'))"
        & $gitExe commit -m $commitMsg
        
        $remotes = & $gitExe remote
        if ($remotes -contains "origin") {
            & $gitExe push origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$($now.ToString('HH:mm:ss'))] >>> Successfully pushed to GitHub!" -ForegroundColor Green
            } else {
                Write-Host "[$($now.ToString('HH:mm:ss'))] >>> Push failed (check internet or GitHub access)." -ForegroundColor Red
            }
        } else {
            Write-Host "[$($now.ToString('HH:mm:ss'))] Remote 'origin' not linked yet." -ForegroundColor Yellow
        }
    }
}

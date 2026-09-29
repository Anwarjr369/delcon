# Sync-GitHub.ps1 — Delcon Platform Automated GitHub Pusher
param (
    [string]$Message = ""
)

$gitExe = "C:\Users\ASUS\AppData\Local\github-copilot-git-2.53.0-4\cmd\git.exe"
if (-not (Test-Path $gitExe)) {
    $whereGit = (Get-Command git -ErrorAction SilentlyContinue).Source
    if ($whereGit) { $gitExe = $whereGit } else { Write-Error "Git not found!"; exit 1 }
}

if ([string]::IsNullOrWhiteSpace($Message)) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $Message = "Update Delcon platform code: $timestamp"
}

Write-Host ">>> Checking Git status..." -ForegroundColor Cyan
& $gitExe status --short

Write-Host ">>> Staging all changed and new files..." -ForegroundColor Cyan
& $gitExe add -A

# Check if there are changes to commit
$changes = & $gitExe status --porcelain
if ($changes) {
    Write-Host ">>> Committing changes: '$Message'..." -ForegroundColor Green
    & $gitExe commit -m $Message
} else {
    Write-Host ">>> No new changes to commit." -ForegroundColor Yellow
}

# Check if remote origin exists
$remotes = & $gitExe remote
if ($remotes -contains "origin") {
    Write-Host ">>> Pushing to GitHub (origin main)..." -ForegroundColor Green
    & $gitExe push -u origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host ">>> Successfully pushed to GitHub!" -ForegroundColor Green
    } else {
        Write-Host ">>> Push failed. Please check your credentials or network." -ForegroundColor Red
    }
} else {
    Write-Host ">>> Remote 'origin' is not configured yet. Link your GitHub repo first." -ForegroundColor Yellow
}

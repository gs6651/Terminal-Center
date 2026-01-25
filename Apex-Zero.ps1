<#
.SYNOPSIS
    Ignite.ps1: The Ultimate Windows 11 Clean-Slate Script.
    Updated: Includes Tool Installs, Path Refresh, Ad-Killer, and Auto-Cloning.
#>

# 1. ELEVATION CHECK 🛡️
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: Please run this script as Administrator!" -ForegroundColor Red
    return
}

Write-Host "🚀 Ignite: Leveling up Windows to Apex status..." -ForegroundColor Cyan

# 2. INSTALL MODERN TOOLS 📦
Write-Host "📦 Installing PowerShell 7, Git, and Starship..." -ForegroundColor Yellow
winget install --id Microsoft.PowerShell -e --source winget --accept-package-agreements --accept-source-agreements
winget install --id Git.Git -e --source winget --accept-package-agreements --override "/NoGui /NoShellIntegration /NoGitLfs /NoCredentialManager"
winget install --id Starship.Starship -e --source winget --accept-package-agreements

# 3. REFRESH ENVIRONMENT PATH 🔄
Write-Host "🔄 Refreshing Environment Paths..." -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 4. PRIVACY & AD-KILLER 🍳
Write-Host "🛡️  Killing tracking and ads..." -ForegroundColor Yellow
# Advertising ID
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
# Tailored Experiences (Ads in Settings)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f
# Start Menu 'Recommendations'
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f
# File Explorer 'Sync Provider' Ads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncConfirmation" /t REG_DWORD /d 0 /f

# 5. UI & SEARCH CLEANUP 🔍
Write-Host "🧹 Cleaning up UI and Search..." -ForegroundColor Blue
# Disable Bing Search in Start Menu
if (!(Test-Path "HKCU\Software\Policies\Microsoft\Windows\Explorer")) {
    New-Item -Path "HKCU\Software\Policies\Microsoft\Windows" -Name "Explorer" -Force
}
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f
# Hide Search Highlights (Daily icons)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsDynamicSearchBoxEnabled" /t REG_DWORD /d 0 /f
# Remove Widgets/Weather from Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f

# 6. SYSTEM OPTIMIZATION ⚡
Write-Host "⚙️  Optimizing System Settings..." -ForegroundColor Cyan
# Set Execution Policy for scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# Disable 'Tips and Suggestions'
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f
# Stop PowerShell 5.1 update nags
[Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK", "Off", "User")
# Hide 'Recent Files' from Quick Access
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f

# 7. DIRECTORY & REPO SETUP 📂
Write-Host "📂 Setting up GitLocal and Cloning Repos..." -ForegroundColor Gray
$gitPath = "$Home\Documents\GitLocal"
if (!(Test-Path $gitPath)) { New-Item -ItemType Directory -Force -Path $gitPath }

# Move to directory and clone all 5 repos
Set-Location $gitPath
$repos = @(
    "git@github.com:gs6651/gs6651.git",
    "git@github.com:gs6651/Terminal-Center.git",
    "git@github.com:gs6651/The-Inkwell.git",
    "git@github.com:gs6651/Six-String-Sanctuary.git",
    "git@github.com:gs6651/Packet-Foundry.git"
)

foreach ($repo in $repos) {
    Write-Host "📥 Cloning $repo..." -ForegroundColor DarkGray
    git clone --depth 1 $repo
}

# 8. THE FINISHER ✨
Write-Host "`n✨ Ignite setup complete!" -ForegroundColor Green
Write-Host "🔄 Restarting Windows Explorer..." -ForegroundColor Magenta
Stop-Process -Name explorer -Force; Start-Sleep -Seconds 2; Start-Process explorer

Write-Host "✅ Done! Switch to the black 'PowerShell' icon in Terminal to start." -ForegroundColor Green
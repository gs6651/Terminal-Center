<#
.SYNOPSIS
    Apex-Zero: The Ultimate Windows 11 Clean-Slate Script.
    Author: Gaurav (with Gemini)
    Description: Removes ads, disables tracking, cleans search, and optimizes for Dev work.
#>

Write-Host "🚀 Initializing Apex-Zero..." -ForegroundColor Cyan

# ---------------------------------------------------------
# 1. ELEVATION CHECK
# ---------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: Please run this script as Administrator!" -ForegroundColor Red
    return
}

# ---------------------------------------------------------
# 2. PRIVACY & AD-KILLER (The "Egg" Destroyer) 🍳
# ---------------------------------------------------------
Write-Host "🛡️  Killing tracking and ads..." -ForegroundColor Yellow

# Disable Advertising ID
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f

# Disable 'Tailored Experiences' (Microsoft's name for ads)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f

# Disable Start Menu 'Recommendations' (Promoted Apps)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f

# Disable Sync Provider Notifications (OneDrive ads in File Explorer)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncConfirmation" /t REG_DWORD /d 0 /f

# ---------------------------------------------------------
# 3. UI & SEARCH CLEANUP (Bing-Free Zones) 🔍
# ---------------------------------------------------------
Write-Host "🧹 Cleaning up UI and Search..." -ForegroundColor Blue

# Disable Bing Search in Start Menu
if (!(Test-Path "HKCU\Software\Policies\Microsoft\Windows\Explorer")) {
    New-Item -Path "HKCU\Software\Policies\Microsoft\Windows" -Name "Explorer" -Force
}
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f

# Hide Search Highlights (The daily icons in search bar)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsDynamicSearchBoxEnabled" /t REG_DWORD /d 0 /f

# Remove 'Weather' and widgets from Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f

# ---------------------------------------------------------
# 4. SYSTEM OPTIMIZATION ⚡
# ---------------------------------------------------------
Write-Host "⚙️  Optimizing System Settings..." -ForegroundColor Cyan

# Set Execution Policy to allow your gitsync script
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Disable 'Tips and Suggestions' notifications
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f

# Hide 'Recent Files' from Quick Access to keep your activity private
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f

# ---------------------------------------------------------
# 5. THE FINISHER
# ---------------------------------------------------------
Write-Host "`n✨ Apex-Zero setup complete!" -ForegroundColor Green
Write-Host "🔄 Restarting Windows Explorer to apply changes..." -ForegroundColor Magenta

Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2
Start-Process explorer

Write-Host "✅ System is now clean, private, and optimized. Enjoy!" -ForegroundColor Green
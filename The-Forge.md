# ⚒️ The Forge: Ultimate System Master Guide

This document is the "Single Source of Truth" for rebuilding your Windows and Linux environments. It contains all scripts, configuration files, and step-by-step instructions.

## 🟦 SECTION 1: WINDOWS 11 "APEX-ZERO" SETUP
1.1 Initial Manual Tweaks

Before running scripts, handle these localization and UI settings that require manual confirmation.

    Fix 12H Format on Lock Screen:

        Settings > Time & language > Language & region.

        Administrative language settings > Administrative tab > Copy settings...

        Check: "Welcome screen and system accounts". Restart.

    Remove Weather/News from Lock Screen:

        Settings > Personalization > Lock screen.

        Change "Lock screen status" to None.

    Manual Registry Disable (Bing Search):

        regedit -> HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer.

        Create DWORD (32-bit) DisableSearchBoxSuggestions, set to 1.

1.2 The "Apex-Zero.ps1" Master Script

Save Path: C:\Users\Gaurav\Documents\GitLocal\Terminal-Center\Apex-Zero.ps1 Instructions: Run in PowerShell as Administrator.
PowerShell

<#
.SYNOPSIS
    Apex-Zero.ps1: The Ultimate Windows 11 Clean-Slate Script.
    Installs tools, cleans UI, kills ads, and sets up Git environment.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: Run as Administrator!" -ForegroundColor Red; return
}

Write-Host "🚀 Initializing Apex-Zero..." -ForegroundColor Cyan

# 1. TOOL INSTALLATION
Write-Host "📦 Installing PWSH 7, Git, and Starship..." -ForegroundColor Yellow
winget install --id Microsoft.PowerShell -e --source winget --accept-package-agreements --accept-source-agreements
winget install --id Git.Git -e --source winget --accept-package-agreements --override "/NoGui /NoShellIntegration /NoGitLfs /NoCredentialManager"
winget install --id Starship.Starship -e --source winget --accept-package-agreements

# Refresh Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 2. PRIVACY & AD-KILLER
Write-Host "🛡️  Killing tracking and ads..." -ForegroundColor Yellow
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncConfirmation" /t REG_DWORD /d 0 /f

# 3. UI & SEARCH CLEANUP
Write-Host "🧹 Cleaning up UI and Search..." -ForegroundColor Blue
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v "IsDynamicSearchBoxEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f

# 4. SYSTEM OPTIMIZATION
Write-Host "⚙️  Optimizing..." -ForegroundColor Cyan
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f
[Environment]::SetEnvironmentVariable("POWERSHELL_UPDATECHECK", "Off", "User")
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d 0 /f

# 5. REPO SETUP
$gitPath = "$Home\Documents\GitLocal"
if (!(Test-Path $gitPath)) { New-Item -ItemType Directory -Force -Path $gitPath }
Set-Location $gitPath
$repos = @("gs6651", "Terminal-Center", "The-Inkwell", "Six-String-Sanctuary", "Packet-Foundry")
foreach ($r in $repos) { git clone --depth 1 git@github.com:gs6651/$r.git }

Stop-Process -Name explorer -Force; Start-Sleep -2; Start-Process explorer
Write-Host "✅ Apex-Zero Complete!" -ForegroundColor Green

1.3 PowerShell 7 Profile Configuration

Save Path: C:\Users\Gaurav\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 Instructions: Type code $PROFILE in PowerShell 7 and paste the following.
PowerShell

# SSH Agent Auto-Start
if ((Get-Service | Where-Object {$_.Name -eq "ssh-agent"}).Status -ne "Running") { Start-Service ssh-agent }
ssh-add "$HOME\.ssh\id_ed25519" 2>$null

# Master GitSync Function
function gitsync {
    $BaseDir = "$Home\Documents\GitLocal"
    $Repos = if ($args[0]) { $args[0] } else { @("Packet-Foundry", "Terminal-Center", "Six-String-Sanctuary", "The-Inkwell", "gs6651") }
    Write-Host "🔄 Starting Global Sync..." -ForegroundColor Cyan
    foreach ($Repo in $Repos) {
        $Target = Join-Path $BaseDir $Repo
        if (Test-Path $Target) {
            Write-Host "`n📁 Processing: $Repo" -ForegroundColor Yellow
            Push-Location $Target
            if ($Repo -eq "The-Inkwell" -and (Test-Path ".assets\update_stats.sh")) {
                & "C:\Program Files\Git\bin\sh.exe" ./.assets/update_stats.sh
            }
            git add .
            $StashOut = git stash push -m "sync-stash"
            if (git pull origin main --rebase) {
                if ($StashOut -notmatch "No local changes to save") { git stash pop --quiet }
                if (git status --porcelain) {
                    git add .
                    git commit -m "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                    git push origin main
                }
            }
            Pop-Location
        }
    }
    Write-Host "✅ Sync Complete!" -ForegroundColor Green
}

# Start Starship
Invoke-Expression (&starship init powershell)

## 🟧 SECTION 2: LINUX (UBUNTU/FEDORA) SETUP
2.1 System De-Bloat & Hardening

    De-Snap Ubuntu:
    Bash

    snap list | awk '{if(NR>1) print $1}' | xargs -I{} sudo snap remove --purge {}
    sudo apt purge snapd -y
    # Prevent re-install (Apt Pinning)
    sudo nano /etc/apt/preferences.d/nosnap.pref
    # Paste:
    # Package: snapd
    # Pin: release a=*
    # Pin-Priority: -10

    Firefox (Mozilla PPA):
    Bash

    sudo add-apt-repository ppa:mozillateam/ppa
    # Pin the PPA to avoid the Snap-wrapper
    echo 'Package: firefox*' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    echo 'Pin: release o=LP-PPA-mozillateam' | sudo tee -a /etc/apt/preferences.d/mozilla-firefox
    echo 'Pin-Priority: 1001' | sudo tee -a /etc/apt/preferences.d/mozilla-firefox
    sudo apt update && sudo apt install firefox

2.2 Bash GitSync Automation

Save Path: ~/.local/bin/gitsync (Make executable: chmod +x gitsync)
Bash

#!/bin/bash
BASE_DIR="$HOME/Documents/GitLocal"
REPOS=("Packet-Foundry" "Terminal-Center" "Six-String-Sanctuary" "The-Inkwell" "gs6651")

for REPO in "${REPOS[@]}"; do
    TARGET="$BASE_DIR/$REPO"
    if [ -d "$TARGET" ]; then
        echo -e "\033[1;33m📁 Processing: $REPO\033[0m"
        cd "$TARGET"
        if [ "$REPO" == "The-Inkwell" ] && [ -f ".assets/update_stats.sh" ]; then
            bash "./.assets/update_stats.sh"
        fi
        git add .
        STASH_OUT=$(git stash push -m "sync-stash")
        if git pull origin main --rebase; then
            [ "$STASH_OUT" != "No local changes to save" ] && git stash pop --quiet
            if ! git diff-index --quiet HEAD; then
                git add .
                git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
                git push origin main
            fi
        fi
    fi
done

## 🟪 SECTION 3: COMMON CONFIGURATIONS
3.1 Starship.toml (Cross-Platform)

Windows Path: C:\Users\Gaurav\.config\starship.toml Linux Path: ~/.config/starship.toml
Ini, TOML

scan_timeout = 1000
command_timeout = 1000
add_newline = false

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[git_branch]
symbol = "🌱 "
style = "bold yellow"

[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
modified = "📝"
untracked = "🆕"
staged = "✅"

[palettes.gaurav_theme]
gs6651 = "bold cyan"
terminal_center = "bold magenta"
inkwell = "bold orange"
sanctuary = "bold green"
foundry = "bold blue"

[directory]
style = "bold italic blue"
repo_root_style = "gaurav_theme" 

[custom.gitsync]
description = "Show sync status of all local repos"
command = """
$repos = Get-ChildItem "$HOME/Documents/GitLocal" -Directory
$dirty = $false
foreach ($repo in $repos) {
    if (git -C $repo.FullName status --porcelain) { $dirty = $true; break }
}
if ($dirty) { echo "❌" } else { echo "✅" }
"""
when = 'test -d "$HOME/Documents/GitLocal"'
shell = ["powershell", "-Command"]
style = "bold blue"
format = "[$symbol($output)]($style) "
symbol = "🔄 "

## 🟥 SECTION 4: DISASTER RECOVERY & TIPS
4.1 Repairing Windows Bootloader (from Linux break)

    Remove Linux Partitions: Use diskmgmt.msc in Windows, delete volumes.

    Repair Commands (Windows Recovery Command Prompt):

        bootrec /fixmbr

        bootrec /fixboot

        bootrec /rebuildbcd

    EFI Ghost Entry Cleanup (diskpart):

        diskpart > sel disk 0 > list vol > sel vol (EFI system) > assign letter=Z:

        cd Z:\EFI > rmdir /S <distro_name>

4.2 Git SSH Identity
Bash

git config --global user.name "Gaurav Saini"
git config --global user.email "gauravsaini88@gmail.com"
ssh-keygen -t ed25519 -C "gauravsaini88@gmail.com"
# Add .pub content to GitHub settings

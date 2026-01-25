# 💻 Windows 11 Ultimate Clean & Dev Setup

A comprehensive guide to transforming Windows 11 into a bloat-free, privacy-respecting development environment.

## 🕒 System Interface & Localization

### Fix the 12H Format on Lock Screen

Windows uses a "Welcome Screen" setting that doesn't always sync with your user profile.

- Open Settings > Time & language > Language & region.
- Click Administrative language settings (on the right or bottom).
- In the "Administrative" tab, click Copy settings....
- Check the box: Welcome screen and system accounts.
- Click OK and restart.

### Remove Weather and News

- Open Settings > Personalization > Lock screen.
- Find Lock screen status.
- Change the dropdown from "Weather and more" to None.

### Disable Bing Search

  = Press Win + R, type `regedit`, and hit Enter.
  = Navigate to: `HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer` *(If the `Explorer` folder doesn't exist, right-click Windows, select New > Key, and name it Explorer)*.
  = Right-click in the right pane, select New > DWORD (32-bit) Value.
  = Name it DisableSearchBoxSuggestions.
  = Double-click it and set the Value data to 1.
  = Restart Windows Explorer (via Task Manager) or your PC.

### Clean Up Search Highlights

To remove the "Daily Image/Icon" inside the search bar itself:

- Go to Settings > Privacy & security > Search permissions.
- Scroll down to More settings and toggle Show search highlights to Off.

## #Disable "Tailored Experiences" & Tracking

This stops Microsoft from using your usage data to show you ads in the first place.

- Go to Settings > Privacy & security > General.
- Toggle OFF all four options, especially:
  - Let apps show me personalized ads by using my advertising ID.
  - Show me suggested content in the Settings app.

### Deep-Clean Notifications & "Welcome" Nagging

Microsoft often hides ads inside the notification system under the guise of "tips."

- Go to Settings > System > Notifications.
- Scroll to the very bottom and click Additional settings.
- Uncheck all three boxes:
  - Show the Windows welcome experience...
  - Suggest ways to get the most out of Windows...
  - Get tips and suggestions when using Windows.

### Clear the Start Menu "Recommendations"

To stop the Start menu from suggesting apps you haven't installed:

- Go to Settings > Personalization > Start.
- Toggle OFF: Show recommendations for tips, shortcuts, new apps, and more.

### Remove File Explorer Ads

Yes, even your folders have "Sync provider notifications" (ads for OneDrive).

- Open File Explorer, click the three dots (...) in the top bar, and select Options.
- Go to the View tab.
- Scroll down and uncheck: Show sync provider notifications.

## ⚡ Automation & Maintenance

One-Click "Kill Switch" Script. Run this in PowerShell (Admin) to apply registry-based privacy tweaks instantly:

```powershell
# Disable Advertising ID, Start Menu Suggestions, and Explorer Ads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncConfirmation" /t REG_DWORD /d 0 /f
```

## Git Setup

### Minimal Installation

Use the following winget command for a clean, non-intrusive install:
`winget install --id Git.Git -e --source winget --override "/NoGui /NoShellIntegration /NoGitLfs /NoCredentialManager"`

- Settings In-check
  - Keep checked: Associate .git* configuration files with the default text editor
  - Keep checked: Associate .sh files to be run with Bash
  - Uncheck: Windows Explorer integration (This removes "Git Bash here" from your right-click menu)
  - Uncheck: Git LFS (Large File Support)
  - Uncheck: Scalar (Git add-on to manage large-scale repositories)
- Other Settinsg
  - Adjusting your PATH: Choose Git from the command line and also from 3rd-party software.
  - SSH executable: Choose Use bundled OpenSSH.
  - HTTPS transport: Choose Use the OpenSSL library.
  - Line ending conversions: Choose Checkout Windows-style, commit Unix-style line endings.
  - Terminal emulator: Choose Use Windows' default console window.
  - Git pull behavior: Choose Default (fast-forward or merge).
  - Credential helper: Choose None (since you'll be using SSH for your repos).

### Setup

- Global Config:
```shell
git config --global user.name "Gaurav Saini"
git config --global user.email "gauravsaini88@gmail.com"
```

- Repository Management
`New-Item -ItemType Directory -Force -Path "C:\Users\Gaurav\Documents\GitLocal"`
SSH Authentication:
`ssh-keygen -t ed25519 -C "gauravsaini88@gmail.com"`

`cat ~/.ssh/id_ed25519.pub`
GitHub Settings > SSH and GPG keys > New SSH Key, paste your key

### Move into your local directory

cd "C:\Users\Gaurav\Documents\GitLocal"

### Clone the 5 repositories

```shell
git clone --depth 1 git@github.com:gs6651/gs6651.git gs6651
git clone --depth 1 git@github.com:gs6651/Terminal-Center.git Terminal-Center
git clone --depth 1 git@github.com:gs6651/The-Inkwell.git The-Inkwell
git clone --depth 1 git@github.com:gs6651/Six-String-Sanctuary.git Six-String-Sanctuary
git clone --depth 1 git@github.com:gs6651/Packet-Foundry.git Packet-Foundry
```


# Ubuntu Setup Guide

## First Thing First - Update / Upgrade

```bash
sudo apt update
sudo apt upgrade -y
```

## De-Snap Ubuntu

1. Remove all installed snap packages:\
`snap list | awk '{if(NR>1) print $1}' | xargs -I{} sudo snap remove --purge {}`

2. Remove the snapd daemon:\
`sudo apt purge snapd -y`

3. Prevent snapd from being re-installed (Apt Pinning):\

- Create a preference file:\
`sudo nano /etc/apt/preferences.d/nosnap.pref`
- Paste the following:

```bash
Package: snapd
Pin: release a=*
Pin-Priority: -10
```

> Press `Ctrl+O`, `Enter`, then `Ctrl+X` to save and exit.

4. Update your package list:\

`sudo apt update`

## Flatpak

```bash
sudo apt install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

## Firefox from Mozilla PPA

> Ubuntu 25.10 includes a "**fake**" Firefox package that tries to re-install the Snap. We need to add the PPA and "pin" it so the real version takes priority.

1. Add the Mozilla Team PPA:\
`sudo add-apt-repository ppa:mozillateam/ppa -y`

2. Set the PPA priority:

- Create a new preference file:\
`sudo nano /etc/apt/preferences.d/mozillateamppa`
- Paste this in to ensure the PPA version always wins:

```bash
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
```

> Press `Ctrl+O`, `Enter`, then `Ctrl+X` to save and exit.

3. Install Firefox

```bash
sudo apt update
sudo apt install firefox -y
```

## Git Setup

1. Install Git:\

- Install Git from the official Ubuntu APT repositories as a standard `.deb` package, not as a snap and not a flatpak\
`sudo apt install git -y`

2. Introduce yourself in git

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

3. Generate SSH Key\
`ssh-keygen -t ed25519 -C "your_email@example.com"`\

(Press Enter to save in the default location and optionally add a passphrase.)

4. Start the ssh-agent:\
`eval "$(ssh-agent -s)"`

5. Add your key to the agent:\
`ssh-add ~/.ssh/id_ed25519`

6. Copy the public key to your clipboard:\
`cat ~/.ssh/id_ed25519.pub`\

**Next:** Copy the output of that last command and add it to your **GitHub Settings -> SSH and GPG keys -> New SSH key**.

7. Test the connection:\
`ssh -T git@github.com`         ! Hi [your-username]! You've successfully authenticated, but GitHub does not provide shell access."

8. Clone the repository without history:\

- I keep it in the `/Documents/SecondBrain_GitLocal/`, Clone it where ever you like.\
`mkdir -p ~/Documents/SecondBrain_GitLocal/
git clone --depth 1 git@github.com:ABC/XYZ.git ~/Documents/SecondBrain_GitLocal/`

### gitsync script 💫

1. Create a small script in local binary folder\

``` bash
mkdir -p ~/.local/bin
nano ~/.local/bin/gitsync
```

2. Past following in the editor"\

```bash
#!/bin/bash

# Define Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TARGET_DIR="$HOME/Documents/SecondBrain_GitLocal/"
cd "$TARGET_DIR" || { echo -e "${RED}Error: Could not find directory $TARGET_DIR${NC}"; exit 1; }
echo -e "${CYAN}Checking for updates...${NC}"

# Pull latest changes
if ! git pull; then
    echo -e "${RED}Sync failed during pull.${NC}"
    exit 1
fi

# Check if there are changes to commit
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${CYAN}Nothing to sync. Everything is up to date.${NC}"
    exit 0
fi

# Add, Commit, and Push
git add .
git commit -m "sync: $(date +'%Y-%m-%d %H:%M:%S', linux )"
if git push; then
    echo -e "${GREEN}Sync successful! Changes pushed to GitHub.${NC}"
else
    echo -e "${RED}Sync failed during push.${NC}"
    exit 1
fi
```

> Press `Ctrl+O`, `Enter`, then `Ctrl+X` to save and exit.

3. Make Script executable"\
`chmod +x ~/.local/bin/gitsync`

4. Move the script to a "Shortcut" location: `mkdir -p ~/.local/bin`

5. Update source: `source ~/.bashrc`

### Terminal Update for Git Branch

```bash
nano ~/.bashrc

# Git prompt support
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
    # This makes the prompt show the branch and a '*' if there are changes
    export GIT_PS1_SHOWDIRTYSTATE=1
    export PS1='\[\033[01;32m\][\u@\h \W]\[\033[00m\]$(__git_ps1 " (\[\033[01;33m\]%s\[\033[00m\])")\$ '
fi
```

> Save and Exit: Press Ctrl+O, Enter, then Ctrl+X

- `source ~/.bashrc`

## Audacity and FFMPEG

```bash
flatpak install flathub org.audacityteam.Audacity -y
sudo apt install ffmpeg -y
```

> How to handle Latency
> Latency (the delay between playing a string and hearing it) is usually caused by the Buffer Size, not the package format.
> Once installed, we will do two things:
>
> 1. In Audacity, go to Edit > Preferences > Audio Settings.
> 2. Reduce the Buffer length (default is 100ms). Try setting it to 20ms or 40ms. If the audio crackles, go slightly higher.

## VScode

1. Install the necessary support tools:
`sudo apt install software-properties-common apt-transport-https wget -y`

2. Import the Microsoft GPG Key:

```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
```

3. Add VScode repository
`sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'`

4. Install VScode

```bash
sudo apt update
sudo apt install code -y
```

## LibreOffice (Only Write and Calc)

```bash
sudo apt install --no-install-recommends libreoffice-writer libreoffice-calc -y
dpkg -l | grep libreoffice ! To Verify the result that only Writer and Calc got installed and some core package, nothing else 
```

## Extras

1. Minimize on click\
`gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'`

2. Install "Extension Manager"\
`sudo apt install gnome-shell-extension-manager -y`

3. Disable shutdown and reboot timers\
`gsettings set org.gnome.SessionManager logout-prompt false`

4. Disable Bluetooth Auto enable after reboot\
`sudo nano /etc/bluetooth/main.conf`  ! Set it to AutoEnable=false'

5. Enable Minimize, Maximize Buttons\
`gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'`

6. Bluetooth Battery percentage\

```bash
sudo systemctl edit bluetooth.service

! Copy below 3 lines
[Service]
ExecStart=
ExecStart=/usr/libexec/bluetooth/bluetoothd --experimental

! Restrart the bluetooth service
sudo systemctl restart bluetooth.service
```

7. To Make Pendrive Bootable\

- `lsblk`   # To check the partitions
- `sudo umount /dev/sdX1`   # un-mount pendrive
- `sudo dd if=/path/to/ubuntu.iso of=/dev/sdX bs=4M status=progress`
  - `if`: specifies the input file (your ISO image).
  - `of`: specifies the output file (your USB drive).
  - `bs=4M`: sets the block size to 4 megabytes for faster writing.
  - `status=progress`: shows the progress of the writing process (available in newer versions of dd).
- `sync`    # to ensure all data in sync. If successful, This will not return anything

## Tweaks for Debian

- `sudo apt purge fcitx5-*`
- `sudo apt purge -s kasumi anthy --autoremove`
- `sudo apt purge kasumi anthy --autoremove`
- `sudo apt purge ibus-mozc fcitx-mozc mozc-data mozc-server mozc-utils-gui uim-mozc emacs-mozc-bin emacs-mozc`
- `sudo apt purge fcitx*`
- `sudo apt autoremove`

### Remove ShotWell

- `sudo apt purge shotwell`
- `rm -rf ~/.config/shotwell`
- `rm -rf ~/.local/share/shotwell`
- `rm -rf ~/.cache/shotwell`
- `sudo apt autoremove`

## Clean-up

```bash
sudo apt autoremove --purge -y
sudo apt clean
flatpak uninstall --unused
```

## EFI Ghost Entry Cleanup

1. List entries\
`sudo efibootmgr`

2. Delete Fedora (replace XXXX with the ID found, e.g., 0013)\
`sudo efibootmgr -b XXXX -B`

3. Remove leftover directory\
`sudo rm -rf /boot/efi/EFI/fedora`


## Low-Latency Kernel

```bash
sudo apt install linux-lowlatency -y    ! reboot after it and hold shift while reboot to select in the GRUB menu
sudo apt purge linux-lowlatency -y      ! To uninstall it
sudo update-grub
```

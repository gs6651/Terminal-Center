#!/bin/bash

# ==========================================================
# 🚀 SYSTEM-FORGE.SH
# Multi-Distro Provisioner (Ubuntu/Fedora)
# ==========================================================

# 0. Interactive Setup
echo -e "\033[0;35m👤 GIT IDENTITY SETUP\033[0m"
read -p "   Enter GitHub Username: " GIT_USER
read -p "   Enter GitHub Email:    " GIT_EMAIL

# 1. OS Detection
OS_TYPE=$(lsb_release -si 2>/dev/null || [ -f /etc/fedora-release ] && echo "Fedora" || echo "Ubuntu")
echo -e "\033[0;34m🌐 Detected OS: $OS_TYPE\033[0m"

# 2. Hostname Configuration
sudo hostnamectl set-hostname $(echo "$OS_TYPE" | tr '[:upper:]' '[:lower:]')

# 3. Ubuntu-Specific: Snap Purge & Firefox Pinning
if [ "$OS_TYPE" == "Ubuntu" ]; then
    echo "🛡️ Purging Snap & Pinning Mozilla PPA..."
    sudo snap remove firefox 2>/dev/null
    sudo apt purge -y snapd 2>/dev/null
    sudo add-apt-repository -y ppa:mozillateam/ppa
    
    sudo tee /etc/apt/preferences.d/mozilla-firefox <<EOF
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1
EOF

    sudo tee /etc/apt/preferences.d/nosnap.pref <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
fi

# 4. Dependencies & Softwares
echo "📦 Installing Apps..."
if [ "$OS_TYPE" == "Fedora" ]; then
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    # VS Code RPM Repo
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    
    sudo dnf install -y curl git gettext ffmpeg audacity firefox gnome-extensions-app libreoffice-writer libreoffice-calc dnsconfd code
else
    sudo apt update
    # VS Code DEB Repo
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    rm microsoft.gpg
    
    sudo apt update
    sudo apt install -y ffmpeg audacity gnome-shell-extension-manager libreoffice-writer libreoffice-calc curl git gettext software-properties-common code firefox
fi

# 5. Encrypted DNS (DoT)
echo "🔒 Configuring Encrypted DNS..."
if [ "$OS_TYPE" == "Fedora" ]; then
    sudo systemctl disable --now systemd-resolved && sudo systemctl mask systemd-resolved
    sudo systemctl enable --now dnsconfd
    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo tee /etc/NetworkManager/conf.d/global-dot.conf > /dev/null <<EOF
[main]
dns=dnsconfd
[global-dns]
resolve-mode=exclusive
[global-dns-domain-*]
servers=dns+tls://1.1.1.1#one.one.one.one
EOF
    sudo systemctl restart NetworkManager
else
    sudo sed -i 's/#DNS=/DNS=1.1.1.1 1.0.0.1/' /etc/systemd/resolved.conf
    sudo sed -i 's/#DNSOverTLS=no/DNSOverTLS=yes/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
fi

# 6. Git & SSH Setup
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$GIT_USER@$(hostname)" -N "" -f ~/.ssh/id_ed25519
    echo -e "\033[1;33m⚠️ ADD THIS SSH KEY TO GITHUB:\033[0m"
    cat ~/.ssh/id_ed25519.pub
fi

# 7. Multi-Repo Architecture
mkdir -p ~/Documents/GitLocal
REPOS=("Terminal-Center" "Packet-Foundry" "Six-String-Sanctuary" "The-Inkwell" "$GIT_USER")
for r in "${REPOS[@]}"; do
    if [ ! -d "$HOME/Documents/GitLocal/$r" ]; then
        git clone git@github.com:$GIT_USER/$r.git "$HOME/Documents/GitLocal/$r"
    fi
done

# 8. Create gitsync tool & gs Alias
mkdir -p ~/.local/bin
cat << 'EOF' > ~/.local/bin/gitsync
#!/bin/bash

# --- 1. Colors & Branding ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' 

BASE_DIR="$HOME/Documents/GitLocal"

echo -e "${PURPLE}============================================${NC}"
echo -e "${PURPLE}🚀 gs6651's GIT-FORGE SYNC ENGINE${NC}"
echo -e "${PURPLE}============================================${NC}"

# --- 2. Determine Targets ---
if [ -n "$1" ]; then
    REPOS=("$1")
    echo -e "${BLUE}🎯 Targeting: $1${NC}"
else
    # Explicitly find folders only inside GitLocal
    REPOS=($(find "$BASE_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
    echo -e "${BLUE}📊 Detected ${#REPOS[@]} Repositories in GitLocal${NC}"
fi

# --- 3. Main Loop ---
for REPO in "${REPOS[@]}"; do
    TARGET="$BASE_DIR/$REPO"
    
    echo -e "${NC}--------------------------------------------"
    
    if [ -d "$TARGET" ] && [ -d "$TARGET/.git" ]; then
        echo -e "📁 Processing: ${YELLOW}$REPO${NC}"
        cd "$TARGET" || continue

        # Internal automation for stats
        if [ "$REPO" == "The-Inkwell" ] && [ -f ".assets/update_stats.sh" ]; then
            echo -e "${BLUE}📝 Updating Book Stats...${NC}"
            bash "./.assets/update_stats.sh"
        fi

        # Git Operations
        git add .
        STASH_OUT=$(git stash push -m "sync-stash")

        echo -e "${BLUE}🔄 Pulling latest changes...${NC}"
        if git pull origin main --rebase; then
            [[ "$STASH_OUT" != "No local changes to save" ]] && git stash pop --quiet
            
            if ! git diff-index --quiet HEAD; then
                git add .
                git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
                if git push origin main; then
                    echo -e "${GREEN}📤 Pushed successfully!${NC}"
                else
                    echo -e "${RED}❌ Push failed! Check connection or permissions.${NC}"
                fi
            else
                echo -e "${GREEN}✨ Sync complete. No new changes to push.${NC}"
            fi
        else
            echo -e "${RED}❌ Pull/Rebase failed! Manual conflict resolution needed.${NC}"
            [[ "$STASH_OUT" != "No local changes to save" ]] && git stash pop --quiet
        fi
    else
        echo -e "${RED}⚠️ Skipping: $REPO (Not a Git repository)${NC}"
    fi
done

echo -e "${PURPLE}============================================${NC}"
echo -e "${GREEN}✅ ALL SYNC OPERATIONS FINISHED${NC}"
echo -e "${PURPLE}============================================${NC}"

EOF
chmod +x ~/.local/bin/gitsync

# Add 'gs' alias to .bashrc if it doesn't exist
if ! grep -q "alias gs=" ~/.bashrc; then
    echo "alias gs='~/.local/bin/gitsync'" >> ~/.bashrc
fi


# 9. GNOME Tweaks
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.Bluetooth power-state-always-on false

# 9.1. Bluetooth Battery Percentage (Automated)
echo "🔋 Enabling Bluetooth Experimental features..."
sudo mkdir -p /etc/systemd/system/bluetooth.service.d
sudo tee /etc/systemd/system/bluetooth.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/libexec/bluetooth/bluetoothd --experimental
EOF
sudo systemctl daemon-reload && sudo systemctl restart bluetooth.service

# 9.2. Terminal Transparency (Smarter Ptyxis Detection)
echo "🎨 Applying Ptyxis Transparency..."
# Try to get default; if null, grab the first existing profile UUID
PTYXIS_PROFILE=$(gsettings get org.gnome.Ptyxis default-profile 2>/dev/null | tr -d "'")
if [ -z "$PTYXIS_PROFILE" ] || [ "$PTYXIS_PROFILE" == "null" ]; then
    PTYXIS_PROFILE=$(gsettings get org.gnome.Ptyxis profile-uuids 2>/dev/null | tr -d "[]'," | awk '{print $1}')
fi

if [ -n "$PTYXIS_PROFILE" ]; then
    gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$PTYXIS_PROFILE/ opacity 0.90
    echo -e "\033[0;32m✅ Ptyxis transparency set on profile: $PTYXIS_PROFILE\033[0m"
else
    echo -e "\033[0;33m⚠️ No Ptyxis profile detected. Open Ptyxis once to initialize.\033[0m"
fi

# 10. Final System Cleanup
echo "🧹 Performing final cleanup..."
if [ "$OS_TYPE" == "Fedora" ]; then
    sudo dnf autoremove -y && sudo dnf clean all
else
    sudo apt autoremove -y && sudo apt clean
fi

echo -e "\033[0;32m✅ FORGE COMPLETE. PLEASE REBOOT.\033[0m"



# 11. EFI Cleanup (Removes old boot entries from previous distros)
echo "🧹 Cleaning EFI boot entries..."
sudo efibootmgr # This displays the list so you can see what is happening
# Example: sudo efibootmgr -b 0001 -B (This is manual to avoid deleting the current OS)

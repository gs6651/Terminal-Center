#!/bin/bash

# 0. Interactive Setup
echo "👤 Git Configuration"
read -p "   Enter Git Username: " GIT_USER
read -p "   Enter Git Email: " GIT_EMAIL

# 1. OS Detection
OS_TYPE=$(lsb_release -si 2>/dev/null || [ -f /etc/fedora-release ] && echo "Fedora" || echo "Ubuntu")
sudo hostnamectl set-hostname $(echo "$OS_TYPE" | tr '[:upper:]' '[:lower:]')

# 2. Ubuntu: Snap Purge & Firefox Pinning
if [ "$OS_TYPE" == "Ubuntu" ]; then
    echo "🛡️ Purging Snap & Pinning Firefox PPA..."
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

# 3. Dependencies & Softwares
echo "📦 Installing Apps..."
if [ "$OS_TYPE" == "Fedora" ]; then
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y git gettext ffmpeg audacity firefox gnome-extensions-app libreoffice-writer libreoffice-calc dnsconfd
else
    sudo apt update
    sudo apt install -y ffmpeg audacity gnome-shell-extension-manager libreoffice-writer libreoffice-calc git gettext software-properties-common
    sudo apt install -y firefox
fi

# 4. Encrypted DNS (DoT)
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
    # Ubuntu Method (systemd-resolved)
    sudo sed -i 's/#DNS=/DNS=1.1.1.1 1.0.0.1/' /etc/systemd/resolved.conf
    sudo sed -i 's/#DNSOverTLS=no/DNSOverTLS=yes/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
fi

# 5. Git & SSH Setup
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$GIT_USER@$(hostname)" -N "" -f ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub
fi

# 6. Clone Repos
mkdir -p ~/Documents/GitLocal
REPOS=("Terminal-Center" "Packet-Foundry" "Six-String-Sanctuary" "The-Inkwell" "$GIT_USER")

for r in "${REPOS[@]}"; do
    if [ ! -d "$HOME/Documents/GitLocal/$r" ]; then
        git clone git@github.com:$GIT_USER/$r.git "$HOME/Documents/GitLocal/$r"
    fi
done

# 7. Create gitsync tool
mkdir -p ~/.local/bin

# We keep 'EOF' quoted to protect all the internal variables like $REPO and $1
cat << 'EOF' > ~/.local/bin/gitsync
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_DIR="$HOME/Documents/GitLocal"

# Check if a specific repo was passed as an argument
if [ -n "$1" ]; then
    REPOS=("$1")
    echo -e "${BLUE}🎯 Targeting single repo: $1${NC}"
else
    # We use a placeholder here
    REPOS=("Packet-Foundry" "Terminal-Center" "Six-String-Sanctuary" "The-Inkwell" "USER_NAME_PLACEHOLDER")
    echo -e "${BLUE}🚀 Starting Global GitSync (All Repos)...${NC}"
fi

for REPO in "${REPOS[@]}"; do
    TARGET="$BASE_DIR/$REPO"
    
    if [ -d "$TARGET" ]; then
        echo -e "${NC}--------------------------------------------"
        echo -e "📁 Processing: ${YELLOW}$REPO${NC}"
        cd "$TARGET" || continue

        if [ "$REPO" == "The-Inkwell" ] && [ -f ".assets/update_stats.sh" ]; then
            bash "./.assets/update_stats.sh"
        fi

        if [ ! -d ".git" ]; then
            echo -e "${RED}❌ Error: $REPO is not a git repository.${NC}"
            continue
        fi

        git add .
        STASH_OUT=$(git stash push -m "sync-stash")

        if git pull origin main --rebase; then
            echo -e "${GREEN}📥 Pull successful.${NC}"
            [ "$STASH_OUT" != "No local changes to save" ] && git stash pop --quiet
            
            if ! git diff-index --quiet HEAD; then
                git add .
                git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
                git push origin main && echo -e "${GREEN}📤 Pushed changes.${NC}"
            else
                echo -e "${BLUE}✨ Already up to date.${NC}"
            fi
        else
            echo -e "${RED}❌ Pull failed.${NC}"
            [ "$STASH_OUT" != "No local changes to save" ] && git stash pop --quiet
        fi
    else
        echo -e "${RED}❌ Error: Directory $REPO not found.${NC}"
    fi
done
echo -e "${NC}--------------------------------------------"
echo -e "${GREEN}✅ Done!${NC}"
EOF

# NOW: We swap the placeholder with your actual $GIT_USER variable
sed -i "s/USER_NAME_PLACEHOLDER/$GIT_USER/g" ~/.local/bin/gitsync

chmod +x ~/.local/bin/gitsync

# 8. GNOME Tweaks
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.Bluetooth power-state-always-on false
PTYXIS_PROFILE=$(gsettings get org.gnome.Ptyxis default-profile | tr -d "'")
gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$PTYXIS_PROFILE/ opacity 0.90


# 9. Final System Cleanup
echo "🧹 Performing final cleanup..."
if [ "$OS_TYPE" == "Fedora" ]; then
    sudo dnf autoremove -y
    sudo dnf clean all
else
    sudo apt autoremove -y
    sudo apt clean
fi

echo "✅ FORGE COMPLETE. After EFI Cleanup (Manual), REBOOT (Must)"

# 10. EFI Cleanup (Removes old boot entries from previous distros)
echo "🧹 Cleaning EFI boot entries..."
sudo efibootmgr # This displays the list so you can see what is happening
# Example: sudo efibootmgr -b 0001 -B (This is manual to avoid deleting the current OS)

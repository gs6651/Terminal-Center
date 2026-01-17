#!/bin/bash

# --- 1. Distro Detection & Initial Setup ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

# Colors for Output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${CYAN}Starting System Forge v2.0 for ${NAME} ${VER}...${NC}"

# Detect Package Manager
if command -v dnf5 &> /dev/null; then
    INSTALL_CMD="sudo dnf5 install -y"
    UPDATE_CMD="sudo dnf5 upgrade -y"
elif command -v dnf &> /dev/null; then
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD="sudo dnf upgrade -y"
elif command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y curl
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
else
    echo -e "${RED}Error: Supported package manager not found.${NC}"
    exit 1
fi

# --- 2. System Update ---
echo -e "${YELLOW}Updating System...${NC}"
$UPDATE_CMD

# --- 3. FEDORA SPECIFIC: Enable RPM Fusion
if [[ "$OS" == "fedora" ]]; then
    echo -e "${YELLOW}Enabling RPM Fusion & Cisco H264...${NC}"
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf config-manager --set-enabled fedora-cisco-openh264
fi

# --- 4. UBUNTU SPECIFIC: Debloating ---
if [[ "$OS" == "ubuntu" ]]; then
    echo -e "${YELLOW}Purging Snaps...${NC}"
    sudo snap list | awk '{if(NR>1) print $1}' | xargs -I{} sudo snap remove --purge {}
    sudo apt purge snapd -y
    sudo bash -c 'cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF'
fi

# --- 5. Git & Multi-Repo Architecture ---
echo -e "${CYAN}--- Git & Knowledge Base Setup ---${NC}"
read -p "Git Email: " git_email
git_user="gs6651"
base_git_path="$HOME/Documents/GitLocal"

$INSTALL_CMD git
git config --global user.email "$git_email"
git config --global user.name "$git_user"

# SSH Key Generation
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N ""
    echo -e "${GREEN}Copy this key to GitHub Settings:${NC}"
    cat ~/.ssh/id_ed25519.pub
    read -p "Press Enter after you have added the key..."
fi

# Clone the 4 Specialized Repos
mkdir -p "$base_git_path"
REPOS=("Packet-Foundry" "Terminal-Center" "Six-String-Sanctuary" "The-Inkwell")

for REPO in "${REPOS[@]}"; do
    if [ ! -d "$base_git_path/$REPO" ]; then
        echo -e "${YELLOW}Attempting to clone $REPO...${NC}"
        # Adding '|| true' prevents the script from stopping if the repo is private
        git clone "git@github.com:gs6651/$REPO.git" "$base_git_path/$REPO" || echo -e "${RED}Note: Could not clone $REPO (It may be private). Skipping...${NC}"
    fi
done

# --- 6. Custom Tool: gitsync (Colorful & Multi-repo) ---
echo -e "${YELLOW}Installing 'gitsync' to ~/.local/bin/...${NC}"
mkdir -p ~/.local/bin

cat << 'EOF' > ~/.local/bin/gitsync
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_DIR="$HOME/Documents/GitLocal"
REPOS=("Packet-Foundry" "Terminal-Center" "Six-String-Sanctuary" "The-Inkwell")

echo -e "${BLUE}🚀 Starting Global GitSync...${NC}"

for REPO in "${REPOS[@]}"; do
    if [ -d "$BASE_DIR/$REPO" ]; then
        echo -e "${NC}--------------------------------------------"
        echo -e "📁 Processing: ${YELLOW}$REPO${NC}"
        cd "$BASE_DIR/$REPO"
        
        if git pull origin main --rebase; then
            git add .
            if ! git diff-index --quiet HEAD; then
                git commit -m "Auto-sync from linux: $(date +'%Y-%m-%d %H:%M:%S')"
                git push origin main
                echo -e "${GREEN}📤 Changes pushed successfully.${NC}"
            else
                echo -e "${BLUE}✨ Already up to date.${NC}"
            fi
        else
            echo -e "${RED}❌ Sync failed for $REPO.${NC}"
        fi
    fi
done
echo -e "${NC}--------------------------------------------"
echo -e "${GREEN}✅ All repositories synchronized!${NC}"
EOF

chmod +x ~/.local/bin/gitsync

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# --- 7. Software Selection ---
confirm() { read -p "Install $1? (y/n): " c; [[ "$c" == "y" ]]; }

if confirm "VS Code"; then
    if [[ "$OS" == "ubuntu" ]]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt update && sudo apt install code -y
    else
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        $INSTALL_CMD code
    fi
fi

# --- 8. System Tweaks ---
echo -e "${YELLOW}Optimizing GNOME & Bluetooth...${NC}"
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

BT_SERVICE_PATH=$(find /usr/lib* -name bluetoothd | head -n 1)
sudo mkdir -p /etc/systemd/system/bluetooth.service.d
sudo bash -c "cat <<EOF > /etc/systemd/system/bluetooth.service.d/override.conf
[Service]
ExecStart=
ExecStart=$BT_SERVICE_PATH --experimental
EOF"
sudo systemctl daemon-reload && sudo systemctl restart bluetooth

echo -e "${GREEN}Forge Complete! Run 'source ~/.bashrc' to enable the 'gitsync' command.${NC}"

# --- 9. Essential Tools ---
sudo apt install -y git curl build-essential
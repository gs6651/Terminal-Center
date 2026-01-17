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
NC='\033[0m'

echo -e "${CYAN}Starting System Forge for ${NAME} ${VER}...${NC}"

# Detect Package Manager (Favoring DNF5 if available on Fedora 43+)
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

# --- 2. System Update & Repo Setup ---
echo -e "${YELLOW}Updating System...${NC}"
$UPDATE_CMD

# --- 3. FEDORA SPECIFIC: Enable RPM Fusion
if [[ "$OS" == "fedora" ]]; then
    echo -e "${YELLOW}Enabling RPM Fusion & Cisco H264...${NC}"
    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    # DNF5 compatibility: using 'config-manager' which is now a built-in subcommand
    sudo dnf config-manager --set-enabled fedora-cisco-openh264
fi

# --- 4. UBUNTU SPECIFIC: Debloating ---
if [[ "$OS" == "ubuntu" ]]; then
    echo -e "${YELLOW}Purging Snaps (Ubuntu 25.10 compatible)...${NC}"
    sudo snap list | awk '{if(NR>1) print $1}' | xargs -I{} sudo snap remove --purge {}
    sudo apt purge snapd -y
    # Prevent Snap from ever coming back
    sudo bash -c 'cat <<EOF > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF'
fi

# --- 5. Git & "Second Brain" Setup ---
echo -e "${CYAN}--- Personalization & Git ---${NC}"
read -p "Git Email: " git_email
read -p "Git Username: " git_user
read -p "Git Repo URL (SSH): " git_repo_url
read -p "Local Folder Path (e.g., /home/$USER/Brain): " git_path

$INSTALL_CMD git
git config --global user.email "$git_email"
git config --global user.name "$git_user"

# SSH Key Generation (Modern Ed25519)
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N ""
    echo -e "${GREEN}Copy this key to GitHub Settings:${NC}"
    cat ~/.ssh/id_ed25519.pub
    read -p "Press Enter after you have added the key..."
fi

# Clone the Second Brain
mkdir -p "$(dirname "$git_path")"
git clone --depth 1 "$git_repo_url" "$git_path"

# --- 6. Custom Tool: gitsync ---
echo -e "${YELLOW}Installing 'gitsync' to ~/.local/bin/...${NC}"
mkdir -p ~/.local/bin
cat <<EOF > ~/.local/bin/gitsync
#!/bin/bash
cd "$git_path" || exit 1
git pull
if [[ -n \$(git status --porcelain) ]]; then
    git add .
    git commit -m "forge-sync: \$(date +'%Y-%m-%d %H:%M:%S')"
    git push
fi
EOF
chmod +x ~/.local/bin/gitsync

# --- 7. Software Selection (Universal) ---
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

# --- 8. System Tweaks (GNOME & BT) ---
echo -e "${YELLOW}Optimizing GNOME & Bluetooth Experimental Features...${NC}"
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# Dynamic path for Bluetooth Battery Reporting
BT_SERVICE_PATH=$(find /usr/lib* -name bluetoothd | head -n 1)
sudo mkdir -p /etc/systemd/system/bluetooth.service.d
sudo bash -c "cat <<EOF > /etc/systemd/system/bluetooth.service.d/override.conf
[Service]
ExecStart=
ExecStart=$BT_SERVICE_PATH --experimental
EOF"
sudo systemctl daemon-reload && sudo systemctl restart bluetooth

echo -e "${GREEN}Forge Complete! Your system is now 'Settled'.${NC}"

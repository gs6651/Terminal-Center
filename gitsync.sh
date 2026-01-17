#!/bin/bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_DIR="$HOME/Documents/GitLocal"
REPOS=("Packet-Foundry" "Terminal-Center" "Six-String-Sanctuary" "The-Inkwell")

echo -e "${BLUE}🚀 Starting Global GitSync...${NC}"

for REPO in "${REPOS[@]}"; do
    if [ -d "$BASE_DIR/$REPO" ]; then
        echo -e "${NC}--------------------------------------------"
        echo -e "📁 Processing: ${YELLOW}$REPO${NC}"
        cd "$BASE_DIR/$REPO"
        
        # Pull from Windows/Remote changes first
        if git pull origin main --rebase; then
            echo -e "${GREEN}📥 Pull successful.${NC}"
        else
            echo -e "${RED}❌ Pull failed! Check for conflicts.${NC}"
            continue
        fi
        
        # Add and check for local changes
        git add .
        if ! git diff-index --quiet HEAD; then
            git commit -m "Auto-sync from linux: $(date +'%Y-%m-%d %H:%M:%S')"
            if git push origin main; then
                echo -e "${GREEN}📤 Changes pushed to GitHub.${NC}"
            else
                echo -e "${RED}❌ Push failed!${NC}"
            fi
        else
            echo -e "${BLUE}✨ Already up to date.${NC}"
        fi
    else
        echo -e "${RED}❌ $REPO: Directory not found.${NC}"
    fi
done

echo -e "${NC}--------------------------------------------"
echo -e "${GREEN}✅ All repositories synchronized!${NC}"
echo -e "${NC}--------------------------------------------"

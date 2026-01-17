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
    REPOS=("Packet-Foundry" "Terminal-Center" "Six-String-Sanctuary" "The-Inkwell" "gs6651")
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

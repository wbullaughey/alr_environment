#!/usr/bin/env bash
# ------------------------------------------------------------
# create-branch-with-submodules.sh
#   Create a new branch in the super-project AND every submodule.
# ------------------------------------------------------------

set -euo pipefail

# ---- Colours ------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }

# ---- Argument check -----------------------------------------
[[ $# -eq 1 ]] || die "Usage: $0 <new-branch-name>"
NEW_BRANCH="$1"

# ---- 1. Super-project ---------------------------------------
SUPER_ROOT="$(git rev-parse --show-toplevel)"
CURRENT_SUPER="$(git rev-parse --abbrev-ref HEAD)"

echo -e "${YELLOW}Creating super-project branch '${NEW_BRANCH}' from '${CURRENT_SUPER}' …${NC}"
git checkout -b "$NEW_BRANCH"
echo -e "${GREEN}Super-project now on '${NEW_BRANCH}'${NC}"

# ---- 2. Submodules ------------------------------------------
echo -e "${YELLOW}Processing submodules…${NC}"

# Use a *single* command string; pass $SUPER_ROOT explicitly.
git submodule foreach --quiet '
    # $name  = submodule name (from .gitmodules)
    # $path  = relative path (same as old $sm_path)

    # Skip if submodule is not checked out
    if [ ! -f "$path/.git" ]; then
        echo -e "'${YELLOW}'Skipping $name (not checked out)${NC}"
        exit 0
    fi

    echo -e "'${YELLOW}'Submodule: $path${NC}"

    # Run git commands inside the submodule directory
    (
        cd "$path" || exit 1

        if git show-ref --quiet --heads "'"$NEW_BRANCH"'"; then
            echo -e "'${GREEN}'  → exists, switching…${NC}"
            git checkout "'"$NEW_BRANCH"'"
        else
            echo -e "'${YELLOW}'  → creating from current HEAD…${NC}"
            git checkout -b "'"$NEW_BRANCH"'"
        fi
    )
'

# ---- 3. (Optional) Record branch in .gitmodules -------------
read -rp $'\n'"${YELLOW}Set '${NEW_BRANCH}' as default branch in .gitmodules? (y/N): ${NC}" -n1 REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git submodule foreach --quiet '
        git config -f "$SUPER_ROOT/.gitmodules" \
            submodule."$path".branch "'"$NEW_BRANCH"'"
    '
    if git diff --quiet .gitmodules; then
        echo -e "${YELLOW}.

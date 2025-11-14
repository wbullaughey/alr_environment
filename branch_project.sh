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
CURRENT_SUPER=$(git rev-parse --abbrev-ref HEAD)
echo -e "${YELLOW}Creating super-project branch '${NEW_BRANCH}' from '${CURRENT_SUPER}' …${NC}"
git checkout -b "$NEW_BRANCH"
echo -e "${GREEN}Super-project now on '${NEW_BRANCH}'${NC}"

# ---- 2. Submodules ------------------------------------------
echo -e "${YELLOW}Processing submodules…${NC}"

# `git submodule foreach` guarantees these variables:
#   $toplevel  – root of the super-project
#   $name      – submodule name (as in .gitmodules)
#   $sm_path   – path relative to $toplevel (may be empty if not checked-out)
#   $sha1      – commit currently checked out
git submodule foreach bash -c '
    set -euo pipefail

    # If the submodule is not checked out, skip it
    [[ -f "$toplevel/$sm_path/.git" ]] || {
        echo -e "'${YELLOW}'Skipping $name (not checked out)${NC}"
        exit 0
    }

    echo -e "'${YELLOW}'Submodule: $sm_path${NC}"

    # Switch/create the branch inside the submodule
    if git show-ref --quiet --heads "'"$NEW_BRANCH"'"; then
        echo -e "'${GREEN}'  → exists, switching…${NC}"
        git checkout "'"$NEW_BRANCH"'"
    else
        echo -e "'${YELLOW}'  → creating from current HEAD…${NC}"
        git checkout -b "'"$NEW_BRANCH"'"
    fi
'

# ---- 3. (Optional) Record branch in .gitmodules -------------
read -rp $'\n'"${YELLOW}Set '${NEW_BRANCH}' as default branch in .gitmodules? (y/N): ${NC}" -n1 REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git submodule foreach bash -c '
        git config -f "$toplevel/.gitmodules" \
            submodule."$sm_path".branch "'"$NEW_BRANCH"'"
    '
    if git diff --quiet .gitmodules; then
        echo -e "${YELLOW}.gitmodules unchanged${NC}"
    else
        git add .gitmodules
        git commit -m "Set submodule branch to ${NEW_BRANCH}"
        echo -e "${GREEN}.gitmodules updated${NC}"
    fi
fi

# ---- 4. Summary ---------------------------------------------
echo -e "\n${GREEN}All done! You are on '${NEW_BRANCH}' in the super-project and every checked-out submodule.${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "   git push origin ${NEW_BRANCH}"
echo "   git submodule foreach 'git push origin ${NEW_BRANCH} || true'"

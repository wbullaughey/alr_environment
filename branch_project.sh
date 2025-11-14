#!/usr/bin/env bash
# ------------------------------------------------------------
# branch_project.sh
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

# Build a *single* command that receives the super-project root.
# Inside the command we read the submodule path from .gitmodules.
git submodule foreach --quiet '
    set -euo pipefail
    SUPER_ROOT="'"$SUPER_ROOT"'"

    # ---- Get the relative path of this submodule (guaranteed) ----
    SUB_PATH=$(git config -f "$SUPER_ROOT/.gitmodules" --get "submodule.$name.path") || {
        echo -e "'"${YELLOW}"'Skipping $name (no .path entry)'"${NC}"'
        exit 0
    }

    # Skip if the submodule directory does not exist
    [[ -d "$SUB_PATH" ]] || {
        echo -e "'"${YELLOW}"'Skipping $name (directory missing)'"${NC}"'
        exit 0
    }

    echo -e "'"${YELLOW}"'Submodule: $SUB_PATH'"${NC}"'

    (
        cd "$SUB_PATH" || exit 1

        if git show-ref --quiet --heads "'"$NEW_BRANCH"'"; then
            echo -e "'"${GREEN}"'  → exists, switching…'"${NC}"'
            git checkout "'"$NEW_BRANCH"'"
        else
            echo -e "'"${YELLOW}"'  → creating from current HEAD…'"${NC}"'
            git checkout -b "'"$NEW_BRANCH"'"
        fi
    )
'

# ---- 3. (Optional) Record branch in .gitmodules -------------
read -rp $'\n'"${YELLOW}Set '${NEW_BRANCH}' as

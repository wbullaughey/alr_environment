#!/usr/bin/env bash
# ------------------------------------------------------------
# branch_project.sh
#   Create a new branch in the super-project and every submodule.
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

# We build a *single* command string that receives the super-project root.
# All variables inside the string are expanded **once** in the outer shell.
CMD='
  set -euo pipefail
  SUPER_ROOT="'"$SUPER_ROOT"'"
  PATH_REL="'"$path"'"

  # Skip if the submodule directory does not exist (not checked-out)
  [[ -d "$PATH_REL" ]] || { echo -e "'"${YELLOW}"'Skipping $name (not checked-out)'"${NC}"'; exit 0; }

  echo -e "'"${YELLOW}"'Submodule: $PATH_REL'"${NC}"'

  (
    cd "$PATH_REL" || exit 1

    if git show-ref --quiet --heads "'"$NEW_BRANCH"'"; then
      echo -e "'"${GREEN}"'  → exists, switching…'"${NC}"'
      git checkout "'"$NEW_BRANCH"'"
    else
      echo -e "'"${YELLOW}"'  → creating from current HEAD…'"${NC}"'
      git checkout -b "'"$NEW_BRANCH"'"
    fi
  )
'

git submodule foreach --quiet "$CMD"

# ---- 3. (Optional) Record branch in .gitmodules -------------
read -rp $'\n'"${YELLOW}Set '${NEW_BRANCH}' as default branch in .gitmodules? (y/N): ${NC}" -n1 REPLY
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git submodule foreach --quiet '
        git config -f "'"$SUPER_ROOT"'/.gitmodules" \
            submodule."$path".branch "'"$NEW_BRANCH"'"
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

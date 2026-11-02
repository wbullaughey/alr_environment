#!/usr/bin/env bash
#
# git-branch-submodules.sh
#
# Create (and switch to) a branch on a Git superproject and on its own
# (top-level) submodules.
#
# Mirrors git-tag-submodules.sh and shares its hard-won rules:
#   * It does NOT recurse into nested submodules -- vendored third-party deps
#     often carry broken nested .gitmodules entries that abort the whole run.
#   * It SKIPS any submodule whose path matches SKIP_PATTERN (vendored deps you
#     don't develop in and usually can't push to).
#   * Branch creation is local by default. With -p it also pushes each new
#     branch and sets upstream tracking; a submodule push that fails (e.g. a
#     third-party remote) warns and continues instead of aborting.

set -euo pipefail

# Remote pushed to (only used with -p). Change if yours differs.
REMOTE="origin"

# Submodule paths matching this case-glob are skipped. Empty string = all.
SKIP_PATTERN="vendor/*"

PUSH=0
FORCE=0

usage() {
    cat <<'EOF'
Usage: git-branch-submodules.sh [-p] [-f] <branch-name>

  -p   Push each new branch to the remote and set upstream tracking.
  -f   Force: if the branch already exists, reset it to the current commit
       (uses checkout -B). Without -f, an existing branch is an error.
  -h   Show this help and exit.

Creates the branch on the superproject and on each top-level submodule,
skipping any whose path matches the SKIP_PATTERN set in the script
(default: vendor/*). Nested submodules are not touched.
EOF
}

die() {
    printf 'error: %s\n' "$1" >&2
    exit 1
}

while getopts ":pfh" opt; do
    case "$opt" in
        p) PUSH=1 ;;
        f) FORCE=1 ;;
        h) usage; exit 0 ;;
        :) die "option -$OPTARG requires an argument" ;;
        \?) die "unknown option -$OPTARG" ;;
    esac
done
shift $((OPTIND - 1))

[ $# -eq 1 ] || die "exactly one branch name is required (see -h)"
BRANCH="$1"

# Must be inside a work tree; operate from its root so submodule paths resolve.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "not inside a Git working tree"
cd "$(git rev-parse --show-toplevel)"

# Without -f, refuse if the branch already exists in the superproject, so we
# fail early with a clear message rather than partway through.
if [ "$FORCE" -eq 0 ] && git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    die "branch '$BRANCH' already exists (use -f to reset it to the current commit)"
fi

# checkout -b creates+switches; -B additionally resets an existing branch.
co_flag="-b"
[ "$FORCE" -eq 1 ] && co_flag="-B"

echo ">> Creating branch '$BRANCH' on superproject..."
git checkout "$co_flag" "$BRANCH"

echo ">> Creating branch on submodules (top-level only, skipping '$SKIP_PATTERN')..."
export SM_BRANCH="$BRANCH" SM_CO="$co_flag" SM_SKIP="$SKIP_PATTERN"
git submodule foreach '
    if [ -n "$SM_SKIP" ]; then
        case "$sm_path" in
            $SM_SKIP) echo "  skipping $sm_path"; exit 0 ;;
        esac
    fi
    git checkout "$SM_CO" "$SM_BRANCH"
'

if [ "$PUSH" -eq 1 ]; then
    echo ">> Pushing submodule branches to $REMOTE (skipping '$SKIP_PATTERN')..."
    export SM_REMOTE="$REMOTE"
    git submodule foreach '
        if [ -n "$SM_SKIP" ]; then
            case "$sm_path" in
                $SM_SKIP) echo "  skipping $sm_path"; exit 0 ;;
            esac
        fi
        git push -u "$SM_REMOTE" "$SM_BRANCH" \
            || echo "  WARN: could not push branch to $sm_path (continuing)"
    '
    echo ">> Pushing superproject branch to $REMOTE..."
    git push -u "$REMOTE" "$BRANCH"
fi

echo ">> Done: branch '$BRANCH' created."

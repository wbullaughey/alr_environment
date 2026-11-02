#!/usr/bin/env bash
#
# git-clone-submodules.sh
#
# Clone a superproject at a given branch or tag, then put each of its own
# (top-level) submodules ON that same branch or tag.
#
# Why this is more than `git clone --recurse-submodules`:
#   A normal submodule checkout leaves each submodule on a DETACHED HEAD at the
#   commit the superproject pins -- not actually "on" a branch or tag. This
#   script clones the superproject at <ref>, then checks out the same-named
#   <ref> inside each submodule, so the whole set sits on one coordinated
#   branch/tag (as produced by git-branch-submodules.sh / git-tag-submodules.sh).
#
# Shares the rules of its sibling scripts:
#   * Submodules are initialized NON-recursively (vendored deps often carry
#     broken nested .gitmodules entries that abort a recursive init).
#   * Submodules matching SKIP_PATTERN (vendored third-party deps) are left at
#     their pinned commits -- not forced onto your ref, which they don't have.
#   * A submodule that lacks <ref> warns and is left at its pinned commit
#     instead of aborting the whole clone.

set -euo pipefail

# Submodule paths matching this case-glob are left at their pinned commit.
SKIP_PATTERN="vendor/*"

usage() {
    cat <<'EOF'
Usage: git-clone-submodules.sh <repo-url> <branch-or-tag> [target-dir]

  <repo-url>        URL of the superproject to clone.
  <branch-or-tag>   The ref to clone at and to check out in each submodule.
  [target-dir]      Where to clone (default: repo name derived from the URL).
  -h                Show this help and exit.

Submodules matching the SKIP_PATTERN set in the script (default: vendor/*)
are initialized at their pinned commits but not moved onto <ref>. Nested
submodules are not recursed into.
EOF
}

die() {
    printf 'error: %s\n' "$1" >&2
    exit 1
}

[ "${1:-}" = "-h" ] && { usage; exit 0; }

URL="${1:-}"
REF="${2:-}"
DIR="${3:-}"
[ -n "$URL" ] && [ -n "$REF" ] || die "need a repo URL and a branch/tag (see -h)"

# Derive a target directory from the URL if none was given (mirrors git clone).
if [ -z "$DIR" ]; then
    DIR="$(basename "$URL")"
    DIR="${DIR%.git}"
fi
[ -e "$DIR" ] && die "target '$DIR' already exists"

# 1) Clone the superproject AT the ref. --branch accepts both branches and tags.
#    A branch leaves you on it; a tag leaves you in detached HEAD (expected).
echo ">> Cloning superproject at '$REF' into '$DIR'..."
git clone --branch "$REF" "$URL" "$DIR"
cd "$DIR"

# 2) Populate top-level submodules at their pinned commits (NOT --recursive).
echo ">> Initializing top-level submodules..."
git submodule update --init

# 3) Check out the same ref inside each of your own submodules.
echo ">> Putting submodules onto '$REF' (skipping '$SKIP_PATTERN')..."
export SM_REF="$REF" SM_SKIP="$SKIP_PATTERN"
git submodule foreach '
    if [ -n "$SM_SKIP" ]; then
        case "$sm_path" in
            $SM_SKIP) echo "  $sm_path: vendored -> left at pinned $(git rev-parse --short HEAD)"; exit 0 ;;
        esac
    fi
    # Make sure tags and remote branches are available, then resolve <ref>.
    git fetch -q origin --tags 2>/dev/null || true
    if git rev-parse -q --verify "refs/tags/$SM_REF" >/dev/null 2>&1; then
        git checkout -q "refs/tags/$SM_REF"
        echo "  $sm_path: on tag $SM_REF (detached)"
    elif git rev-parse -q --verify "refs/remotes/origin/$SM_REF" >/dev/null 2>&1; then
        git checkout -q -B "$SM_REF" "origin/$SM_REF"
        echo "  $sm_path: on branch $SM_REF"
    else
        echo "  WARN: $sm_path has no '$SM_REF' -> left at pinned $(git rev-parse --short HEAD)"
    fi
'

# 4) Summary so you can confirm where everything landed.
echo ">> Result:"
sp_head="$(git rev-parse --abbrev-ref HEAD)"
[ "$sp_head" = "HEAD" ] && sp_head="$REF (detached)"
echo "  superproject: $sp_head"
git submodule --quiet foreach '
    b="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
    if [ -n "$b" ]; then
        echo "  $sm_path: $b (branch)"
    else
        echo "  $sm_path: $(git describe --tags --always 2>/dev/null) (detached)"
    fi
' 2>/dev/null || true

echo ">> Done."

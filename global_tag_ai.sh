#!/usr/bin/env bash
#
# git-tag-submodules.sh
#
# Create and push a tag on a Git superproject and on its own (top-level)
# submodules, then push everything.
#
# Why this exists:
#   A superproject already records the exact commit of every submodule (the
#   "gitlink"), recursively, so tagging only the superproject is enough to
#   reproduce the whole tree later via `git submodule update --init --recursive`.
#   For a coordinated release, this script also tags each *top-level* submodule's
#   own repository with the same tag and pushes it.
#
#   It deliberately does NOT recurse into nested submodules, and it SKIPS any
#   submodule whose path matches SKIP_PATTERN (vendored third-party deps). Those
#   are repos you typically don't own -- recursing into them hits broken nested
#   .gitmodules entries, and pushing to them fails with "permission denied".
#   The superproject's gitlink still captures their exact commits regardless.
#   A submodule push that fails (e.g. a third-party remote) warns and continues.

set -euo pipefail

# Remote pushed to for both superproject and submodules. Change if yours differs.
REMOTE="origin"

# Submodule paths matching this case-glob are skipped (not tagged, not pushed).
# Set to an empty string to operate on every top-level submodule.
SKIP_PATTERN="vendor/*"

MSG=""
SIGN=0
FORCE=0

# Recursing into submodules and pushing are always on; they are not CLI options.
RECURSE=1
PUSH=1

usage() {
    cat <<'EOF'
Usage: git-tag-submodules.sh [-m MSG] [-s] [-f] <tag-name>

  -m MSG  Annotation message (default: "Release <tag-name>").
  -s      Make a GPG-signed tag instead of a plain annotated tag.
  -f      Force: overwrite the tag if it already exists.
  -h      Show this help and exit.

Submodules are always tagged recursively, and all tags are pushed to the
remote, by default.
EOF
}

die() {
    printf 'error: %s\n' "$1" >&2
    exit 1
}

while getopts ":m:sfh" opt; do
    case "$opt" in
        m) MSG="$OPTARG" ;;
        s) SIGN=1 ;;
        f) FORCE=1 ;;
        h) usage; exit 0 ;;
        :) die "option -$OPTARG requires an argument" ;;
        \?) die "unknown option -$OPTARG" ;;
    esac
done
shift $((OPTIND - 1))

[ $# -eq 1 ] || die "exactly one tag name is required (see -h)"
TAG="$1"
[ -n "$MSG" ] || MSG="Release $TAG"

# Must be inside a work tree; operate from its root so submodule paths resolve.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "not inside a Git working tree"
cd "$(git rev-parse --show-toplevel)"

# Refuse to tag a dirty tree. This also catches submodules whose checked-out
# commit differs from the recorded gitlink, or that contain local changes.
if ! git diff-index --quiet HEAD --; then
    die "working tree has uncommitted changes; commit or stash first"
fi

# Don't clobber an existing tag unless -f was given.
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
    [ "$FORCE" -eq 1 ] || die "tag '$TAG' already exists (use -f to overwrite)"
fi

# Flags for the superproject tag (if/then form avoids the set -e && pitfall).
tag_flags=()
if [ "$SIGN" -eq 1 ]; then tag_flags+=(-s); else tag_flags+=(-a); fi
if [ "$FORCE" -eq 1 ]; then tag_flags+=(-f); fi

if [ "$RECURSE" -eq 1 ]; then
    echo ">> Tagging submodules (top-level only, skipping '$SKIP_PATTERN')..."
    # No --recursive: nested submodules of vendored deps often have broken
    # .gitmodules entries and would abort the run. foreach runs each command in
    # a fresh shell per submodule; exported vars are inherited.
    export SM_TAG="$TAG" SM_MSG="$MSG" SM_SIGN="$SIGN" SM_FORCE="$FORCE" SM_SKIP="$SKIP_PATTERN"
    git submodule foreach '
        if [ -n "$SM_SKIP" ]; then
            case "$sm_path" in
                $SM_SKIP) echo "  skipping $sm_path"; exit 0 ;;
            esac
        fi
        flags="-a"
        [ "$SM_SIGN" = "1" ] && flags="-s"
        [ "$SM_FORCE" = "1" ] && flags="$flags -f"
        git tag $flags -m "$SM_MSG" "$SM_TAG"
    '
fi

echo ">> Tagging superproject..."
git tag "${tag_flags[@]}" -m "$MSG" "$TAG"

if [ "$PUSH" -eq 1 ]; then
    # Push submodules before the superproject so their refs exist first.
    if [ "$RECURSE" -eq 1 ]; then
        echo ">> Pushing submodule tags to $REMOTE (skipping '$SKIP_PATTERN')..."
        export SM_REMOTE="$REMOTE" SM_TAG="$TAG" SM_SKIP="$SKIP_PATTERN"
        git submodule foreach '
            if [ -n "$SM_SKIP" ]; then
                case "$sm_path" in
                    $SM_SKIP) echo "  skipping $sm_path"; exit 0 ;;
                esac
            fi
            git push "$SM_REMOTE" "refs/tags/$SM_TAG" \
                || echo "  WARN: could not push tag to $sm_path (continuing)"
        '
    fi
    echo ">> Pushing superproject tag to $REMOTE..."
    git push "$REMOTE" "refs/tags/$TAG"
fi

echo ">> Done: created tag '$TAG'."

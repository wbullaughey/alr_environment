#!/bin/zsh
# gen_docs.zsh -- generate GNATdoc documentation for a project in the
# alr_environment workspace.
#
# Usage:
#   ./gen_docs.zsh                          # document the default project
#   ./gen_docs.zsh path/to/some_project.gpr # document a specific project
#   ./gen_docs.zsh -v path/to/project.gpr   # verbose (show environment info)
#
# Run from anywhere; the script cds to its own directory, which should be
# the crate root (the directory containing alire.toml).

set -e

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Default project to document when none is given on the command line.
DEFAULT_PROJECT="applications/video/camera/unit_test/camera_tests.gpr"

# Directories to exclude when scanning for .gpr files.
EXCLUDE_DIRS=(".git" "obj" "alire" "bin" "lib" "config")

# Extra directories containing .gpr files that projects here depend on.
# Entries may be absolute, or relative to the crate root (this script's
# directory). Each is added to GPR_PROJECT_PATH.
EXTRA_GPR_DIRS=(
    "/System/Volumes/Data/Users/wayne/Desktop/GNAT/gnatcoll-core/minimal"
    "/Users/wayne/Project/git/alr/interfaces/gnoga_lib/gnoga_options"
    "/Users/wayne/Project/git/alr/interfaces"
)

# ---------------------------------------------------------------------------
# Argument handling
# ---------------------------------------------------------------------------

VERBOSE=0
if [[ "$1" == "-v" ]]; then
    VERBOSE=1
    shift
fi

PROJECT="${1:-$DEFAULT_PROJECT}"

# ---------------------------------------------------------------------------
# Move to the crate root (directory containing this script)
# ---------------------------------------------------------------------------

SCRIPT_DIR="${0:A:h}"
cd "$SCRIPT_DIR"

if [[ ! -f alire.toml ]]; then
    print -u2 "error: no alire.toml in $SCRIPT_DIR -- place this script in the crate root."
    exit 1
fi

if [[ ! -f "$PROJECT" ]]; then
    print -u2 "error: project file not found: $PROJECT"
    exit 1
fi

# ---------------------------------------------------------------------------
# Load the Alire build environment (GPR_PROJECT_PATH for dependency crates,
# toolchain PATH, etc.)
# ---------------------------------------------------------------------------

eval "$(alr printenv)"

# ---------------------------------------------------------------------------
# Extend GPR_PROJECT_PATH with every directory in this workspace that
# contains a .gpr file, so sibling/submodule projects resolve without the
# aggregate project.
# ---------------------------------------------------------------------------

# Build the find exclusion arguments from EXCLUDE_DIRS.
FIND_ARGS=()
for d in "${EXCLUDE_DIRS[@]}"; do
    FIND_ARGS+=(-not -path "*/$d/*")
done

LOCAL_GPR_DIRS="$(find "$PWD" -name '*.gpr' "${FIND_ARGS[@]}" -exec dirname {} \; | sort -u | paste -sd: -)"

export GPR_PROJECT_PATH="${GPR_PROJECT_PATH:+$GPR_PROJECT_PATH:}$LOCAL_GPR_DIRS"

# Append the extra directories (relative entries resolve against crate root).
for d in "${EXTRA_GPR_DIRS[@]}"; do
    [[ "$d" != /* ]] && d="$SCRIPT_DIR/${d#./}"
    if [[ -d "$d" ]]; then
        export GPR_PROJECT_PATH="$GPR_PROJECT_PATH:$d"
    else
        print -u2 "warning: extra GPR directory not found, skipping: $d"
    fi
done

if (( VERBOSE )); then
    print "== gnatdoc:        $(command -v gnatdoc || print 'NOT FOUND')"
    print "== project:        $PROJECT"
    print "== GPR_PROJECT_PATH:"
    print -- "$GPR_PROJECT_PATH" | tr ':' '\n' | sed 's/^/     /'
fi

if ! command -v gnatdoc >/dev/null; then
    print -u2 "error: gnatdoc not found on PATH (try: alr install gnatdoc)"
    exit 1
fi

# ---------------------------------------------------------------------------
# Run GNATdoc
# ---------------------------------------------------------------------------

print "Generating documentation for $PROJECT ..."
gnatdoc -P "$PROJECT"

# ---------------------------------------------------------------------------
# Report where the output landed (GNATdoc writes into a gnatdoc/ directory
# under the project's object dir, or the project dir if no object dir).
# ---------------------------------------------------------------------------

PROJ_DIR="${PROJECT:h}"
for candidate in "$PROJ_DIR"/obj/gnatdoc "$PROJ_DIR"/gnatdoc; do
    if [[ -d "$candidate" ]]; then
        print "Documentation generated in: $candidate"
        if [[ -f "$candidate/html/index.html" ]]; then
            print "Open with: open $candidate/html/index.html"
        elif [[ -f "$candidate/index.html" ]]; then
            print "Open with: open $candidate/index.html"
        fi
        exit 0
    fi
done

print "Done. (Output location depends on the project's Object_Dir -- look for a 'gnatdoc' directory there.)"

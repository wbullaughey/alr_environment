#!/bin/bash
# Compile a single source file: walk up from its directory to find the
# nearest build.sh, then run: ./build.sh execute <filename>
#
# Our own status lines are written only to LOG_FILE, never to stdout/stderr,
# so SlickEdit's Build window only sees build.sh's real output (and doesn't
# mistake our status text for an error location).

FILE="$1"
LOG_FILE="/tmp/compile_current_file.log"

if [[ -z "$FILE" ]]; then
   echo "usage: $0 <path-to-source-file>" >> "$LOG_FILE"
   echo "usage: $0 <path-to-source-file>"
   exit 1
fi

BASE=$(basename "$FILE")
echo "=== compile_current_file.sh started $(date) pid $$ compiling $BASE ===" > "$LOG_FILE"

DIR=$(cd "$(dirname "$FILE")" && pwd)

SEARCH_DIR="$DIR"
while [[ "$SEARCH_DIR" != "/" ]]; do
   if [[ -f "$SEARCH_DIR/build.sh" ]]; then
      cd "$SEARCH_DIR" || exit 1
      echo "found build.sh in $(basename "$SEARCH_DIR")" >> "$LOG_FILE"
      exec > >(tee -a "$LOG_FILE") 2>&1
      exec ./build.sh execute "$BASE"
   fi
   SEARCH_DIR=$(dirname "$SEARCH_DIR")
done

echo "no build.sh found above this file" >> "$LOG_FILE"
echo "no build.sh found above this file"
exit 1

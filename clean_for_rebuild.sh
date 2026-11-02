#!/bin/sh
# clean_for_rebuild.sh
# Works on macOS, Linux, BSD, etc.
# Usage: ./clean_for_rebuild.sh o ali stderr stdout s

if [ $# -eq 0 ]; then
    echo "Usage: $0 extension1 extension2 ..."
    echo "Example: $0 o ali stderr stdout s"
    exit 1
fi

# Convert extensions to lowercase safely (macOS/BSD compatible)
EXTS=""
for ext in "$@"; do
    # Use tr instead of ${var,,} which is bash-only
    lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    if [ -n "$EXTS" ]; then
        EXTS="$EXTS|$lower"
    else
        EXTS="$lower"
    fi
    printf "   *.%s\n" "$lower"
done

echo "WARNING: Will delete all files matching these extensions (case-insensitive)"
echo "in the current directory and ALL subdirectories recursively."
echo

# Count files first
echo "Scanning for files..."
TOTAL=0
for ext in "$@"; do
    count=$(find . -type f -iname "*.$ext" | grep -v "/.git/" | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        printf "   %4d  *.%s\n" "$count" "$(echo $ext | tr '[:upper:]' '[:lower:]')"
        TOTAL=$((TOTAL + count))
    fi
done

echo "   ----"
printf "   %4d  files total\n" "$TOTAL"

if [ "$TOTAL" -eq 0 ]; then
    echo "Nothing to delete."
    exit 0
fi

echo
printf "Type YES to permanently delete these %d files: " "$TOTAL"
read -r answer
echo

if [ "$answer" = "YES" ]; then
    echo "Deleting..."
    for ext in "$@"; do
        find . -type f -iname "*.$ext" -print -delete
    done
    echo "Done. $TOTAL files removed."
else
    echo "Cancelled. No files were deleted."
fi

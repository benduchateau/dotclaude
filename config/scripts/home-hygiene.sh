#!/usr/bin/env bash
# Home directory hygiene check
# Flags loose files and unexpected directories in ~/

# Directories expected in ~/. Override by setting HYGIENE_ALLOWED_DIRS in env.
ALLOWED_DIRS="${HYGIENE_ALLOWED_DIRS:-projects}"
HOME_DIR="$HOME"
issues=0

# Check for loose files (non-dotfiles)
loose_files=$(find "$HOME_DIR" -maxdepth 1 -type f -not -name ".*" 2>/dev/null)
if [ -n "$loose_files" ]; then
    echo "⚠ Loose files in ~/:"
    echo "$loose_files" | while read -r f; do echo "  $(basename "$f")"; done
    issues=$((issues + $(echo "$loose_files" | wc -l)))
fi

# Check for unexpected directories (non-dotfiles, not in allowed list)
while IFS= read -r dir; do
    dirname=$(basename "$dir")
    if ! echo "$ALLOWED_DIRS" | grep -qw "$dirname"; then
        echo "⚠ Unexpected directory: ~/$dirname"
        issues=$((issues + 1))
    fi
done < <(find "$HOME_DIR" -maxdepth 1 -mindepth 1 -type d -not -name ".*" 2>/dev/null)

# Check for Zone.Identifier files anywhere in projects
zone_files=$(find "$HOME_DIR/projects" -name "*Zone.Identifier" 2>/dev/null | wc -l)
if [ "$zone_files" -gt 0 ]; then
    echo "⚠ $zone_files Zone.Identifier file(s) in projects/"
    issues=$((issues + 1))
fi

if [ "$issues" -eq 0 ]; then
    echo "✓ Home directory is clean"
fi

exit 0

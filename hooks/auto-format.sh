#!/bin/bash
# Auto-format files after Claude edits them
# Runs Prettier if available in the project, skips silently if not

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file_path // empty')

# Skip if no file path
[ -z "$FILE_PATH" ] && exit 0

# Skip non-formattable files
case "$FILE_PATH" in
  *.md|*.json|*.yaml|*.yml|*.png|*.jpg|*.jpeg|*.gif|*.svg|*.avif|*.webp|*.ico|*.lock)
    exit 0
    ;;
esac

# Only format if prettier is available in the project
if command -v npx >/dev/null 2>&1 && [ -f "$FILE_PATH" ]; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
fi

exit 0

#!/bin/bash
# Auto-format files after Claude edits them.
# Runs Prettier if available in the project, skips silently if not.
# Uses python3 for JSON parsing (jq may not be installed).

FILE_PATH=$(python3 -c 'import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("file_path", ""))
except Exception:
    pass' 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *.md|*.json|*.yaml|*.yml|*.png|*.jpg|*.jpeg|*.gif|*.svg|*.avif|*.webp|*.ico|*.lock)
    exit 0
    ;;
esac

if command -v npx >/dev/null 2>&1 && [ -f "$FILE_PATH" ]; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
fi

exit 0

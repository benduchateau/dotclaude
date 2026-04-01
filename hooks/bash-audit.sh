#!/bin/bash
# Log every Bash command Claude runs to an audit file
# Format: timestamp | working directory | command

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$COMMAND" ] && exit 0

LOGFILE="$HOME/.claude/bash-audit.log"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "$TIMESTAMP | $CWD | $COMMAND" >> "$LOGFILE"

exit 0

#!/bin/bash
# Log every Bash command Claude runs to an audit file.
# Format: timestamp | working directory | command
# Uses python3 for JSON parsing (jq may not be installed).

read_input=$(python3 -c 'import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("command", ""))
    print(d.get("cwd", ""))
except Exception:
    print("")
    print("")' 2>/dev/null)

COMMAND=$(echo "$read_input" | sed -n '1p')
CWD=$(echo "$read_input" | sed -n '2p')

[ -z "$COMMAND" ] && exit 0

LOGFILE="$HOME/.claude/bash-audit.log"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "$TIMESTAMP | $CWD | $COMMAND" >> "$LOGFILE"

exit 0

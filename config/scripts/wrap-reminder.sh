#!/bin/bash
# Remind user to run /wrap before exiting
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null)

if echo "$PROMPT" | grep -qiE '^\s*(/exit|exit|quit|bye)\s*$'; then
  echo '{"systemMessage": "Run /wrap first to save session state (todos, lessons, decisions, stray file check)"}'
fi

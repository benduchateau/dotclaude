#!/usr/bin/env bash
# Runs the Six Month Vision skill via the claude CLI.
# Called by the cron job or manually.

set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills/six-month-vision"
REPORT_DIR="${HOME}/.claude/six-month-vision/reports"
LOG_FILE="${HOME}/.claude/six-month-vision/six-month-vision.log"
DATE=$(date +"%Y-%m-%d")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p "${REPORT_DIR}"

log() {
  echo "[${TIMESTAMP}] $*" | tee -a "${LOG_FILE}"
}

log "Starting Six Month Vision run"

# Build the prompt that invokes the skill
PROMPT=$(cat <<'PROMPT_EOF'
/six-month-vision

Today is $(date +"%A, %B %-d, %Y"). Run the full Six Month Vision scan now.

Search the web broadly across all source categories in references/ai-sources.md. Gather real, current intelligence — do not rely on training data for recent events. After researching, produce the complete strategy report in the specified output format.

Save the completed report to: ${REPORT_DIR}/${DATE}.md
PROMPT_EOF
)

# Resolve variables in prompt
PROMPT=$(DATE="${DATE}" REPORT_DIR="${REPORT_DIR}" envsubst <<< "${PROMPT}")

# Invoke claude CLI in non-interactive mode
# --print outputs the result without opening an interactive session
if command -v claude &>/dev/null; then
  log "Invoking claude CLI"
  claude \
    --print \
    --dangerously-skip-permissions \
    -p "${PROMPT}" \
    >> "${LOG_FILE}" 2>&1
  EXIT_CODE=$?
  if [ "${EXIT_CODE}" -eq 0 ]; then
    log "Run completed successfully. Report: ${REPORT_DIR}/${DATE}.md"
  else
    log "ERROR: claude exited with code ${EXIT_CODE}"
    exit "${EXIT_CODE}"
  fi
else
  log "ERROR: claude CLI not found in PATH. Install from: https://claude.ai/code"
  exit 1
fi

#!/usr/bin/env bash
# Installs the Six Month Vision daily cron job at 8pm NZST (08:00 UTC).
# Run once per machine to activate nightly AI trend scanning.
#
# Usage: bash setup-cron.sh [--uninstall]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_SCRIPT="${HOME}/.claude/skills/six-month-vision/scripts/run-vision.sh"
LOG_DIR="${HOME}/.claude/six-month-vision"
LOG_FILE="${LOG_DIR}/six-month-vision.log"
REPORT_DIR="${LOG_DIR}/reports"

# 8pm NZST = UTC+13 (NZDT) or UTC+12 (NZST standard)
# 8pm NZST = 08:00 UTC (standard) / 07:00 UTC (daylight saving)
# Using 08:00 UTC as the safe standard-time anchor.
CRON_SCHEDULE="0 8 * * *"
CRON_COMMENT="six-month-vision"
CRON_LINE="${CRON_SCHEDULE} bash ${RUN_SCRIPT} >> ${LOG_FILE} 2>&1 # ${CRON_COMMENT}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[setup]${NC} $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}  $*"; }
error()   { echo -e "${RED}[error]${NC} $*"; exit 1; }

# ── Uninstall ─────────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--uninstall" ]]; then
  if crontab -l 2>/dev/null | grep -q "${CRON_COMMENT}"; then
    crontab -l 2>/dev/null | grep -v "${CRON_COMMENT}" | crontab -
    info "Cron job removed."
  else
    warn "No six-month-vision cron job found — nothing to remove."
  fi
  exit 0
fi

# ── Pre-flight checks ─────────────────────────────────────────────────────────

info "Running pre-flight checks..."

if ! command -v claude &>/dev/null; then
  error "claude CLI not found. Install Claude Code from https://claude.ai/code and ensure it is in PATH."
fi

if ! command -v crontab &>/dev/null; then
  error "crontab not available on this system."
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
info "claude CLI found: ${CLAUDE_VERSION}"

# ── Directories ───────────────────────────────────────────────────────────────

mkdir -p "${LOG_DIR}" "${REPORT_DIR}"
info "Report directory: ${REPORT_DIR}"
info "Log file:         ${LOG_FILE}"

# ── Copy run script to ~/.claude/skills location ──────────────────────────────

SKILLS_DIR="${HOME}/.claude/skills/six-month-vision/scripts"
mkdir -p "${SKILLS_DIR}"

if [ "${SCRIPT_DIR}" != "${SKILLS_DIR}" ]; then
  cp "${SCRIPT_DIR}/run-vision.sh" "${SKILLS_DIR}/run-vision.sh"
  info "Copied run-vision.sh to ${SKILLS_DIR}/"
fi

chmod +x "${RUN_SCRIPT}"
info "Made run-vision.sh executable."

# ── Install cron job ──────────────────────────────────────────────────────────

if crontab -l 2>/dev/null | grep -q "${CRON_COMMENT}"; then
  warn "Cron job already exists. Replacing..."
  crontab -l 2>/dev/null | grep -v "${CRON_COMMENT}" | crontab -
fi

(crontab -l 2>/dev/null; echo "${CRON_LINE}") | crontab -

info "Cron job installed:"
info "  Schedule: ${CRON_SCHEDULE} (08:00 UTC = 8pm NZST)"
info "  Command:  bash ${RUN_SCRIPT}"
info "  Log:      ${LOG_FILE}"

# ── Verify ────────────────────────────────────────────────────────────────────

echo ""
info "Verifying installation..."
if crontab -l 2>/dev/null | grep -q "${CRON_COMMENT}"; then
  echo ""
  echo "  Installed cron entry:"
  crontab -l | grep "${CRON_COMMENT}"
  echo ""
  info "Six Month Vision is active. First report will be generated at 8pm NZST tonight."
  info "To run immediately: bash ${RUN_SCRIPT}"
  info "To uninstall:       bash ${BASH_SOURCE[0]} --uninstall"
  info "Reports saved to:   ${REPORT_DIR}/"
else
  error "Cron job installation failed — check crontab permissions."
fi

# ── Timezone note ─────────────────────────────────────────────────────────────

echo ""
warn "Timezone note: The cron runs at 08:00 UTC."
warn "  NZST (UTC+12): runs at 8:00pm ✓"
warn "  NZDT (UTC+13, Oct–Apr): runs at 9:00pm"
warn "  Adjust CRON_SCHEDULE to '0 7 * * *' during daylight saving if exact 8pm is required."

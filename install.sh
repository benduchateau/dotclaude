#!/usr/bin/env bash
# Engine AI — dotclaude installer
# Installs skills, statusline, hooks, and scripts into ~/.claude/
# Safe: backs up anything it would overwrite, asks before touching CLAUDE.md or settings.json.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
BACKUP_DIR="${CLAUDE_DIR}/backups/dotclaude-$(date -u +%Y%m%dT%H%M%SZ)"

GOLD='\033[38;2;196;163;90m'
GREEN='\033[32m'
YELLOW='\033[33m'
DIM='\033[2m'
RESET='\033[0m'

say()   { printf "${GOLD}▸${RESET} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${RESET} %s\n" "$*"; }
warn()  { printf "${YELLOW}⚠${RESET} %s\n" "$*"; }
dim()   { printf "${DIM}  %s${RESET}\n" "$*"; }

confirm() {
  local prompt="$1"
  read -r -p "$(printf "${YELLOW}?${RESET} %s [y/N] " "$prompt")" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# ── Preflight ──────────────────────────────────────
say "Engine AI dotclaude installer"
dim "Repo: $REPO_DIR"
dim "Target: $CLAUDE_DIR"

if [ ! -d "$CLAUDE_DIR" ]; then
  warn "$CLAUDE_DIR does not exist. Creating."
  mkdir -p "$CLAUDE_DIR"
fi

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/scripts" "$CLAUDE_DIR/hooks" "$BACKUP_DIR"
ok "Backup dir: $BACKUP_DIR"

# ── Skills ─────────────────────────────────────────
say "Installing skills"
skill_count=0
for category in "$REPO_DIR"/*/; do
  cat_name=$(basename "$category")
  # Skip non-skill folders
  case "$cat_name" in
    config|.git|tasks|docs|dist) continue ;;
  esac
  # Top-level skill (SKILL.md directly under folder)
  if [ -f "${category}SKILL.md" ]; then
    dest="$CLAUDE_DIR/skills/$cat_name"
    [ -d "$dest" ] && cp -r "$dest" "$BACKUP_DIR/skill-$cat_name" 2>/dev/null || true
    cp -r "$category" "$dest"
    skill_count=$((skill_count + 1))
    continue
  fi
  # Category folder with sub-skills
  for sub in "$category"*/; do
    [ -f "${sub}SKILL.md" ] || continue
    sub_name=$(basename "$sub")
    dest="$CLAUDE_DIR/skills/$sub_name"
    [ -d "$dest" ] && cp -r "$dest" "$BACKUP_DIR/skill-$sub_name" 2>/dev/null || true
    cp -r "$sub" "$dest"
    skill_count=$((skill_count + 1))
  done
done
ok "Installed $skill_count skills into $CLAUDE_DIR/skills/"

# ── Scripts ────────────────────────────────────────
say "Installing scripts (statusline, session hooks)"
for f in "$REPO_DIR"/config/scripts/*; do
  name=$(basename "$f")
  dest="$CLAUDE_DIR/scripts/$name"
  [ -f "$dest" ] && cp "$dest" "$BACKUP_DIR/script-$name" 2>/dev/null || true
  cp "$f" "$dest"
  chmod +x "$dest"
done
ok "Installed scripts into $CLAUDE_DIR/scripts/"

# ── Hooks ──────────────────────────────────────────
say "Installing hooks (auto-format, bash-audit, clear-image-cache)"
for f in "$REPO_DIR"/config/hooks/*; do
  name=$(basename "$f")
  dest="$CLAUDE_DIR/hooks/$name"
  [ -f "$dest" ] && cp "$dest" "$BACKUP_DIR/hook-$name" 2>/dev/null || true
  cp "$f" "$dest"
  chmod +x "$dest"
done
ok "Installed hooks into $CLAUDE_DIR/hooks/"

# ── CLAUDE.md ──────────────────────────────────────
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  warn "$CLAUDE_DIR/CLAUDE.md already exists."
  if confirm "Replace with Engine AI template (backup kept)?"; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
    cp "$REPO_DIR/config/templates/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md"
    ok "Installed CLAUDE.md template — edit it to personalise."
  else
    dim "Kept existing CLAUDE.md"
  fi
else
  cp "$REPO_DIR/config/templates/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md"
  ok "Installed CLAUDE.md template — edit it to personalise."
fi

# ── settings.json ──────────────────────────────────
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  warn "$CLAUDE_DIR/settings.json already exists."
  if confirm "Replace with Engine AI template (backup kept — existing plugins + permissions will be lost)?"; then
    cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/settings.json"
    cp "$REPO_DIR/config/templates/settings.json.template" "$CLAUDE_DIR/settings.json"
    ok "Installed settings.json template."
  else
    dim "Kept existing settings.json — merge hooks/statusLine sections manually from config/templates/settings.json.template"
  fi
else
  cp "$REPO_DIR/config/templates/settings.json.template" "$CLAUDE_DIR/settings.json"
  ok "Installed settings.json template."
fi

# ── Done ───────────────────────────────────────────
printf "\n"
ok "Install complete."
dim "Backup: $BACKUP_DIR"
dim "Next: restart Claude Code to pick up the new statusline and hooks."
dim "Optional: export OPENCLAW_HOST in your shell rc if you run an OpenClaw server."

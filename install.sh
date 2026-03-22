#!/usr/bin/env bash
#
# dotclaude installer
# Symlinks this repo's contents into ~/.claude/
# Safe to re-run. Backs up existing files before overwriting.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/dotclaude-$(date +%Y%m%d-%H%M%S)"

# Colours
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

mkdir -p "$CLAUDE_DIR"

# Backup and symlink a file or directory
# Usage: link_item <source_relative_path> <target_path>
link_item() {
    local src="$SCRIPT_DIR/$1"
    local dst="$CLAUDE_DIR/$2"

    if [ ! -e "$src" ]; then
        warn "Source not found: $src (skipping)"
        return
    fi

    # If target exists and is not already our symlink, back it up
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$2"
        mkdir -p "$(dirname "$backup_path")"
        mv "$dst" "$backup_path"
        warn "Backed up existing $dst -> $backup_path"
    elif [ -L "$dst" ]; then
        rm "$dst"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    ln -s "$src" "$dst"
    info "Linked $2"
}

echo ""
echo "=== dotclaude installer ==="
echo "Source: $SCRIPT_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Top-level files
link_item "CLAUDE.md" "CLAUDE.md"
link_item "engagement-context.md" "engagement-context.md"
link_item "settings.json" "settings.json"
link_item "statusline-command.sh" "statusline-command.sh"

# Directories (link each file to preserve existing directory structure)
for file in commands/*.md; do
    [ -f "$file" ] && link_item "$file" "$file"
done

for file in scripts/*; do
    [ -f "$file" ] && link_item "$file" "$file"
done

for file in templates/*; do
    [ -f "$file" ] && link_item "$file" "$file"
done

# Skills (link each skill directory)
for skill_dir in skills/*/; do
    skill_name="$(basename "$skill_dir")"
    link_item "skills/$skill_name" "skills/$skill_name"
done

# Standalone skill file
if [ -f "skills/Stellar-Immigration-Agent-Skill.md" ]; then
    link_item "skills/Stellar-Immigration-Agent-Skill.md" "skills/Stellar-Immigration-Agent-Skill.md"
fi

# Memory files
MEMORY_DIR="$CLAUDE_DIR/projects/-home-duchats/memory"
mkdir -p "$MEMORY_DIR"
for file in memory/*; do
    [ -f "$file" ] && {
        local_name="$(basename "$file")"
        src="$SCRIPT_DIR/$file"
        dst="$MEMORY_DIR/$local_name"

        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            mkdir -p "$BACKUP_DIR/memory"
            mv "$dst" "$BACKUP_DIR/memory/$local_name"
            warn "Backed up existing memory/$local_name"
        elif [ -L "$dst" ]; then
            rm "$dst"
        fi

        ln -s "$src" "$dst"
        info "Linked memory/$local_name"
    }
done

echo ""
info "Done. Existing files backed up to: $BACKUP_DIR"
echo ""
echo "Note: settings.local.json is machine-specific and not managed by this repo."
echo "      Plugins (gstack, superpowers, etc.) are installed separately via Claude Code."
echo ""

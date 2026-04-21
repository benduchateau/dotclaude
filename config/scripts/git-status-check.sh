#!/usr/bin/env bash
# Git status check across ~/projects/
# Flags repos with uncommitted changes, unpushed commits, or stale branches

PROJECTS_DIR="$HOME/projects"
issues=0

if [ ! -d "$PROJECTS_DIR" ]; then
    echo "✓ No projects directory"
    exit 0
fi

for repo in "$PROJECTS_DIR"/*/; do
    [ -d "$repo/.git" ] || continue
    name=$(basename "$repo")

    # Uncommitted changes (staged + unstaged + untracked)
    dirty=$(git -C "$repo" status --porcelain 2>/dev/null | head -20)
    if [ -n "$dirty" ]; then
        count=$(echo "$dirty" | wc -l)
        echo "⚠ $name: $count uncommitted change(s)"
        issues=$((issues + 1))
    fi

    # Unpushed commits on current branch
    branch=$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        upstream=$(git -C "$repo" rev-parse --abbrev-ref "@{upstream}" 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$repo" rev-list --count "$upstream..HEAD" 2>/dev/null || echo 0)
            if [ "$ahead" -gt 0 ]; then
                echo "⚠ $name: $ahead unpushed commit(s) on $branch"
                issues=$((issues + 1))
            fi
        fi
    fi
done

if [ "$issues" -eq 0 ]; then
    echo "✓ All projects clean"
fi

exit 0

#!/usr/bin/env python3
"""Check if project session files have changed since last wiki sync."""

import os
import json
import sys
from pathlib import Path

WIKI_DIR = Path.home() / "wiki"
SYNC_STATE = WIKI_DIR / ".last-sync"
PROJECTS_DIR = Path.home() / "projects"
MEMORY_DIR = Path.home() / ".claude" / "projects"

# Files to watch in each project
WATCH_FILES = ["tasks/lessons.md", "docs/decisions.md"]


def get_last_sync():
    """Get timestamp of last wiki sync."""
    if SYNC_STATE.exists():
        try:
            data = json.loads(SYNC_STATE.read_text())
            return data.get("timestamp", 0)
        except (json.JSONDecodeError, KeyError):
            return 0
    return 0


def check_project_files(last_sync):
    """Check project session files for changes since last sync."""
    changed = []
    if not PROJECTS_DIR.exists():
        return changed

    for project in sorted(PROJECTS_DIR.iterdir()):
        if not project.is_dir() or project.name.startswith("."):
            continue
        for watch_file in WATCH_FILES:
            path = project / watch_file
            if path.exists() and path.stat().st_mtime > last_sync:
                changed.append(f"{project.name}/{watch_file}")
    return changed


def check_memory_files(last_sync):
    """Check Claude memory files for changes since last sync."""
    changed = 0
    if not MEMORY_DIR.exists():
        return changed

    for memory_file in MEMORY_DIR.rglob("*.md"):
        if memory_file.name == "MEMORY.md":
            continue
        if memory_file.stat().st_mtime > last_sync:
            changed += 1
    return changed


def main():
    if not WIKI_DIR.exists():
        return

    last_sync = get_last_sync()

    if last_sync == 0:
        print("⚠ Wiki has never been synced. Run a sync to pull in project knowledge.")
        return

    project_changes = check_project_files(last_sync)
    memory_changes = check_memory_files(last_sync)

    parts = []
    if project_changes:
        projects = set(c.split("/")[0] for c in project_changes)
        parts.append(f"{len(projects)} project(s) with updated session files")
    if memory_changes:
        parts.append(f"{memory_changes} new memory file(s)")

    if parts:
        print(f"⚠ Wiki sync available: {', '.join(parts)}")
        if project_changes:
            for change in project_changes[:5]:
                print(f"  - {change}")
            if len(project_changes) > 5:
                print(f"  ... and {len(project_changes) - 5} more")
    else:
        print("✓ Wiki up to date")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
dotclaude sync — syncs live ~/.claude/ config to ~/dotclaude/ repo.

Compares live files against the repo, shows a diff summary, then
optionally copies, commits, and pushes.

Usage:
    python3 ~/dotclaude/sync.py              # preview what would sync
    python3 ~/dotclaude/sync.py --apply      # sync, commit, push
    python3 ~/dotclaude/sync.py --apply --no-push   # sync + commit only
    python3 ~/dotclaude/sync.py --reverse    # pull repo into ~/.claude/ (for new machines)
"""

import argparse
import filecmp
import os
import shutil
import subprocess
import sys
from pathlib import Path

# ── Paths ──────────────────────────────────────────────────────────────
LIVE = Path.home() / ".claude"
REPO = Path.home() / "dotclaude"

# ── What to sync ───────────────────────────────────────────────────────
# Top-level files: (live relative path, repo relative path)
TOP_FILES = [
    ("CLAUDE.md", "CLAUDE.md"),
    ("settings.json", "settings.json"),
    # settings.local.json excluded: machine-specific, gitignored
    ("statusline-command.sh", "statusline-command.sh"),
    ("engagement-context.md", "engagement-context.md"),
]

# Directories to sync recursively: (live relative, repo relative)
SYNC_DIRS = [
    ("commands", "commands"),
    ("templates", "templates"),
    ("scripts", "scripts"),
    ("hooks", "hooks"),
]

# Skills from gstack submodule (don't copy these to repo as standalone dirs).
# We read this dynamically from the submodule.
def get_gstack_skills() -> set:
    """Return set of skill names provided by the gstack submodule."""
    gstack_dir = REPO / "skills" / "gstack"
    if not gstack_dir.is_dir():
        return set()
    # gstack provides skills as subdirectories (not .md files at root)
    skills = set()
    for entry in gstack_dir.iterdir():
        if entry.is_dir() and not entry.name.startswith("."):
            skills.add(entry.name)
    # Also add "gstack" itself since that's the submodule dir
    skills.add("gstack")
    return skills


# ── Exclude patterns ──────────────────────────────────────────────────
EXCLUDE_FILES = {
    ".credentials.json",
    ".mcp.json",
    "history.jsonl",
    "stats-cache.json",
    "mcp-needs-auth-cache.json",
    "launch.json",
}

EXCLUDE_EXTENSIONS = {
    ".Identifier",  # Zone.Identifier files from Windows
    ".pyc",
    ".pyo",
    ".so",
    ".dylib",
    ".whl",
}

EXCLUDE_DIRS = {
    "cache",
    "channels",
    "debug",
    "file-history",
    "ide",
    "paste-cache",
    "plans",
    "plugins",
    "projects",
    "session-env",
    "sessions",
    "shell-snapshots",
    "telemetry",
    "todos",
    "usage-data",
    "backups",
}

# Directories to skip when walking inside synced dirs (e.g. inside skills)
EXCLUDE_SUBDIRS = {
    ".venv",
    "venv",
    "node_modules",
    "__pycache__",
    ".git",
    ".cache",
    "dist",
    "build",
    ".next",
    "data",
    "browser_state",
    "browser_profile",
}


def should_skip_file(path: Path) -> bool:
    """Check if a file should be excluded from sync."""
    if path.name in EXCLUDE_FILES:
        return True
    if any(path.name.endswith(ext) for ext in EXCLUDE_EXTENSIONS):
        return True
    if path.name.startswith("."):
        return True
    return False


# ── Comparison ─────────────────────────────────────────────────────────
class SyncAction:
    def __init__(self, src: Path, dst: Path, action: str, label: str):
        self.src = src
        self.dst = dst
        self.action = action  # "new", "updated", "deleted"
        self.label = label    # human-readable relative path

    def __repr__(self):
        icons = {"new": "+", "updated": "~", "deleted": "-"}
        return f"  {icons.get(self.action, '?')} {self.label}"


def compare_files(src: Path, dst: Path) -> bool:
    """Return True if files differ (or dst doesn't exist)."""
    if not dst.exists():
        return True
    if not src.exists():
        return False
    return not filecmp.cmp(src, dst, shallow=False)


def diff_top_files() -> list:
    """Compare top-level config files."""
    actions = []
    for live_rel, repo_rel in TOP_FILES:
        src = LIVE / live_rel
        dst = REPO / repo_rel
        if not src.exists():
            continue
        if should_skip_file(src):
            continue
        if compare_files(src, dst):
            action = "new" if not dst.exists() else "updated"
            actions.append(SyncAction(src, dst, action, repo_rel))
    return actions


def diff_directory(live_rel: str, repo_rel: str) -> list:
    """Compare a directory recursively."""
    actions = []
    src_dir = LIVE / live_rel
    dst_dir = REPO / repo_rel

    if not src_dir.is_dir():
        return actions

    # Files in live but not in repo, or different
    for root, dirs, files in os.walk(src_dir):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_SUBDIRS]
        root_path = Path(root)
        rel = root_path.relative_to(src_dir)
        for f in files:
            src_file = root_path / f
            if should_skip_file(src_file):
                continue
            dst_file = dst_dir / rel / f
            label = str(Path(repo_rel) / rel / f)
            if compare_files(src_file, dst_file):
                action = "new" if not dst_file.exists() else "updated"
                actions.append(SyncAction(src_file, dst_file, action, label))

    # Files in repo but not in live (deleted)
    if dst_dir.is_dir():
        for root, dirs, files in os.walk(dst_dir):
            dirs[:] = [d for d in dirs if d not in EXCLUDE_SUBDIRS]
            root_path = Path(root)
            rel = root_path.relative_to(dst_dir)
            for f in files:
                dst_file = root_path / f
                src_file = src_dir / rel / f
                label = str(Path(repo_rel) / rel / f)
                if not src_file.exists() and not should_skip_file(dst_file):
                    actions.append(SyncAction(src_file, dst_file, "deleted", label))

    return actions


def diff_skills() -> list:
    """Compare skills, excluding gstack-provided ones."""
    actions = []
    gstack_skills = get_gstack_skills()
    src_dir = LIVE / "skills"
    dst_dir = REPO / "skills"

    if not src_dir.is_dir():
        return actions

    for entry in sorted(src_dir.iterdir()):
        name = entry.name

        # Skip gstack-provided skills
        if name in gstack_skills:
            continue

        if should_skip_file(entry):
            continue

        if entry.is_file():
            # Standalone skill files (e.g., Stellar-Immigration-Agent-Skill.md)
            dst_file = dst_dir / name
            if compare_files(entry, dst_file):
                action = "new" if not dst_file.exists() else "updated"
                actions.append(SyncAction(entry, dst_file, action, f"skills/{name}"))

        elif entry.is_dir():
            # Skill directories with SKILL.md etc.
            for root, dirs, files in os.walk(entry):
                dirs[:] = [d for d in dirs if d not in EXCLUDE_SUBDIRS]
                root_path = Path(root)
                rel = root_path.relative_to(src_dir)
                for f in files:
                    src_file = root_path / f
                    if should_skip_file(src_file):
                        continue
                    dst_file = dst_dir / rel / f
                    label = f"skills/{rel}/{f}"
                    if compare_files(src_file, dst_file):
                        action = "new" if not dst_file.exists() else "updated"
                        actions.append(SyncAction(src_file, dst_file, action, label))

    # Check for skills in repo that were removed from live (excluding gstack)
    if dst_dir.is_dir():
        for entry in sorted(dst_dir.iterdir()):
            name = entry.name
            if name in gstack_skills or should_skip_file(entry):
                continue
            src_entry = src_dir / name

            if entry.is_file() and not src_entry.exists():
                actions.append(SyncAction(src_entry, entry, "deleted", f"skills/{name}"))

            elif entry.is_dir() and not src_entry.exists():
                for root, dirs, files in os.walk(entry):
                    dirs[:] = [d for d in dirs if d not in EXCLUDE_SUBDIRS]
                    root_path = Path(root)
                    rel = root_path.relative_to(dst_dir)
                    for f in files:
                        dst_file = root_path / f
                        label = f"skills/{rel}/{f}"
                        actions.append(SyncAction(src_dir / rel / f, dst_file, "deleted", label))

    return actions


def diff_memory() -> list:
    """Compare memory files (project-level memories)."""
    actions = []
    # Live memory is in the projects directory for the home context
    src_dir = LIVE / "projects" / "-home-duchats" / "memory"
    dst_dir = REPO / "memory"

    if not src_dir.is_dir():
        return actions

    for f in sorted(src_dir.iterdir()):
        if should_skip_file(f) or not f.is_file():
            continue
        dst = dst_dir / f.name
        if compare_files(f, dst):
            action = "new" if not dst.exists() else "updated"
            actions.append(SyncAction(f, dst, action, f"memory/{f.name}"))

    # Deleted from live
    if dst_dir.is_dir():
        for f in sorted(dst_dir.iterdir()):
            if should_skip_file(f) or not f.is_file():
                continue
            src = src_dir / f.name
            if not src.exists():
                actions.append(SyncAction(src, f, "deleted", f"memory/{f.name}"))

    return actions


# ── Apply ──────────────────────────────────────────────────────────────
def apply_actions(actions: list):
    """Execute the sync actions."""
    for a in actions:
        if a.action == "deleted":
            if a.dst.exists():
                a.dst.unlink()
                print(f"  Deleted: {a.label}")
        else:
            a.dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(a.src, a.dst)
            print(f"  Copied:  {a.label}")

    # Clean up empty directories in repo
    for dirpath, dirnames, filenames in os.walk(REPO, topdown=False):
        p = Path(dirpath)
        if p == REPO:
            continue
        if not any(p.iterdir()) and ".git" not in str(p):
            p.rmdir()


def git_commit_and_push(actions: list, push: bool = True):
    """Stage, commit, and optionally push."""
    os.chdir(REPO)

    # Stage all changes
    subprocess.run(["git", "add", "-A"], check=True)

    # Check if there's anything to commit
    result = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        capture_output=True
    )
    if result.returncode == 0:
        print("\n  Nothing to commit (working tree clean after staging).")
        return

    # Build commit message
    new = sum(1 for a in actions if a.action == "new")
    updated = sum(1 for a in actions if a.action == "updated")
    deleted = sum(1 for a in actions if a.action == "deleted")
    parts = []
    if new:
        parts.append(f"{new} new")
    if updated:
        parts.append(f"{updated} updated")
    if deleted:
        parts.append(f"{deleted} deleted")
    summary = ", ".join(parts)
    msg = f"sync: {summary}"

    subprocess.run(["git", "commit", "-m", msg], check=True)
    print(f"\n  Committed: {msg}")

    if push:
        subprocess.run(["git", "push"], check=True)
        print("  Pushed to remote.")
    else:
        print("  Skipped push (--no-push).")


def reverse_sync(actions: list):
    """Pull repo files INTO ~/.claude/ (for bootstrapping new machines)."""
    for a in actions:
        # Swap src/dst logic for reverse
        if a.action == "deleted":
            # File exists in repo but not live: copy to live
            # Need to figure out the live path from the label
            pass
        # For simplicity, just copy everything from repo to live
    print("  Reverse sync: copying repo -> live")
    for live_rel, repo_rel in TOP_FILES:
        src = REPO / repo_rel
        dst = LIVE / live_rel
        if src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            print(f"    {repo_rel}")

    for live_rel, repo_rel in SYNC_DIRS:
        src_dir = REPO / repo_rel
        dst_dir = LIVE / live_rel
        if not src_dir.is_dir():
            continue
        for root, dirs, files in os.walk(src_dir):
            root_path = Path(root)
            rel = root_path.relative_to(src_dir)
            for f in files:
                src = root_path / f
                dst = dst_dir / rel / f
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
                print(f"    {live_rel}/{rel}/{f}")

    # Skills (skip gstack, it needs submodule init)
    gstack_skills = get_gstack_skills()
    src_dir = REPO / "skills"
    dst_dir = LIVE / "skills"
    if src_dir.is_dir():
        for entry in sorted(src_dir.iterdir()):
            if entry.name in gstack_skills or should_skip_file(entry):
                continue
            dst_entry = dst_dir / entry.name
            if entry.is_file():
                dst_entry.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(entry, dst_entry)
                print(f"    skills/{entry.name}")
            elif entry.is_dir():
                if dst_entry.exists():
                    shutil.rmtree(dst_entry)
                shutil.copytree(entry, dst_entry)
                print(f"    skills/{entry.name}/")

    print("\n  Reverse sync complete. Run 'cd ~/dotclaude && git submodule update --init' for gstack.")


# ── Main ───────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="Sync ~/.claude/ config to ~/dotclaude/ repo")
    parser.add_argument("--apply", action="store_true", help="Apply changes (default is dry-run preview)")
    parser.add_argument("--no-push", action="store_true", help="Commit but don't push")
    parser.add_argument("--reverse", action="store_true", help="Pull repo into ~/.claude/ (new machine setup)")
    args = parser.parse_args()

    print(f"\n  dotclaude sync")
    print(f"  Live:  {LIVE}")
    print(f"  Repo:  {REPO}\n")

    # Gather all diffs
    all_actions = []
    all_actions.extend(diff_top_files())
    for live_rel, repo_rel in SYNC_DIRS:
        all_actions.extend(diff_directory(live_rel, repo_rel))
    all_actions.extend(diff_skills())
    all_actions.extend(diff_memory())

    if not all_actions:
        print("  Everything is in sync. Nothing to do.\n")
        return

    # Print summary
    new = [a for a in all_actions if a.action == "new"]
    updated = [a for a in all_actions if a.action == "updated"]
    deleted = [a for a in all_actions if a.action == "deleted"]

    if new:
        print(f"  NEW ({len(new)}):")
        for a in new:
            print(f"    + {a.label}")
    if updated:
        print(f"\n  UPDATED ({len(updated)}):")
        for a in updated:
            print(f"    ~ {a.label}")
    if deleted:
        print(f"\n  DELETED ({len(deleted)}):")
        for a in deleted:
            print(f"    - {a.label}")

    total = len(all_actions)
    print(f"\n  Total: {total} change(s)\n")

    if args.reverse:
        reverse_sync(all_actions)
        return

    if not args.apply:
        print("  Dry run. Use --apply to sync.\n")
        return

    # Apply
    print("  Syncing...\n")
    apply_actions(all_actions)
    git_commit_and_push(all_actions, push=not args.no_push)
    print("\n  Done.\n")


if __name__ == "__main__":
    main()

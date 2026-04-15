#!/usr/bin/env python3
"""
Sync skills from ~/.claude/skills/ to the engineai-skills repo.

Copies Engine AI skills (excludes gstack), organises into category
folders, and commits/pushes if there are changes.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

# Paths
LIVE_SKILLS = Path.home() / ".claude" / "skills"
REPO_ROOT = Path(__file__).parent.resolve()

# Category mappings: skill name -> category folder
# Skills not listed here go to repo root
CATEGORIES = {
    # GEO suite
    "geo": "geo",
    "geo-audit": "geo",
    "geo-brand-mentions": "geo",
    "geo-citability": "geo",
    "geo-compare": "geo",
    "geo-content": "geo",
    "geo-crawlers": "geo",
    "geo-llmstxt": "geo",
    "geo-platform-optimizer": "geo",
    "geo-proposal": "geo",
    "geo-prospect": "geo",
    "geo-report": "geo",
    "geo-report-pdf": "geo",
    "geo-schema": "geo",
    "geo-technical": "geo",
    # Session lifecycle
    "load-project": "session",
    "resume": "session",
    "resume-deep": "session",
    "wrap": "session",
    # Review
    "adversarial-review": "review",
    "code-combat": "review",
    # Meta
    "autoresearch": "meta",
    "skill-creator": "meta",
    # Infrastructure
    "openclaw-audit": "infra",
    "unraid-troubleshooter": "infra",
}

# Files/patterns to skip
SKIP_FILES = {".DS_Store", "Zone.Identifier", "Thumbs.db"}


def is_gstack_skill(skill_path: Path) -> bool:
    """Check if a skill is from gstack (symlinked SKILL.md or has .tmpl)."""
    skill_md = skill_path / "SKILL.md"
    skill_tmpl = skill_path / "SKILL.md.tmpl"

    if skill_tmpl.exists():
        return True
    if skill_md.is_symlink():
        target = str(os.readlink(skill_md))
        if "gstack" in target:
            return True
    return False


def get_engine_skills() -> list[str]:
    """Get list of Engine AI skills (not gstack)."""
    if not LIVE_SKILLS.exists():
        print(f"Skills directory not found: {LIVE_SKILLS}")
        sys.exit(1)

    skills = []
    for item in sorted(LIVE_SKILLS.iterdir()):
        name = item.name

        # Skip dotfiles and known junk
        if name.startswith(".") or any(s in name for s in SKIP_FILES):
            continue

        # Skip gstack submodule itself
        if name == "gstack":
            continue

        # Handle directories
        if item.is_dir():
            if is_gstack_skill(item):
                continue
            skills.append(name)
        # Handle standalone files (like Stellar-Immigration-Agent-Skill.md)
        elif item.is_file() and name.endswith(".md"):
            skills.append(name)

    return skills


def sync_skill(name: str) -> bool:
    """Sync a single skill. Returns True if changes were made."""
    src = LIVE_SKILLS / name
    category = CATEGORIES.get(name)

    if category:
        dst = REPO_ROOT / category / name
    else:
        dst = REPO_ROOT / name

    # Ensure parent exists
    dst.parent.mkdir(parents=True, exist_ok=True)

    # For files (standalone skills)
    if src.is_file():
        if dst.exists() and src.read_bytes() == dst.read_bytes():
            return False
        shutil.copy2(src, dst)
        return True

    # For directories
    if not src.is_dir():
        return False

    # Check if content differs by comparing file trees
    changed = False

    # Copy new/changed files from source
    for root, dirs, files in os.walk(src):
        rel_root = Path(root).relative_to(src)
        dst_dir = dst / rel_root
        dst_dir.mkdir(parents=True, exist_ok=True)

        for f in files:
            if any(s in f for s in SKIP_FILES):
                continue
            src_file = Path(root) / f
            dst_file = dst_dir / f

            # Skip symlinks that point to gstack
            if src_file.is_symlink():
                target = str(os.readlink(src_file))
                if "gstack" in target:
                    continue

            if not dst_file.exists():
                shutil.copy2(src_file, dst_file)
                changed = True
            elif src_file.read_bytes() != dst_file.read_bytes():
                shutil.copy2(src_file, dst_file)
                changed = True

    # Remove files in dest that no longer exist in source
    if dst.exists():
        for root, dirs, files in os.walk(dst):
            rel_root = Path(root).relative_to(dst)
            src_dir = src / rel_root
            for f in files:
                src_file = src_dir / f
                if not src_file.exists():
                    dst_file = Path(root) / f
                    dst_file.unlink()
                    changed = True

    return changed


def git_commit_and_push():
    """Stage, commit, and push if there are changes."""
    os.chdir(REPO_ROOT)

    # Check for changes
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        capture_output=True, text=True
    )
    if not result.stdout.strip():
        print("No changes to commit.")
        return

    # Stage all
    subprocess.run(["git", "add", "-A"], check=True)

    # Commit
    subprocess.run(
        ["git", "commit", "-m", "Sync skills from live config"],
        check=True
    )

    # Push
    result = subprocess.run(
        ["git", "push", "origin", "main"],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print("Pushed to origin/main.")
    else:
        print(f"Push failed: {result.stderr}")


def main():
    print(f"Source: {LIVE_SKILLS}")
    print(f"Repo:   {REPO_ROOT}")
    print()

    skills = get_engine_skills()
    print(f"Found {len(skills)} Engine AI skills (gstack excluded)")
    print()

    changed = []
    unchanged = []

    for name in skills:
        if sync_skill(name):
            changed.append(name)
            print(f"  Updated: {name}")
        else:
            unchanged.append(name)

    print()
    print(f"Changed: {len(changed)}  |  Unchanged: {len(unchanged)}")

    if changed:
        print()
        git_commit_and_push()
    else:
        print("Everything in sync.")


if __name__ == "__main__":
    main()

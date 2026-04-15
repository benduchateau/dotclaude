#!/usr/bin/env python3
"""
Sync Engine AI skills from ~/.claude/skills/ to the engineai-skills repo.

Uses an allowlist to include only Engine AI skills (not gstack or
third-party). Organises into category folders and commits/pushes
if there are changes.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.resolve()

# Engine AI skills allowlist with category mapping
# None = repo root (standalone), string = category subfolder
SKILLS = {
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
    # Standalone
    "brainstorming": None,
    "brand": None,
    "file-organizer": None,
    "humaniser": None,
    "notebooklm": None,
    "senior-architect": None,
    "Stellar-Immigration-Agent-Skill.md": None,
    "x-voice.skill": None,
}

SKIP_FILES = {".DS_Store", "Zone.Identifier", "Thumbs.db", "__pycache__"}
SKIP_DIRS = {".venv", "venv", "node_modules", "__pycache__", ".git"}


def find_skills_dir() -> Path:
    """Find the live skills directory (works on both WSL and Windows)."""
    # Try WSL path first
    wsl = Path("/home/duchats/.claude/skills")
    if wsl.exists():
        return wsl
    # Fall back to Windows via Path.home()
    win = Path.home() / ".claude" / "skills"
    if win.exists():
        return win
    print("Could not find ~/.claude/skills/")
    sys.exit(1)


def sync_item(src: Path, dst: Path) -> bool:
    """Sync a file or directory. Returns True if changes were made."""
    if not src.exists():
        return False

    # Single file
    if src.is_file():
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists() and src.read_bytes() == dst.read_bytes():
            return False
        shutil.copy2(src, dst)
        return True

    # Directory
    changed = False
    for root, dirs, files in os.walk(src):
        # Prune skipped directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]

        rel = Path(root).relative_to(src)
        target_dir = dst / rel
        target_dir.mkdir(parents=True, exist_ok=True)

        for f in files:
            if any(s in f for s in SKIP_FILES):
                continue
            sf = Path(root) / f
            df = target_dir / f

            # Skip broken symlinks
            if sf.is_symlink() and not sf.exists():
                continue

            if not df.exists() or sf.read_bytes() != df.read_bytes():
                shutil.copy2(sf, df)
                changed = True

    # Remove files in dest no longer in source
    if dst.exists():
        for root, _, files in os.walk(dst):
            rel = Path(root).relative_to(dst)
            for f in files:
                if not (src / rel / f).exists():
                    (Path(root) / f).unlink()
                    changed = True

    return changed


def main():
    live = find_skills_dir()
    print(f"Source: {live}")
    print(f"Repo:   {REPO_ROOT}")

    changed = []
    missing = []

    for name, category in sorted(SKILLS.items()):
        src = live / name

        if not src.exists():
            missing.append(name)
            continue

        if category:
            dst = REPO_ROOT / category / name
        else:
            dst = REPO_ROOT / name

        if sync_item(src, dst):
            changed.append(name)
            print(f"  Updated: {name}")

    if missing:
        print(f"\n  Not found ({len(missing)}): {', '.join(missing)}")

    print(f"\nChanged: {len(changed)}  |  Skipped: {len(SKILLS) - len(changed) - len(missing)}")

    if not changed:
        print("Everything in sync.")
        return

    # Git commit and push
    os.chdir(REPO_ROOT)
    subprocess.run(["git", "add", "-A"], check=True)

    result = subprocess.run(
        ["git", "status", "--porcelain"],
        capture_output=True, text=True
    )
    if not result.stdout.strip():
        print("No git changes after staging.")
        return

    subprocess.run(
        ["git", "commit", "-m", "Sync skills from live config"],
        check=True
    )
    r = subprocess.run(
        ["git", "push", "origin", "main"],
        capture_output=True, text=True
    )
    if r.returncode == 0:
        print("Pushed to origin/main.")
    else:
        print(f"Push failed: {r.stderr}")


if __name__ == "__main__":
    main()

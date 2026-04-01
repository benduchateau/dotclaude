---
name: dotclaude portable config repo
description: benduchateau/dotclaude GitHub repo is the portable Claude Code config bundle. 11 skills in repo vs 45 installed locally. No sync skill exists yet.
type: reference
---

## dotclaude Repo

- **GitHub:** `benduchateau/dotclaude`
- **Local path:** `~/dotclaude/`
- **Purpose:** Portable Claude Code configuration bundle for replicating the setup across machines
- **Contains:** CLAUDE.md, settings.json, statusline-command.sh, skills/, scripts/, commands/, templates/, memory/

### Skills gap (as of 2026-04-01)
- **In repo:** 11 skills (Stellar-Immigration-Agent-Skill, autoresearch, brainstorming, file-organizer, gstack (submodule), humaniser, openclaw-audit, resume, senior-architect, skill-creator, wrap)
- **Installed locally:** 45 skills (many from gstack submodule expansion plus newer installs like codex, browse, qa, design-review, design-shotgun, design-consultation, etc.)
- **No sync skill exists.** User asked about building one on 2026-04-01. The repo is significantly behind the live install.

### Notes
- Skills are the primary content. The gstack submodule symlinks bring in browse, qa, design-review, connect-chrome, and many more.
- wrap and resume skills were optimised via autoresearch on 2026-03-25 (both reached 100% eval score).
- Push new skills here after creating/updating them in `~/.claude/skills/`.

---
name: Custom Claude Code statusline
description: Custom Python statusline at ~/.claude/scripts/statusline.py. Engine AI gold branding, project name mapping, effort level, date/time. Replaced claude-code-bar.
type: reference
---

## Custom Statusline

**Script:** `~/.claude/scripts/statusline.py`
**Language:** Python 3 (stdlib only, no deps). Was originally `.sh` extension, renamed to `.py` on 2026-03-30.
**Replaced:** `claude-code-bar` npm package (still installed as fallback).

### Display
```
▸ Opus │ 27% │ ⏱️ 2m14s │ Engine AI │ main* │ ⚡high │ 22:39  Mon 30 Mar
⏱️ 5h   ▓▓▓▓░░░░░░ 48%
📅 7d   ▓░░░░░░░░░ 12%
```

### Features vs claude-code-bar
- Project name mapping (directory basename → friendly name, e.g. `engineai_website` → `Engine AI`)
- Engine AI gold branding on separators
- Effort level indicator
- Date/time display
- Traffic-light rate limit bars (preserved from claude-code-bar)

### Configuration
Project mapping is a dict at the top of the script. To add new projects, add a line to `PROJECT_MAP`.

Wired in `~/.claude/settings.json` under `statusLine`.

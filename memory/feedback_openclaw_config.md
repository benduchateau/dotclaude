---
name: feedback-openclaw-config
description: Never edit openclaw.json directly — gateway overwrites it on restart. Always use openclaw config set CLI commands.
type: feedback
---

Never edit `~/.openclaw/openclaw.json` directly — the gateway process overwrites it on startup.

**Why:** Direct file edits get reverted when the gateway restarts, causing config changes to silently disappear. This caused repeated frustration during the 2026-03-13 gateway setup session.

**How to apply:** Always use `openclaw config set <dot.path> <value>` to persist config changes. Verify with `openclaw config get <dot.path>` after setting.

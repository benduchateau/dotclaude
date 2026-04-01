---
name: Use broad prefix permission rules
description: Claude Code permissions should use broad prefix rules (Bash(git:*)) not one-off command approvals. Cleaned from 49 to 16 rules on 2026-03-30.
type: feedback
---

Use broad prefix wildcard rules for Claude Code permissions, not one-off command approvals that accumulate over sessions.

**Why:** The allow list in `~/.claude/settings.json` had grown to 49 specific one-off rules (exact curl commands, pkill chains, npx sequences) from past auto-approvals. These don't generalise and create noise. Cleaned to 16 broad prefix rules on 2026-03-30.

**How to apply:** When permissions accumulate past ~20 rules, consolidate. Use patterns like `Bash(git:*)`, `Bash(npm:*)`, `Bash(npx:*)`, `Bash(curl:*)` etc. Prefix wildcards match any command starting with that string. Drop specific one-liners that are subsumed by the broader rules.

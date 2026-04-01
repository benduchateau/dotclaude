---
name: OpenAI Codex plugin for Claude Code
description: Codex CLI plugin installed. Provides /codex:review, /codex:adversarial-review, /codex:rescue. Used successfully on CRM build (found 4 real bugs).
type: reference
---

## Codex Plugin

OpenAI's Codex CLI integrated into Claude Code as slash commands. Installed 2026-03-31.

**Codex CLI version:** 0.117.0
**Auth:** authenticated (ChatGPT subscription)
**Review gate:** disabled (burns usage fast, enable selectively for high-stakes PRs)

### Commands
| Command | Purpose |
|---|---|
| `/codex:review` | Standard code review on uncommitted changes or branch diffs |
| `/codex:adversarial-review` | Challenges implementation and design decisions |
| `/codex:rescue` | Delegates task to Codex as background subagent |
| `/codex:status` | Check running background jobs |
| `/codex:result` / `/codex:cancel` | Retrieve results or cancel |
| `/codex:setup` | Validate install and auth |

### Track Record
- CRM build (2026-03-30): found 2 P1s (OAuth callback blocked by middleware, stale IDs in quick-log) and 2 P2s (no kanban rollback, signup without session). All legitimate findings, all fixed.

### Config
Respects `~/.codex/config.toml` or project-level `.codex/config.toml` for default models and effort levels.

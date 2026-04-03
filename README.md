# dotclaude

Portable Claude Code configuration bundle for Engine AI. Drop this into `~/.claude/` on any machine to replicate the full dev environment, skills, hooks, and memory system.

## What's Inside

```
CLAUDE.md              # Global operator config (identity, projects, principles)
settings.json          # Permission rules, model preferences, tool config
statusline-command.sh  # Custom status bar with project context
shell-aliases.sh       # Shell aliases (cc for claude-code, etc.)
install.sh             # One-shot installer
sync.py                # Sync utility
hooks/                 # Event-driven hooks (session start, tool calls)
commands/              # Custom slash commands
templates/             # Proposal and document templates
memory/                # Persistent cross-session memory system
skills/                # Claude Code skills (see below)
```

## Skills

### Custom Skills

Built for Engine AI workflows and personal infrastructure.

| Skill | Purpose |
|---|---|
| `brand` | Engine AI visual identity and brand system. Colours, typography, spacing, component patterns, animation, tone of voice, asset references. Source of truth for all Engine AI UI work. |
| `humaniser` | Strips AI writing patterns and applies a natural, direct voice. Flags em dashes, filler phrases, and corporate padding. |
| `brainstorming` | Pre-build intent and requirements exploration. Run before any creative or feature work to clarify scope. |
| `resume` | Start-of-session briefing. Reads memory files, checks Linear/Notion, reviews git state, suggests next actions. |
| `wrap` | End-of-session cleanup. Updates todos, lessons, decisions. Checks for stray files. |
| `autoresearch` | Autonomously optimise any Claude Code skill by running it repeatedly, scoring with binary evals, mutating the prompt, and keeping improvements. |
| `senior-architect` | System architecture design for React, Next.js, Node, Postgres, GraphQL, Go, Python. Architecture diagrams, tech stack decisions, trade-off analysis. |
| `skill-creator` | Guide for creating and updating Claude Code skills with proper structure and frontmatter. |
| `file-organizer` | Intelligent file/folder organisation, duplicate detection, and restructuring suggestions. |
| `openclaw-audit` | Audit the OpenClaw VM against security, health, Docker, and application standards. |
| `unraid-troubleshooter` | Unraid server diagnostics: array, parity, Docker containers, VMs, plugins, Community Apps. |
| `notebooklm` | Query Google NotebookLM notebooks from Claude Code for source-grounded, citation-backed answers. |
| `Stellar-Immigration-Agent-Skill` | NZ immigration process for Stellar Recruitment. AEWV system, visa applications, compliance. |

### gstack (Third-Party Toolkit)

The `gstack` submodule provides ~30 DevOps, QA, and workflow skills including:

- **Browse/QA:** `browse`, `qa`, `qa-only`, `benchmark`, `canary`
- **Design:** `design-consultation`, `design-review`, `design-shotgun`, `design-html`
- **Shipping:** `ship`, `review`, `land-and-deploy`, `document-release`
- **Planning:** `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, `autoplan`
- **Safety:** `careful`, `freeze`, `unfreeze`, `guard`
- **Other:** `codex`, `connect-chrome`, `cso`, `investigate`, `office-hours`, `retro`, `learn`

## Setup

```bash
git clone https://github.com/benduchateau/dotclaude.git ~/dotclaude
cd ~/dotclaude
./install.sh
```

Or manually symlink what you need into `~/.claude/`.

## Environment

- WSL2 (Ubuntu) on Windows
- Claude Code as primary IDE
- Vercel for deployment
- Supabase for backend/DB
- GitHub org: `engineai-nz`

## Who This Is For

Engine AI team members setting up Claude Code with the full skill set, hooks, and configuration. If you're Joe, start here.

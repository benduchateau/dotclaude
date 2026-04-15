# Engine AI Skills

Claude Code skills built by [Engine AI](https://engineai.co.nz) for AI orchestration, content optimisation, session management, and infrastructure ops.

Drop any skill folder into `~/.claude/skills/` to use it.

---

## GEO -- Generative Engine Optimisation

Full suite for optimising websites for AI-powered search engines (ChatGPT, Claude, Perplexity, Gemini, Google AI Overviews).

| Skill | What it does |
|---|---|
| `geo/geo` | Core GEO analysis with citability scoring, crawler checks, and schema audit |
| `geo/geo-audit` | Full website audit with parallel subagent delegation across all GEO dimensions |
| `geo/geo-brand-mentions` | Brand mention and authority scanning across AI-referenced platforms |
| `geo/geo-citability` | Score how likely AI systems are to cite or quote page content (0-100) |
| `geo/geo-compare` | Monthly delta tracking between baseline and current GEO audits |
| `geo/geo-content` | Content quality and E-E-A-T assessment for AI citability |
| `geo/geo-crawlers` | AI crawler access analysis via robots.txt, meta tags, and HTTP headers |
| `geo/geo-llmstxt` | Generate and validate llms.txt files for AI system discoverability |
| `geo/geo-platform-optimizer` | Platform-specific optimisation for individual AI search engines |
| `geo/geo-proposal` | Auto-generate client-ready GEO service proposals from audit data |
| `geo/geo-prospect` | CRM-lite for managing GEO prospects through the sales pipeline |
| `geo/geo-report` | Professional client-facing report combining all audit results |
| `geo/geo-report-pdf` | PDF report generation with score gauges, charts, and action plans |
| `geo/geo-schema` | Schema.org structured data audit and JSON-LD generation |
| `geo/geo-technical` | Technical SEO audit with GEO-specific crawlability and SSR checks |

## Design

| Skill | What it does |
|---|---|
| `design/brand` | Engine AI visual identity: colours, typography, spacing, components, tone of voice |
| `design/design-html` | Convert approved AI mockups into production-quality HTML/CSS |
| `design/design-shotgun` | Generate multiple design variants with comparison board and structured feedback |

## Session

Session lifecycle management for Claude Code.

| Skill | What it does |
|---|---|
| `session/load-project` | Guided walkthrough for opening a project and getting it running locally |
| `session/resume` | Start-of-session briefing: memory, git state, next actions |
| `session/resume-deep` | Comprehensive briefing with full memory review and cross-project scan |
| `session/wrap` | End-of-session cleanup: update todos, lessons, decisions, check for stray files |

## Review

| Skill | What it does |
|---|---|
| `review/adversarial-review` | Dual-agent adversarial review of PRDs, specs, and architecture docs |
| `review/code-combat` | Multi-round adversarial negotiation between AI agents over build docs |

## Meta

Skills about skills.

| Skill | What it does |
|---|---|
| `meta/autoplan` | Auto-review pipeline running CEO, design, and engineering reviews |
| `meta/autoresearch` | Autonomously optimise skills by running, scoring, and mutating prompts |
| `meta/skill-creator` | Guide for creating and packaging new Claude Code skills |

## Infrastructure

| Skill | What it does |
|---|---|
| `infra/openclaw-audit` | Audit OpenClaw VM against security, health, Docker, and app standards |
| `infra/unraid-troubleshooter` | Unraid server diagnostics: array, parity, Docker, VMs, plugins |

## Standalone Skills

| Skill | What it does |
|---|---|
| `brainstorming` | Pre-build exploration of intent, requirements, and design before implementation |
| `connect-chrome` | Launch Chrome with Side Panel extension for live activity tracking |
| `cso` | Chief Security Officer audit: secrets, supply chain, threat modelling |
| `file-organizer` | Intelligent file/folder organisation with duplicate detection |
| `humaniser` | Strip AI writing patterns, apply natural direct voice |
| `learn` | Manage, review, search, and prune project learnings across sessions |
| `notebooklm` | Query Google NotebookLM for source-grounded, citation-backed answers |
| `senior-architect` | System architecture design with diagrams for React, Node, Postgres, Go, Python |
| `Stellar-Immigration-Agent-Skill` | NZ immigration process for recruiting Filipino skilled workers (AEWV) |

---

## Installation

Copy a skill folder into your Claude Code skills directory:

```bash
# Single skill
cp -r geo/geo-audit ~/.claude/skills/geo-audit

# Entire category
cp -r geo/* ~/.claude/skills/

# Everything
for dir in */; do
  [[ -f "$dir/SKILL.md" ]] && cp -r "$dir" ~/.claude/skills/
  for sub in "$dir"*/; do
    [[ -f "$sub/SKILL.md" ]] && cp -r "$sub" ~/.claude/skills/
  done
done
```

## Built by

[Engine AI](https://engineai.co.nz) -- AI orchestration consultancy, Auckland, New Zealand.

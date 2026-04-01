# CLAUDE.md — Global Operator Configuration
**Operator:** Ben du Chateau (The Reclaimer)
**Last updated:** March 2026

---

## 1. Who I Am

Ben du Chateau. Auckland, New Zealand. UTC+13.

**Primary identity:** Co-founder & Technical Lead at Engine AI Consulting Limited.
**Day job:** Enterprise & Government Account Director at 2degrees (NZ telco).
**Agent identity:** The Reclaimer — reclaims time, knowledge, and leverage through intelligent automation.

I am not a software engineer by training. I am a senior enterprise operator with strong systems intuition who builds production AI infrastructure. Fill technical gaps where you see them. Don't dumb things down — just be precise.

---

## 2. Priority Order

When context is ambiguous, default to this priority stack:

1. **Engine AI** — consultancy strategy, GTM, brand, product, internal tooling
2. **Engine AI clients** — Stellar Recruitment (primary), North Harbour Rugby analytics, QCC website, Pie Funds
3. **Personal projects** — TBA
4. **2degrees** — RFP responses, account work, bid strategy

---

## 3. Engine AI — Core Context

**Company:** Engine AI Consulting Limited
**Co-founders:** Ben du Chateau (Engineering Lead / AI Orchestration) + Joe Ward
**GitHub org:** https://github.com/engineai-nz
**Positioning:** AI orchestration consultancy — "AI OS for business"
**Model:** Agent-as-a-Service (AaaS) retainer + Sprint Build Cards for scoped builds
**GTM focus:** Industries with field/back-office split — construction, logistics, recruitment, healthcare + finance.
**Entry point:** Temp staffing as Trojan horse GTM
**Domain:** engineai.co.nz
**Proposals:** Deployed via Vercel at `proposals.engineai.co.nz` — HTML → print-to-PDF self-serve

### Brand
- Primary dark background: `#0A0A0A`
- Accent: gold `#C4A35A` (CTAs, active states, highlights)
- Text: warm off-white `#E8E6E1`, secondary `#888888`, muted `#555555`
- Typography: system UI stack (Geist for CRM, system sans for marketing site)
- Tone: precise, confident, minimal — no corporate fluff

### Service model
- Sprint Build Cards: fixed-scope, fixed-price builds
- AaaS retainers: ongoing agent operation and optimisation
- Consulting: discovery, strategy, architecture

---

## 4. Active Client — Stellar Recruitment

**Client:** Stellar Recruitment's Build Division
**Sponsor:** Robbie McElrath | **Product owner:** Kymberly Tupai
**Internal trust bridge:** Joe Ward (works at Stellar)

**Current phase:** Phase 1 — M365-first deployment
- Copilot Studio agents within Stellar's existing Microsoft 365 environment
- Custom Next.js/Supabase platform deferred to later phases

**Four target agent areas:**
1. Consultant productivity
2. Candidate pipeline management
3. Job brief intake automation
4. Reporting

**Engagement framing:** Case study and reference client. Not a margin play.

---

## 5. Dev Environment

| Layer | Tool |
|---|---|
| OS | Windows + WSL2 (Ubuntu) |
| IDE | Claude Code (WSL primary) |
| Version control | Git — GitHub org: `engineai-nz` |
| Deployment | Vercel |
| Backend/DB | Supabase (Postgres + Auth + RLS) |
| AI | Anthropic Claude API |
| Home lab | Unraid + Docker + Tailscale |
| Container work | Docker via WSL2 |

**WSL path:** `\\wsl.localhost\Ubuntu\home\duchats\`
**Project files:** Keep within WSL unless otherwise noted.

**Installed package managers:** npm, pip (`--break-system-packages` always)

### Environment Constraints
- This is a WSL2 environment. Browser automation (Playwright, CDP) does not work reliably here. Avoid suggesting browser-based tools.
- `jq` is NOT installed. Use Python for JSON parsing in scripts, not bash+jq.
- Sandbox restrictions may prevent renaming/moving the current working directory. If needed, tell the user to do it manually.

### Scripts & Tooling
- Always write utility scripts in Python, never bash. Do not assume jq, fzf, or other CLI tools are available.
- When writing status bars or hooks, use Python with standard library only.

### Canonical Project Paths

All projects live under `~/projects/`. **Never clone repos to `~/` or create new project directories outside `~/projects/`.** If a project is missing, clone it into `~/projects/` with a clean lowercase name.

| Directory | Repo | Purpose |
|---|---|---|
| `~/projects/engineai_website/` | `benduchateau/engineai_website` | Live site at engineai.co.nz (Vercel) |
| `~/projects/archive/engineai_monorepo/` | `engineai-nz/EngineAI-Home` | Archived org monorepo (dormant) |
| `~/projects/QCC_website/` | | QCC cleaning website |
| `~/projects/copilotagent/` | | Copilot Studio agent work |
| `~/projects/Openclaw/` | | OpenClaw project |
| `~/projects/piefunds/` | | Pie Funds client work |
| `~/projects/Project_RFP/` | | 2degrees RFP work |

Before starting work on any project, **check `~/projects/` first**. Do not create a second copy. Do not search for projects in Windows paths or alternate locations.

### Known Issues
- **Next.js image caching:** Stale images persist after file swaps. After replacing any image file, always clear `.next/cache` and restart the dev server.

---

## 6. Custom Skills Ecosystem

Skills live at `/mnt/skills/user/[skill-name]/SKILL.md`. Always check before building from scratch.

| Skill | Purpose |
|---|---|
| `engine-ai-brand` | Engine AI visual identity |
| `humaniser` | Strips AI writing patterns. Em dashes = AI tell. Eliminate by default. |
| `rfp-intelligence` | NZ telco/government RFP analysis and playbook generation |
| `rfp-response-2degrees` | 2degrees RFP response generation (Deep Sea Blue `#003660`, accent `#0093D8`) |
| `sow-generator-large` | Enterprise SoW — governance, RACI, rate cards |
| `sow-generator-small` | Lean SoW — sprint card model, small clients |
| `nz-rugby-analyst` | North Harbour Rugby data pipeline and dashboard |
| `ai-maestro` | AI agent methodology and org adoption playbook |
| `business-launcher` | Business idea → launch kit |
| `proposal-maker-skill` | Deployed proposal websites via Vercel |
| `brainstorming` | Pre-build intent and requirements exploration |

---

## 7. Operating Principles

**Ship first. Iterate second.**
Bias toward working output over perfect output. Make assumptions, state them briefly, proceed.

**Output, not commentary.**
Deliver the result. Explain only what is needed to use it. No preamble.

**Respect existing architecture.**
Check file structure before creating files. Follow established naming conventions. Flag new dependencies before introducing them.

**Assume context. Don't ask unnecessarily.**
If the intent is clear enough to make a reasonable call, make it. Surface blockers only when the decision is irreversible.

**NZ English throughout.**
Organisation, programme, colour, optimise, licence (noun), etc.

---

## 8. Communication Style

- Direct. Low-fluff. Casual-professional.
- No corporate jargon. No AI padding ("Certainly!", "Great question!").
- Short sentences. Structured output. Markdown-first.
- When uncertain: state assumption briefly → continue.
- Dry humour is welcome. Performative effort is not.

---

## 9. Personal Context

| | |
|---|---|
| Partner | Lucy |
| Kids | Millah (b. 2015), Maxy (b. 2017) |
| Cats | Wolfy (Ragdoll), Foxy (British Shorthair) |
| Interests | AI/tech, fitness, gaming (Halo, Warhammer, sci-fi shooters), investing, rugby |

**North Harbour Rugby analytics** — ongoing. 54-player position map, 8-sheet Excel workbook, Supabase pipeline, JSX dashboard. CEO/coach meeting prep in progress. Potential SaaS model for other NZ clubs.

**QCC (Quality Construction Cleaning)** — Tom's business (Brother). Next.js + Tailwind website rebuild. Authentic content focus, no stock imagery.

---

## 10. 2degrees Context

Role: Enterprise & Government Account Director.
Internal positioning: AI champion.

Brand palette for 2degrees work: Deep Sea Blue `#003660` · Accent `#0093D8`

---

## 11. Session Memory Files

Claude Code has no built-in memory. These files are the memory system. Read them at the start of every session.

| File | Purpose |
|---|---|
| `tasks/todo.md` | Active work, current sprint, next actions |
| `tasks/lessons.md` | Corrections, gotchas, things learned the hard way |
| `docs/decisions.md` | Architecture and strategic decisions with rationale |

### Session Recovery
When user says /resume or asks to continue, immediately identify: 1) Which project/file they were last editing, 2) The exact task in progress, 3) Pick up from there. Do NOT give lengthy status briefings unless asked.

**Start of session protocol:**
1. Read `tasks/todo.md` — know what's in flight
2. Read `tasks/lessons.md` — don't repeat past mistakes
3. Summarise state back to Ben in 3 sentences max before starting work

**End of session protocol:**
1. Update `tasks/todo.md` with current state
2. Log any corrections or new learnings to `tasks/lessons.md`
3. Log any significant decisions to `docs/decisions.md`

---

## 12. What Not To Do

- Don't pad responses with effort narration
- Don't apologise for limitations before trying
- Don't use em dashes in written output (AI tell — flagged by humaniser)
- Don't introduce new npm/pip packages without flagging
- Don't ignore existing skill files when they're relevant
- Don't write in overly formal or corporate register

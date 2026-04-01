---
name: NH Rugby Intel Hub project context
description: North Harbour Rugby intelligence dashboard — Engine AI client project. Joe Ward architects, Ben builds. Phase 1 (Schema-First) active, blocked on Joe for Supabase access and schema decisions.
type: project
---

North Harbour Rugby Intelligence Hub. AI-native dashboard for coaching, S&C, and medical staff.

**Why:** Engine AI's showcase client project. Understanding the Ben/Joe dynamic and dependency chain is critical for unblocking work each session.

**How to apply:**
- Repo: `~/projects/NH-Rugby-Intel-Platform/` on branch `ben/supabase-setup`. Main is protected (Joe reviews PRs).
- Joe Ward is architect and Supabase owner. Ben builds on Joe's specifications. Key decisions need Joe's approval.
- Linear project: "NH Rugby Intel Hub" (Engineai team, 37 issues across 5 phase milestones). Joe is project lead.
- Notion workspace: "North Harbour Rugby" with Product Roadmap, Decision Log, Document Hub, Meeting Notes, Risk Register (see reference_notion_nhrugby.md for IDs).
- Session files: `tasks/todo.md`, `tasks/lessons.md`, `docs/decisions.md` in the project repo.
- `/resume` and `/wrap` skills handle session handoff with Linear/Notion checking and `.last_session` timestamps.

**Current state (as of 2026-03-30):**
- Phase 1 (Schema-First Foundation) is active. ENG-60 (schema audit) complete, waiting on Joe for 5 decisions.
- ENG-61 (Supabase setup) blocked: Ben needs access to Joe's Supabase org.
- ENG-59 (widget-to-schema contract) is Joe's task and blocks ENG-12 (schema design).
- Notion + Linear sync was attempted 2026-03-24 as unblocked work, but parked mid-session. Still a viable task to progress without Joe.
- Open question: Joe's email says React/Node.js, refactor plan says Next.js 15. Schema work is safe either way.
- Joe works directly in Supabase SQL editor (created opta_match_actions table, ingest.js script). Uses Supabase JS client, not Drizzle ORM. Likely resolution: Supabase JS for ETL, Drizzle for app queries.

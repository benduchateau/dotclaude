---
name: Engine AI CRM
description: Internal CRM built on Supabase + Next.js. Live at app-theta-indol-79.vercel.app since 2026-03-30. QA 78/100, Design B+. Next steps: custom domain, Google SSO, create/edit forms.
type: project
---

Engine AI internal CRM covering prospect-to-delivery lifecycle.

**Supabase ref:** `wrpmsssdwqjytcpplfoy` (ap-southeast-2, Sydney)
**Repo:** engineai-nz/Engineai_CRM (private)
**Local path:** ~/projects/Engineai_CRM
**Live URL:** https://app-theta-indol-79.vercel.app

## Current State (as of 2026-03-30)

Phase 1 DB deployed: companies, contacts, opportunities, sub_opportunities, interactions. RLS enabled (authenticated-only). Seed data for Stellar, NH Rugby, TPA Management.

Notion CRM also set up in Engine AI workspace (4 linked databases, same seed data) as parallel working UI.

Frontend built and deployed 2026-03-30:
- Pipeline kanban (home), Companies table, Company detail (with tabs), Activity feed
- Quick-log drawer for interactions
- Auth: Supabase email/password (Google SSO button present, needs OAuth config)
- Codex review: 4 findings fixed (OAuth callback, stale IDs, optimistic rollback, signup flow)
- QA score: 78/100 (core functional, no CRUD forms yet)
- Design score: B+ (sidebar collapse on mobile, h1 sizing, touch targets, kanban hover all fixed)

**Design direction:** Gold accent #C4A35A, Geist font, dark-only, industrial-refined (Linear-inspired). Full tokens in DESIGN.md.

**Auth:** Supabase email/password for Ben. Joe still needs to sign up.

**Key deps:** @supabase/ssr, @dnd-kit/core, @dnd-kit/sortable, lucide-react, date-fns, geist font.

## Next Steps
- Custom domain (crm.engineai.co.nz)
- Google SSO configuration in Supabase
- Create/edit forms (companies, opportunities, contacts)
- Remove signup flow once Joe has an account
- Phase 2: AI layer

**Why:** Ben and Joe need a CRM shaped to their two-person operator workflow, not a reporting tool.

**How to apply:** Read DESIGN.md before any UI work. Read docs/schema.md for DB schema. Don't overbuild.

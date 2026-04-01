---
name: Autonomous deployment and environment health pipeline skill
description: Planned Claude Code skill for pre-flight env checks, auto-fix, and deploy pipeline. Spec ready, not yet built.
type: project
---

Build an autonomous deployment and environment health pipeline as a Claude Code skill. Spec below.

## 1. Pre-flight checks (run on /resume or session start)
- Verify all required env vars exist in .env.local AND Vercel (list common ones from package.json/code)
- Check git status, current branch, and whether we're behind origin
- Verify dev server can start without errors (`npm run build` dry run)
- Check that all external services are reachable (Supabase, Resend, any MCP servers)
- Report results as a traffic-light status summary

## 2. Auto-fix what's possible
- Stale lock files
- Missing .env vars that have defaults
- Outdated dependencies

## 3. Deploy pipeline
When user says "ship it": run lint + type-check + build + push + verify Vercel deployment URL returns 200.

## 4. Packaging
Save as a reusable skill. Must be idempotent and safe to run anytime.

**Why:** Insights report flagged significant time lost to environment issues: expired OAuth tokens, missing env vars (RESEND_API_KEY), CDP bridge failures, WSL path mismatches, and Vercel deployment errors. A pre-flight check turns these common derailments into non-issues.

**How to apply:** When this skill is built, integrate it into the /resume flow and the /ship flow. Pre-flight runs automatically on session start. Deploy pipeline triggers on "ship it" or /ship.

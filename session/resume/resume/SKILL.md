---
name: resume
description: Fast start-of-session briefing. Reads tasks/todo.md and git state to deliver a tight catch-up under 5k tokens. Use when starting a session, resuming work, or when the user says "catch me up", "where were we", or "resume". For deep cross-project briefings with Linear sync, use /resume-deep instead. Counterpart to /wrap.
user_invocable: true
---

# Session Resume (Lean)

Fast briefing in under 5k tokens. No Linear, no cross-project scan, no Notion, no full memory dumps. Just: where you left off, git state, what to do next.

If the user wants deeper context (Linear sync, teammate updates, scan of other projects), tell them to run `/resume-deep` instead.

## Step 1: Identify Project

Determine the active project from the current working directory.

- If `tasks/todo.md` exists, this is a tracked project.
- If not, check for `CLAUDE.md` to confirm project context.
- **If no project files exist** (e.g. working from `~/`), skip to Step 4 and just show git state. Recommend switching into a project directory.

## Step 2: Read todo.md ONLY

Read `tasks/todo.md`. Do NOT read `lessons.md`, `decisions.md`, or `CLAUDE.md` — they're either already in context (CLAUDE.md is loaded by the harness) or rarely needed for resumption.

Extract only:
- What was in progress
- What's next
- What's blocked

If `tasks/todo.md` is over ~500 lines, read the last 100 lines only — the current state lives at the bottom.

## Step 3: Git State

Run a single combined git check: branch + status (short) + last 3 commits. One bash call. Flag uncommitted work or being on the wrong branch.

## Step 4: Deliver the Briefing

Format:

```
## Resume — [Project]

**Branch:** `branch-name` | **Last commit:** [date]

### Where You Left Off
- [1 line from todo.md]

### Git
- [Clean | N uncommitted | unpushed]

### Next
- [Top item from todo.md, or "Pick from backlog"]
```

Keep under 10 lines. No padding. Omit empty sections entirely — don't write "No changes."

## What This Skill Does NOT Do

- No Linear queries (use `/resume-deep`)
- No cross-project scan (use `/resume-deep`)
- No reading `lessons.md` or `decisions.md` (load on demand only when relevant to the next task)
- No Notion (we're not using Notion as a system of record)
- No file rewrites
- No suggesting next actions beyond reading the top of `todo.md`

## Why Lean

`/resume` runs at the start of every session. Heavy resumption skills prime the context with 30-80k tokens of preamble before the user has typed a single working prompt — and that preamble re-caches on every subsequent turn. On long sessions this compounds into 40-150M token sessions. Keep this skill cheap so it can run every time without penalty.

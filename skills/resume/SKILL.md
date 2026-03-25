---
name: resume
description: Start-of-session briefing. Reads session memory files, checks Linear and Notion for teammate updates, reviews git state, scans other active projects, suggests next action, and delivers a concise catch-up. Use when starting a new session, resuming work, or when the user says "catch me up", "where were we", "what's changed", or "resume". Counterpart to /wrap.
user_invocable: true
---

# Session Resume

Deliver a fast, structured briefing so the user knows exactly where they are and what changed since last session. This is the start-of-session counterpart to `/wrap`.

See `references/projects.md` for the full project registry, query patterns, and configuration.

## Step 1: Identify the Project and Session Window

Determine the active project from the current working directory. Check for `tasks/todo.md`, `tasks/lessons.md`, and `docs/decisions.md`. If none exist, check `CLAUDE.md` for project context.

**If no project is identified** (e.g. working from `~/` with no project files), skip Steps 2-4 and 9. Go straight to Step 5 (git state), then Step 6 (other projects scan), then Step 7 (suggest switching to a project with activity). Deliver a minimal briefing: skip the Branch/Sprint/Phase header, skip Where You Left Off, skip What Changed. Just show Other Projects, Suggested Next (recommend which project to switch to), and Warnings.

**If the directory is not a git repo**, skip Step 5 entirely.

**Determine the lookup window:**

1. Check for `.last_session` file in the project root. If it exists, use that timestamp as the start of the window.
2. If no `.last_session` file, fall back to day-of-week logic: 24 hours for weekday sessions, 7 days for Monday sessions.

Store the resolved window start as `$SINCE` for use in all subsequent queries.

## Step 2: Read Session Memory Files

Read these files in parallel:

1. `tasks/todo.md` — current sprint, next actions, blockers
2. `tasks/lessons.md` — corrections and gotchas from prior sessions
3. `docs/decisions.md` — architecture decisions and rationale

Also read the project's `CLAUDE.md` if present, to confirm current architecture and conventions.

Do not summarise every line. Extract only:
- What was in progress last session
- What's next in the queue
- What's blocked and on whom

## Step 3: Check Linear for Updates

Query the project's Linear board for issues updated since `$SINCE`. Also check for project-level status updates.

Compare the current state against what `tasks/todo.md` says. Flag:

- **Status changes** — issues that moved (especially blockers that are now resolved)
- **New issues** — created by teammates since last session
- **Reassignments** — work that shifted between team members
- **Priority changes** — anything bumped up or down
- **Comments** — use `get_issue` to check for comments on issues where `updatedAt` changed but status did not
- **Project updates** — status updates posted by teammates (like architecture notes or progress reports)

If no Linear project is configured for this directory, skip this step.

## Step 4: Check Notion for Updates

Two sub-steps:

### 4a: Recent Changes

Search Notion for pages created or updated since `$SINCE` in the project's space.

Flag any new or updated pages from teammates. Focus on: decision documents, roadmap changes, meeting notes, design docs.

### 4b: Key Doc Sync Check

For each Key Notion Page listed in `references/projects.md`, fetch the page and compare against local session files:

- Does the Notion roadmap match the phase/milestone in `tasks/todo.md`?
- Are there Notion decision log entries not reflected in `docs/decisions.md`?
- Any new pages created by teammates that should inform the current sprint?

If the project has no Notion space configured, skip this step.

## Step 5: Check Git State

Check the current branch, uncommitted changes, recent commits, and commits ahead of main.

Flag:
- Uncommitted changes (might be work-in-progress from last session)
- Being on the wrong branch (e.g. on `main` when sprint work is on a feature branch)
- Unpushed commits

## Step 6: Quick Scan Other Projects

For every project in `references/projects.md` that is NOT the current working directory, run a lightweight check:

1. **Git:** Check for new commits since `$SINCE`.
2. **Linear:** If configured, count issues updated since `$SINCE` (don't fetch details).
3. **Summary:** One line per project. Example: `NH Rugby: 3 Linear updates, 2 new commits` or `QCC: no changes`

Do NOT read session files, Notion pages, or issue details for non-current projects. Keep this fast. If a project shows significant activity, note it so the user can switch and run `/resume` there if needed.

## Step 7: Suggest Next Action

Based on everything gathered, recommend what to work on this session. Use this priority logic:

1. **Unblocked items** — was something blocked last session that's now resolved? Lead with that.
2. **In-progress work** — if something was mid-flight, suggest continuing it.
3. **Highest priority backlog** — next item in the sprint backlog that has no blockers.
4. **Context from teammates** — if a teammate's update changes what's most valuable to work on, flag it.

Frame as a suggestion, not a directive. Example:
> **Suggested:** ENG-62 (Firebase ETL) has no blockers and is next in the sprint backlog. ENG-61 is still waiting on Joe's Supabase access.

## Step 8: Deliver the Briefing

Present a structured briefing in this exact format:

```
## Session Briefing — [Project Name]

**Branch:** `branch-name` | **Sprint:** [sprint name] | **Phase:** [phase]
**Last session:** [timestamp from .last_session or "unknown"]

### Where You Left Off
- [1-2 lines: last task worked on, its status]

### What Changed
**Linear:** [summary or "No changes" — omit this line entirely if no Linear project is configured]
**Notion:** [summary or "No changes" — omit this line entirely if no Notion space is configured]
**Git:** [summary or "Clean"]

### Blockers
- [What's blocked and on whom, or "None"]

### Other Projects
- [One line per project with activity, or "All quiet"]

### Suggested Next
- [Recommended task with reasoning]

### Warnings
- [Uncommitted changes, wrong branch, stale todo, or "None"]
```

Keep the entire briefing under 25 lines. No fluff. No commentary on the briefing itself.

## Step 9: Sync Session Files if Needed

If Linear or Notion show changes that make `tasks/todo.md` stale (e.g. a blocker was resolved, an issue was completed by a teammate, a roadmap shifted), update the todo file to reflect reality. Note what changed.

Do not rewrite the entire file. Only update what's out of sync.

## When to Skip Steps

- **No Linear project:** Skip Step 3 entirely.
- **No Notion space:** Skip Step 4 entirely.
- **No .last_session file:** Fall back to day-of-week logic for the lookup window.
- **No other projects in registry:** Skip Step 6.
- **Clean state everywhere:** Collapse the briefing — don't pad with "No changes" on every line. Just say "No changes since last session" and go straight to Suggested Next.

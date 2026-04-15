---
name: resume-deep
description: Comprehensive start-of-session briefing with Linear sync, full session memory review, and cross-project scan. Higher token cost than /resume. Use weekly (Mondays), after extended time away, or when the user explicitly asks for a "deep resume", "full briefing", "what's changed everywhere", or "weekly catch-up". For fast daily resumption, use /resume instead.
user_invocable: true
---

# Session Resume (Deep)

Full briefing: project state + Linear updates + cross-project scan. Higher token cost than `/resume`. Use weekly or after extended absence.

See `references/projects.md` for the project registry and Linear configuration.

## Step 1: Identify the Project and Session Window

Determine the active project from the current working directory. Check for `tasks/todo.md`, `tasks/lessons.md`, and `docs/decisions.md`.

**If no project is identified** (e.g. working from `~/`), skip Steps 2 and 8. Go to Step 4 (git), Step 5 (other projects), then deliver a minimal briefing recommending which project to switch to.

**If the directory is not a git repo**, skip Step 4 entirely.

**Determine the lookup window:**

1. Check for `.last_session` file in the project root. If it exists, use that timestamp.
2. Otherwise: 24 hours for weekday sessions, 7 days for Monday sessions.

Store the resolved window start as `$SINCE`.

## Step 2: Read Session Memory Files

Read in parallel:
1. `tasks/todo.md` — current sprint, next actions, blockers
2. `tasks/lessons.md` — corrections and gotchas
3. `docs/decisions.md` — architecture decisions

Skip `CLAUDE.md` — already loaded by the harness, reading it again doubles it in context.

Extract only:
- What was in progress last session
- What's next
- What's blocked and on whom

## Step 3: Check Linear

Query the project's Linear board for issues updated since `$SINCE`. Also check project-level status updates.

Flag:
- **Status changes** — especially resolved blockers
- **New issues** — created by teammates
- **Reassignments** — work that shifted between people
- **Priority changes**
- **Comments** — use `get_issue` if `updatedAt` changed but status didn't
- **Project status updates** — posted by teammates

If no Linear project is configured for this directory, skip this step.

## Step 4: Git State

Branch, uncommitted changes, recent commits, commits ahead of main. Flag work-in-progress or wrong-branch issues.

## Step 5: Quick Scan Other Projects

For every project in `references/projects.md` that is NOT the current directory:

1. **Git:** `git -C <project_dir> log --oneline --since="<last_session>"` — any new commits?
2. **Linear:** If configured, count issues updated since `$SINCE` (count only, no detail).
3. **Summary:** One line per project. Example: `NH Rugby: 3 Linear updates, 2 new commits`.

Do NOT read session files or fetch issue details for non-current projects. Keep this fast.

## Step 6: Suggest Next Action

Priority logic:

1. **Unblocked items** — was something blocked last session that's now resolved?
2. **In-progress work** — if something was mid-flight, suggest continuing it
3. **Highest priority backlog** — next sprint item with no blockers
4. **Context shift from teammates** — if a teammate's update changes what's most valuable

Frame as a suggestion, not a directive.

## Step 7: Deliver the Briefing

```
## Deep Resume — [Project Name]

**Branch:** `branch-name` | **Sprint:** [name] | **Phase:** [phase]
**Last session:** [timestamp from .last_session or "unknown"]

### Where You Left Off
- [1-2 lines: last task worked on, its status]

### What Changed
**Linear:** [summary or omit if no Linear configured]
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

Keep under 25 lines.

## Step 8: Sync Session Files if Needed

If Linear shows changes that make `tasks/todo.md` stale (e.g. a blocker was resolved, an issue was completed by a teammate), update the todo file to reflect reality.

Do not rewrite the entire file. Only patch what's out of sync.

## When to Skip Steps

- **No Linear project:** Skip Step 3.
- **No `.last_session` file:** Fall back to day-of-week logic.
- **No other projects in registry:** Skip Step 5.
- **Clean state everywhere:** Collapse the briefing — don't pad with "No changes" on every line.

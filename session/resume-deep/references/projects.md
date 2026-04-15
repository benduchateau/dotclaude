# Project Registry for /resume-deep

## Active Projects

| Directory | Linear Project | Team | Key Files |
|-----------|---------------|------|-----------|
| `~/projects/NH-Rugby-Intel-Platform/` | NH Rugby Intel Hub | Engineai (ENG) | `tasks/todo.md`, `tasks/lessons.md`, `docs/decisions.md` |
| `~/projects/engineai_website/` | — | — | Check for `tasks/` or `CLAUDE.md` |
| `~/projects/copilotagent/` | — | — | Check for `tasks/` or `CLAUDE.md` |
| `~/projects/QCC_website/` | — | — | Check for `tasks/` or `CLAUDE.md` |
| `~/projects/Engineai_CRM/` | — | — | Check for `tasks/` or `CLAUDE.md` |

## Linear Query Patterns

```
# Use .last_session timestamp if it exists, otherwise duration
list_issues(project="<project name>", updatedAt="-P1D", orderBy="updatedAt")

# Monday / start-of-week fallback
list_issues(project="<project name>", updatedAt="-P7D", orderBy="updatedAt")

# Project-level status updates
get_status_updates(type="project", project="<project name>", createdAt="-P1D")
```

## What Counts as a "Change" from Teammates

Flag in the briefing:
- Issues moved to a different status (Backlog -> In Progress -> Done)
- Issues assigned or reassigned
- New issues created by someone other than the user
- Comments added (check via `get_issue` if `updatedAt` changed but status didn't)
- Blockers resolved
- Priority changes
- Project status updates

## Quick Scan for Non-Current Projects

For projects that are NOT the current working directory, only check:

1. `git -C <project_dir> log --oneline --since="<last_session>"` — any new commits?
2. Linear: count issues updated since `$SINCE` (count only, no detail)
3. One-line summary: "NH Rugby: 3 Linear updates, 1 new commit" or "QCC: no changes"

Do not read session files for non-current projects. Keep the scan fast.

## .last_session File

Location: `<project_dir>/.last_session`

Written by `/wrap` at end of each session. Read by `/resume-deep` to determine the lookup window.

Format:
```
2026-03-24T10:30:00+13:00
```

Single line, ISO 8601 with timezone. If the file doesn't exist, fall back to day-of-week logic (24h daily, 7d Monday).

Add `.last_session` to `.gitignore` — it's local session state, not project code.

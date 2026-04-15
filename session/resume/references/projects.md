# Project Registry for /resume

## Active Projects

| Directory | Linear Project | Team | Notion Space | Key Notion Pages | Key Files |
|-----------|---------------|------|-------------|-----------------|-----------|
| `~/projects/NH-Rugby-Intel-Platform/` | NH Rugby Intel Hub | Engineai (ENG) | NH Rugby | Product Roadmap, Decision Log, Document Hub | `tasks/todo.md`, `tasks/lessons.md`, `docs/decisions.md` |
| `~/projects/engineai_website/` | — | — | Engine AI | — | Check for `tasks/` or `CLAUDE.md` |
| `~/projects/copilotagent/` | — | — | — | — | Check for `tasks/` or `CLAUDE.md` |
| `~/projects/QCC_website/` | — | — | — | — | Check for `tasks/` or `CLAUDE.md` |

## Linear Query Patterns

To check for recent changes by teammates:

```
# Use .last_session timestamp if it exists, otherwise fall back to duration
list_issues(project="<project name>", updatedAt="-P1D", orderBy="updatedAt")

# Monday / start-of-week fallback
list_issues(project="<project name>", updatedAt="-P7D", orderBy="updatedAt")

# Also check project-level status updates
get_status_updates(type="project", project="<project name>", createdAt="-P1D")
```

## What Counts as a "Change" from Teammates

Flag these in the briefing:
- Issues moved to a different status (e.g. Backlog -> In Progress, In Progress -> Done)
- Issues assigned or reassigned
- New issues created by someone other than the user
- Comments added (check via get_issue if updatedAt changed but status didn't)
- Blockers resolved (issues we were waiting on that are now Done or In Progress)
- Priority changes
- Project status updates (like Joe's Opta schema update)

## Notion Query Patterns

### Recent changes (for briefing)
```
# Search for recent updates in the project's Notion space
notion-search(query="<project name>", filters={created_date_range: {start_date: "<last_session_date>"}}, page_size=10, max_highlight_length=100)
```

### Key doc sync check
For each project that has Key Notion Pages listed, fetch those pages and compare against local session files. Flag if:
- Notion roadmap shows a phase/milestone that doesn't match todo.md
- Notion decision log has entries not reflected in docs/decisions.md
- New pages created by teammates since last session

## Quick Scan for Non-Current Projects

For projects that are NOT the current working directory, only check:
1. `git -C <project_dir> log --oneline -1 --since="<last_session>"` -- any new commits?
2. Linear: any issues updated since last session? (count only, no detail)
3. One-line summary: "NH Rugby: 3 Linear updates, 1 new commit" or "QCC: no changes"

Do not read session files or Notion for non-current projects. Keep the scan fast.

## .last_session File

Location: `<project_dir>/.last_session`

Written by `/wrap` at end of each session. Read by `/resume` to determine the lookup window.

Format:
```
2026-03-24T10:30:00+13:00
```

Single line, ISO 8601 with timezone. If the file doesn't exist, fall back to day-of-week logic (24h daily, 7d Monday).

Add `.last_session` to `.gitignore` -- it's local session state, not project code.

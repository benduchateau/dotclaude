# New Project Setup

Scaffold a new project in the current directory and generate a populated CLAUDE.md.

## Instructions

1. Check if CLAUDE.md already exists in the current directory. If it does, stop and tell Ben — don't overwrite.

2. Ask Ben for the following (collect all answers before doing anything):
   - **Project name** — e.g. "Stellar Recruitment Phase 1"
   - **Client or owner** — e.g. "Stellar Recruitment" or "Internal / Engine AI"
   - **One-line purpose** — what is this project actually for?
   - **Stack** — what's being built with (framework, DB, deployment, etc.)
   - **Key people** — stakeholders, sponsors, product owners (if any)
   - **Primary constraint** — the one thing Claude Code must never do or assume in this project

3. Create the following files using the answers:
   - `CLAUDE.md` — populated with project details (use PROJECT_CLAUDE.md template structure)
   - `tasks/todo.md` — with project name filled in, one starter task: "Initial project setup"
   - `tasks/lessons.md` — with project name filled in, blank otherwise
   - `docs/decisions.md` — with project name filled in, blank otherwise

4. Confirm what was created with a short file tree summary.

5. Tell Ben the next step: open a Claude Code session in this folder and it will load global + project context automatically.

## Notes

- Do not copy placeholder text like {{PROJECT_NAME}} into the output — replace all tokens with real values
- Keep CLAUDE.md tight — 60-100 lines max
- If Ben skips a field, use a sensible default and note it

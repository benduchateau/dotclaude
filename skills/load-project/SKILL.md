---
name: load-project
description: >
  Guided walkthrough for opening an existing project and getting it running locally.
  Use this skill when starting work on a project, loading a project, opening a repo,
  or when unsure how to get a project running. Paint-by-numbers approach for new coders.
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
  - Glob
---

# Load Project

Step-by-step guided workflow for opening an existing project and getting it running.
One step at a time. Explains what each step does and why.

## Step 1: Pick a project

List all directories in `~/projects/` with a short description of each (based on directory name and any README or package.json found inside).

Present them as a numbered list. Ask: **"Which project do you want to work on?"**

Wait for the answer before continuing.

## Step 2: Move into the project

`cd` into the selected project directory. Confirm the path.

Tell the user: *"We're now inside [project name]. This is where all the code lives."*

## Step 3: Check git status

Run `git status` and explain what it shows in plain language:

- **Branch:** "You're on the [branch] branch. Think of branches as separate copies of the code you can work on independently."
- **Clean/dirty:** If there are uncommitted changes, list them and explain: *"These are files that have been changed but not saved to git yet. That's fine for now."*
- **Behind remote:** If the branch is behind, explain: *"There are newer changes on GitHub that you don't have yet. We'll grab those next."*

## Step 4: Pull latest changes

If the project has a remote and the branch is behind (or we're unsure), run `git pull`.

- If it works cleanly: *"Got the latest code from GitHub."*
- If there's a merge conflict: Stop and explain the situation. Do not auto-resolve. Ask what to do.
- If there's no remote: *"This project isn't connected to GitHub, so there's nothing to pull. That's fine."*

## Step 5: Install dependencies

Check what kind of project this is and install accordingly:

| Indicator | Command | Explanation |
|---|---|---|
| `package.json` exists | `npm install` | *"This downloads all the libraries the project needs. They go into a folder called node_modules."* |
| `requirements.txt` exists | `pip install -r requirements.txt` | *"This installs the Python libraries the project depends on."* |
| `pyproject.toml` exists | `pip install -e .` | *"This installs the Python project in development mode."* |
| None of the above | Skip | *"No dependencies to install. This project is self-contained."* |

If `node_modules/` already exists and `package.json` hasn't changed recently, mention: *"Dependencies look up to date, but running install anyway to be safe. This is quick if nothing changed."*

## Step 6: Check for environment variables

Look for `.env.example`, `.env.local.example`, or `.env.template` files.

- If found and no `.env` / `.env.local` exists: Warn the user. *"This project needs environment variables (like API keys and secrets). There's a template at [file] but no actual .env file yet. You may need to create one. Want me to help set that up?"*
- If `.env` already exists: *"Environment variables are already configured."*
- If no template exists: Skip silently.

Do NOT read or display the contents of any `.env` file. Just confirm it exists.

## Step 7: Start the dev server

Check `package.json` scripts for the dev command (usually `dev`, sometimes `start`).

Run it and explain: *"Starting the local development server. This runs the project on your computer so you can see it in a browser."*

Report the URL once it's running (usually `http://localhost:3000`).

If this is not a web project (no dev server), skip and say: *"This project doesn't have a dev server. You're ready to start working on it directly."*

## Step 8: Health check

Confirm everything is good:

- Dev server responding (if applicable)
- No obvious errors in the terminal
- Git is in a clean state (or note what's uncommitted)

Give a one-line summary: *"[Project name] is up and running at [URL]. You're on the [branch] branch. Ready to go."*

## Principles

- **One step at a time.** Complete each step before moving to the next.
- **Explain everything.** Assume the user has never done this before. Use plain language.
- **No jargon without context.** If a technical term is unavoidable, define it in one sentence.
- **Ask before acting** on anything destructive or ambiguous.
- **Keep it encouraging.** Learning to code is hard. Be supportive without being patronising.

---
name: Autoresearch skill optimisation tool
description: Karpathy-style skill optimisation loop — cloned from olelehmann100kMRR/autoresearch-skill on 2026-03-25. Binary evals, mutation, scoring.
type: reference
---

## Autoresearch

- **Origin:** Cloned from `github.com/olelehmann100kMRR/autoresearch-skill` on 2026-03-25
- **Local clone:** `~/projects/autoresearch-skill/` (contains SKILL.md and eval-guide.md)
- **Installed copy:** `~/.claude/skills/autoresearch/`
- **Also:** `~/copy_autoresearch/` exists (likely a working copy)

### How it works
Runs a skill repeatedly, scores outputs against binary evals, mutates the prompt, keeps improvements. Based on Karpathy's autoresearch methodology.

### Results so far
- `/wrap` skill: optimised from 96% to 100% on 2026-03-25
- `/resume` skill: optimised from 80% to 100% on 2026-03-25
- Results and dashboards stored in each skill's `autoresearch-*/` subdirectory

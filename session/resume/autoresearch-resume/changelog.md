# Autoresearch Changelog — resume skill

| Experiment | Action | Mutation | Score | Result |
|---|---|---|---|---|
| 0 | baseline | N/A | 20/25 (80%) | Baseline established |
| 1 | keep | Added non-project fallback (Step 1) + omit unconfigured integration lines from template | 25/25 (100%) | All 5 evals pass across all 5 scenarios |
| 2 | keep | Removed literal API call code blocks from Steps 3 and 4; replaced with intent-only descriptions | 25/25 (100%) | Score holds. Query patterns still in references/projects.md |
| 3 | keep | Simplified git commands in Steps 5 and 6 to intent-only descriptions | 25/25 (100%) | Score holds. All 4 git checks enumerated by name. |

---

## Experiment 1 — keep

**Score:** 25/25 (100%)
**Change:** Two mutations: (1) Added non-project dir fallback to Step 1 with minimal briefing format and non-git skip. (2) Changed template's Linear/Notion lines to say "omit this line entirely if not configured."
**Reasoning:** Baseline failed 5 evals across S2/S3/S4. S4 had no handling for non-project dirs (3 eval failures). S2/S3 showed "Linear: No changes" for projects that don't have Linear (misleading).
**Result:** All 5 scenarios now pass all 5 evals. 80% to 100% in one experiment.
**Failing outputs:** None.

## Experiment 2 — keep

**Score:** 25/25 (100%)
**Change:** Removed `list_issues(...)`, `get_status_updates(...)`, and `notion-search(...)` code blocks from Steps 3 and 4. Replaced with intent-only sentences.
**Reasoning:** Agents know how to call Linear/Notion tools. The literal API examples were prescriptive detail that added length. Query patterns remain in references/projects.md for reference.
**Result:** Score held. Skill is shorter with no information loss.
**Failing outputs:** None.

## Experiment 3 — keep

**Score:** 25/25 (100%)
**Change:** Replaced 4 literal git commands in Step 5 with "Check the current branch, uncommitted changes, recent commits, and commits ahead of main." Also simplified Step 6 git command.
**Reasoning:** Same simplification pattern. All 4 git checks are enumerated by name so no ambiguity. Agents know git.
**Result:** Score held. EVAL4 (Accurate git) specifically verified across all scenarios. The intent-only description is unambiguous because it lists all checks.
**Failing outputs:** None.

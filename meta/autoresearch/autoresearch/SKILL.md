---
name: autoresearch
description: "Autonomously optimise any Claude Code skill by running it repeatedly, scoring outputs against binary evals, mutating the prompt, and keeping improvements. Based on Karpathy's autoresearch methodology. Use when: optimize this skill, improve this skill, run autoresearch on, make this skill better, self-improve skill, benchmark skill, eval my skill, run evals on. Outputs: an improved SKILL.md, a results log, and a changelog of every mutation tried."
---

# Autoresearch for Skills

Most skills work about 70% of the time. The other 30% you get garbage. The fix isn't to rewrite the skill from scratch. It's to let an agent run it dozens of times, score every output, and tighten the prompt until that 30% disappears.

This skill adapts Andrej Karpathy's autoresearch methodology (autonomous experimentation loops) to Claude Code skills. Instead of optimising ML training code, we optimise skill prompts.

---

## the core job

Take any existing skill, define what "good output" looks like as binary yes/no checks, then run an autonomous loop that:

1. Generates outputs from the skill using test inputs
2. Scores every output against the eval criteria with adversarial rigour
3. Mutates the skill prompt using a structured taxonomy of changes
4. Keeps mutations that improve the score, discards the rest
5. Checkpoints state after every experiment so the loop can resume if interrupted
6. Repeats until the score ceiling is hit or the user stops it

**Output:** An improved SKILL.md + `results.tsv` log + `changelog.md` of every mutation attempted.

---

## before starting: gather context

**STOP. Do not run any experiments until all fields below are confirmed with the user. Ask for any missing fields before proceeding.**

1. **Target skill** -- Which skill do you want to optimise? (need the exact path to SKILL.md)
2. **Test inputs** -- What 3-5 different prompts/scenarios should we test the skill with? (variety matters -- pick inputs that cover different use cases so we don't overfit to one scenario)
3. **Eval criteria** -- What 3-6 binary yes/no checks define a good output? (these are your "test questions" -- see [eval-guide.md](eval-guide.md) for how to write good evals)
4. **Runs per experiment** -- How many times should we run the skill per mutation? Default: 5. (more runs = more reliable scores, but slower and more expensive. 5 is the sweet spot for most skills.)
5. **Budget cap** -- Optional. Max number of experiment cycles before stopping. Default: 20 cycles.

---

## step 0: estimate cost and confirm

Before running anything, estimate the token cost so the user knows what they're signing up for.

**Rough formula:**
```
tokens_per_run = (skill_length_tokens x 2) + estimated_output_tokens
runs_per_experiment = [N from config]
estimated_experiments = budget_cap or 15 (typical)
total_tokens = tokens_per_run x runs_per_experiment x estimated_experiments x 2 (scoring overhead)
```

Present to the user:
```
Cost estimate:
  ~[X] tokens per skill run
  ~[Y] runs total ([N] per experiment x ~[E] experiments)
  ~[Z] total tokens (roughly $[cost] at current API rates)
```

If the estimate is over 2M tokens, flag it explicitly and confirm before proceeding. This is a guardrail, not a hard stop.

---

## step 1: read the skill

Before changing anything, read and understand the target skill completely.

1. Read the full SKILL.md file
2. Read any referenced files (check for relative paths to other docs, examples, references)
3. Identify the skill's core job, process steps, and output format
4. Note any existing quality checks or anti-patterns already in the skill
5. Count the skill's approximate token length (needed for cost estimation)

Do NOT skip this. You need to understand what the skill does before you can improve it.

---

## step 2: build the eval suite

Convert the user's eval criteria into a structured test. Every check must be binary -- pass or fail, no scales.

**Format each eval as:**

```
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [What "yes" looks like -- be specific]
Fail condition: [What triggers a "no"]
Evidence required: [What the scorer must quote from the output to justify the decision]
```

The "Evidence required" field is critical for scoring accuracy. It forces the scorer to point at specific text rather than making a vibes-based call.

**Rules for good evals:**
- Binary only. Yes or no. No "rate 1-7" scales. Scales compound variability and give unreliable results.
- Specific enough to be consistent. "Is the text readable?" is too vague. "Are all words spelled correctly with no truncated sentences?" is testable.
- Not so narrow that the skill games the eval. "Contains fewer than 200 words" will make the skill optimise for brevity at the expense of everything else.
- 3-6 evals is the sweet spot. More than that and the skill starts parroting eval criteria back instead of actually improving.
- Each eval must be independently scoreable. No eval should depend on another's result.

See [eval-guide.md](eval-guide.md) for detailed examples of good vs bad evals.

**Max score calculation:**
```
max_score = [number of evals] x [runs per experiment]
```

Example: 4 evals x 5 runs = max score of 20.

---

## step 3: set up the working directory

Create the experiment workspace and initialise tracking.

1. Create working directory: `autoresearch-[skill-name]/` inside the skill's parent folder
2. Create `autoresearch-[skill-name]/outputs/` for raw output capture
3. Back up the original skill: copy SKILL.md to `autoresearch-[skill-name]/SKILL.md.baseline`
4. If inside a git repo: create a branch `autoresearch/[skill-name]` and commit the baseline. This gives you version history for every kept mutation, not just a single backup file.
5. Create `results.tsv` with the header row:
   ```
   experiment	score	max_score	pass_rate	status	strategy	description
   ```
6. Create empty `changelog.md`
7. Create `checkpoint.json` (see session recovery section)

---

## how to "run" a skill

This is the most important section. When this skill says "run the target skill", here is what that means concretely in Claude Code.

**You cannot invoke a skill recursively from within another skill.** Instead, you simulate the skill execution:

1. **Read** the target SKILL.md content (you already have it from step 1)
2. **For each test input**, act as if you are that skill being invoked with that input:
   - Follow the skill's instructions step by step
   - Use the same tools the skill would use (Write, Bash, Edit, etc.)
   - Produce the output the skill specifies
3. **Capture the output** -- save it to `autoresearch-[skill-name]/outputs/experiment-[N]/run-[M].md` (or whatever file type the skill produces)

**For parallel execution** (recommended when runs_per_experiment > 3):

Use the Agent tool to run multiple test inputs simultaneously. Brief each sub-agent with:
- The full content of the current SKILL.md (not a path -- paste the actual content so the agent has it)
- One specific test input
- Instructions to produce the output and save it to a specific path (give the full absolute path)
- Do NOT have the sub-agent score its own output (scoring happens separately -- see next section)

Collect all outputs from the sub-agents, then score them in a dedicated pass.

**What "running" looks like depends on the skill type:**

| Skill type | How to simulate it |
|---|---|
| Writing skills (proposals, emails, copy) | Generate the text following the skill's instructions, save to file |
| Code generation skills | Write the code to a file, optionally execute it to check for errors |
| Analysis skills | Run the analysis, capture the output |
| Visual/design skills | Generate the code/markup, save to file |
| Multi-step workflow skills | Follow each step, capture final output |

---

## scoring: mitigating self-assessment bias

The same model that generates output will score it. LLMs are lenient self-graders. This section counteracts that.

**Scoring protocol:**

1. **Score with adversarial framing.** When evaluating outputs, adopt this mindset:
   > "You are a strict quality auditor. Your job is to find failures. A pass must be justified with specific evidence from the output. When in doubt, fail it."

2. **Require evidence for every score.** For each eval on each output, the scorer must:
   - Quote the specific text or element that justifies the decision
   - If no specific evidence can be quoted, the eval FAILS (absence of evidence = fail)

3. **Devil's advocate pass.** After initial scoring, review all "pass" decisions and actively look for reasons to flip any to "fail". This single step catches most self-grading leniency.

4. **Cross-run consistency check.** If the same eval passes on some runs but fails on others for similar outputs, the eval is too subjective. Tighten the eval criteria before continuing. Do not accept the variance.

**Scoring output format (for each run):**
```
RUN [M] -- Input: "[test input summary]"
  EVAL 1 [pass/FAIL]: "[quoted evidence]"
  EVAL 2 [pass/FAIL]: "[quoted evidence]"
  ...
  Run score: [X]/[max]
```

FAIL is capitalised. Failures should be visually obvious in the log.

**Save scoring details** to `autoresearch-[skill-name]/outputs/experiment-[N]/scores.md` so the reasoning is auditable.

---

## step 4: establish baseline

Run the skill AS-IS before changing anything. This is experiment #0.

1. Run the skill [N] times using the test inputs (rotate through inputs if N > number of inputs)
2. Score every output using the adversarial scoring protocol
3. Record the baseline score in results.tsv
4. Update checkpoint.json
5. Print the baseline summary to the terminal:

```
--- BASELINE (experiment 0) ---
Score: 14/20 (70.0%)
Per-eval breakdown:
  Text legibility:  ########..  4/5
  Pastel colours:   ##########  5/5
  Linear layout:    ######....  3/5
  No numbering:     ####......  2/5
--------------------------------
```

**IMPORTANT:** After establishing baseline, confirm the score with the user before proceeding. If baseline is already 90%+, the skill may not need optimisation -- ask the user if they want to continue.

---

## step 5: the mutation taxonomy

When choosing what to change, work through this taxonomy. Start with the strategy most likely to fix the most common failure.

| # | Strategy | When to use | Example |
|---|---|---|---|
| 1 | **Exemplify** | Skill lacks a worked example of correct output | Add a complete example showing the desired result |
| 2 | **Constrain** | Recurring unwanted pattern in outputs | Add "NEVER do X" or "Do NOT include Y" |
| 3 | **Reorder** | A critical instruction is buried deep in the skill | Move it to the top of its section or into the first paragraph |
| 4 | **Clarify** | An instruction is ambiguous, outputs interpret it differently | Replace vague wording with specific, testable language |
| 5 | **Simplify** | Skill is over-optimising for one eval at the expense of others | Remove or soften an over-dominant instruction |
| 6 | **Negate** | A failure keeps happening despite positive instructions | Add the explicit opposite: "X, not Y" |
| 7 | **Decompose** | A complex instruction is being partially followed | Break it into numbered sub-steps |
| 8 | **Merge** | Two instructions interact badly or contradict each other | Combine them into one coherent directive |

**Rules:**
- Apply ONE strategy per experiment. Never stack multiple changes.
- Start at the top of the taxonomy for each new failure pattern. Exemplify and Constrain solve most problems.
- If a strategy doesn't help after 2 attempts on the same failure, move to the next one down.
- Track which strategies you've tried per failure in the changelog so you don't repeat yourself.

---

## step 6: run the experiment loop

This is the core autoresearch loop. Once started, run autonomously until a stop condition is met.

**LOOP:**

1. **Analyse failures.** Look at which evals are failing most across all runs. Read the actual outputs that failed. Read the scoring evidence. Identify the pattern.

2. **Select a mutation strategy** from the taxonomy (step 5). Pick the one most likely to address the most common current failure.

3. **Form a hypothesis.** Write one sentence: "Changing [X] using [strategy] should fix [failure pattern] because [reason]." Log this in the changelog BEFORE making the change.

4. **Make the change.** Edit SKILL.md with ONE targeted mutation.

5. **Run the experiment.** Execute the skill [N] times with the same test inputs. Use sub-agents for parallel execution when practical.

6. **Score it** using the adversarial scoring protocol.

7. **Decide: keep or discard.**
   - Score improved -> **KEEP.** If using git, commit the change with message: `autoresearch: [strategy] - [description]`. This is the new baseline.
   - Score stayed the same -> **DISCARD.** Revert SKILL.md to previous version. The change added complexity without improvement.
   - Score got worse -> **DISCARD.** Revert SKILL.md to previous version.

8. **Update tracking.** Append to results.tsv, append to changelog.md, update checkpoint.json.

9. **Print progress** to the terminal:
   ```
   --- Experiment [N] -- [KEEP/DISCARD] ---
   Score: [X]/[max] ([percent]%) [+N / -N / =]
   Strategy: [taxonomy name]
   Change: [one-line description]
   Best so far: [X]/[max] ([percent]%)
   Consecutive discards: [N]
   ----------------------------------------
   ```

10. **Repeat.** Go back to step 1 of the loop.

**Stop conditions (check after every experiment):**
- The user manually stops you
- Budget cap reached (default: 20 experiments)
- 95%+ pass rate sustained for 3 consecutive experiments (ceiling hit)
- 5 consecutive discards with no improvement (you're stuck -- present findings and ask the user for direction)

**If you run out of ideas:** Re-read the failing outputs with fresh eyes. Try combining two previous near-miss mutations. Try the opposite of something that helped (sometimes removing a fix reveals a better one). Try simplifying -- removing instructions while maintaining the score is always a win. If truly stuck, check whether the eval itself is the problem rather than the skill.

---

## session recovery

Context limits, crashes, and interruptions happen. The loop must be resumable.

**After every experiment**, update `checkpoint.json`:

```json
{
  "skill_name": "[name]",
  "skill_path": "[absolute path to SKILL.md]",
  "status": "running",
  "current_experiment": 3,
  "baseline_score": 70.0,
  "best_score": 90.0,
  "best_experiment": 2,
  "runs_per_experiment": 5,
  "budget_cap": 20,
  "consecutive_discards": 1,
  "test_inputs": ["input 1", "input 2"],
  "evals": [
    {
      "name": "Text legibility",
      "question": "Is all text fully legible?",
      "pass": "Every word complete and readable",
      "fail": "Any word partially hidden or cut off",
      "evidence": "Quote the illegible text"
    }
  ],
  "experiments": [
    {"id": 0, "score": 14, "max_score": 20, "pass_rate": 70.0, "status": "baseline", "strategy": "-"},
    {"id": 1, "score": 16, "max_score": 20, "pass_rate": 80.0, "status": "keep", "strategy": "constrain"},
    {"id": 2, "score": 16, "max_score": 20, "pass_rate": 80.0, "status": "discard", "strategy": "clarify"}
  ],
  "mutations_tried": [
    {"experiment": 1, "strategy": "constrain", "target_eval": "No numbering", "kept": true},
    {"experiment": 2, "strategy": "clarify", "target_eval": "Text legibility", "kept": false}
  ]
}
```

**To resume after interruption:**

1. When the autoresearch skill is invoked and a `checkpoint.json` already exists in the working directory, ask the user: "Found a previous run at experiment [N] with best score [X]%. Resume from there, or start fresh?"
2. If resuming: read checkpoint.json, verify the current SKILL.md matches expectations (compare against the last known state)
3. If the skill was modified externally since the last checkpoint, warn the user and ask how to proceed
4. Reload the eval suite and test inputs from the checkpoint
5. Continue the experiment loop from `current_experiment + 1`

The checkpoint file also serves as the data source for the optional dashboard (see below).

---

## step 7: write the changelog

After each experiment (whether kept or discarded), append to `changelog.md`:

```markdown
## Experiment [N] -- [KEEP/DISCARD]

**Score:** [X]/[max] ([percent]%)
**Strategy:** [taxonomy name from step 5]
**Hypothesis:** [one sentence -- what you expected to happen and why]
**Change:** [one sentence describing what was changed in the skill]
**Result:** [what actually happened -- which evals improved/declined]
**Evidence:** [brief quotes from outputs that drove the scoring decisions]
**Failing outputs:** [brief description of what still fails, if anything]
```

This changelog is the most valuable artefact. It's a research log that any future agent (or smarter future model) can pick up and continue from.

---

## step 8: deliver results

When the user returns or the loop stops, present:

1. **Score summary:** Baseline score -> Final score (percent improvement)
2. **Total experiments run:** How many mutations were tried
3. **Keep rate:** How many mutations were kept vs discarded
4. **Top 3 changes that helped most** (from the changelog)
5. **Remaining failure patterns** (what the skill still gets wrong, if anything)
6. **The improved SKILL.md** (already saved in place)
7. **Files produced:** Location of results.tsv, changelog.md, and checkpoint.json

If using git: "Changes are on branch `autoresearch/[skill-name]`. Review the commits and merge when satisfied."

---

## optional: live dashboard

If the user has browser access and wants a visual dashboard, generate a self-contained HTML file at `autoresearch-[skill-name]/dashboard.html`.

The dashboard should:
- Auto-refresh every 10 seconds (reads from checkpoint.json)
- Show a score progression line chart (experiment number on X, pass rate % on Y)
- Show a coloured bar for each experiment: green = keep, red = discard, blue = baseline
- Show a table of all experiments with: experiment #, score, pass rate, status, strategy, description
- Show per-eval breakdown: which evals pass most/least across all runs
- Use Chart.js from CDN for the line chart
- Clean styling: white background, pastel accents, sans-serif font

Generate as a single self-contained HTML file with inline CSS and JavaScript that reads checkpoint.json.

**This is optional.** The terminal progress output (printed after every experiment) is the primary feedback mechanism. Only generate the dashboard if the user asks for it or if you know they have browser access. Do not use `open` commands that assume macOS.

---

## output format

The skill produces these files in `autoresearch-[skill-name]/`:

```
autoresearch-[skill-name]/
  checkpoint.json         # resumable state (updated after every experiment)
  results.tsv             # score log for every experiment
  changelog.md            # detailed mutation log
  SKILL.md.baseline       # original skill before optimisation
  dashboard.html          # optional browser dashboard
  outputs/
    experiment-0/
      run-0.md            # raw output from each run
      run-1.md
      scores.md           # scoring evidence for this experiment
    experiment-N/
      ...
```

Plus the improved SKILL.md saved back to its original location.

**results.tsv example:**

```
experiment	score	max_score	pass_rate	status	strategy	description
0	14	20	70.0%	baseline	-	original skill -- no changes
1	16	20	80.0%	keep	constrain	added explicit anti-numbering instruction
2	16	20	80.0%	discard	clarify	tried enforcing left-to-right layout -- no improvement
3	18	20	90.0%	keep	exemplify	added colour palette hex codes instead of vague "pastel"
4	18	20	90.0%	discard	negate	added anti-pattern for neon colours -- no improvement
5	19	20	95.0%	keep	exemplify	added worked example showing correct label formatting
```

---

## example: optimising a diagram-generator skill

**Context gathered:**
- Target skill: `~/.claude/skills/diagram-generator/SKILL.md`
- Test inputs: "OAuth flow diagram", "CI/CD pipeline", "microservices architecture", "user onboarding funnel", "database schema relationships"
- Evals: (1) All text legible and spelled correctly? (2) Uses only pastel/soft colours? (3) Linear layout -- left-to-right or top-to-bottom? (4) Free of numbers, ordinals, and ordering?
- Runs per experiment: 10
- Max score: 40

**Cost estimate:**
- ~2,000 tokens per skill run (800 token skill x 2 + ~400 output)
- ~200 runs total (10 per experiment x ~20 experiments)
- ~800K total tokens with scoring overhead (~$2.40)
- User confirmed: proceed.

**Baseline run (experiment 0):**
Generated 10 diagrams. Scored each against 4 evals using adversarial protocol. Result: 32/40 (80%).
Common failures: 3 diagrams had numbered steps, 2 had bright red elements, 3 had illegible small text.

**Experiment 1 -- KEEP (35/40, 87.5%) -- Strategy: Constrain**
Hypothesis: Adding an explicit anti-numbering rule should eliminate numbered steps because the current skill never says not to use them.
Change: Added "NEVER include step numbers, ordinal numbers (1st, 2nd), or any numerical ordering in diagrams" to the anti-patterns section.
Result: Numbering failures dropped from 3 to 1. Other evals held steady.

**Experiment 2 -- DISCARD (34/40, 85%) -- Strategy: Constrain**
Hypothesis: Adding a minimum font size should fix illegible text.
Change: Added "All text must be minimum 14px font size."
Result: Legibility improved by 1, but colour compliance dropped by 2. The constraint pushed the skill to prioritise sizing over colour. Reverted.

**Experiment 3 -- KEEP (37/40, 92.5%) -- Strategy: Exemplify**
Hypothesis: Replacing vague "pastel colours" with specific hex codes should eliminate colour failures because the skill currently interprets "pastel" inconsistently.
Change: Replaced vague "pastel colors" instruction with specific hex codes: `#A8D8EA, #AA96DA, #FCBAD3, #FFFFD2, #B5EAD7`.
Result: Colour eval went from 8/10 to 10/10. Other evals held.

**Experiment 4 -- DISCARD (37/40, 92.5%) -- Strategy: Negate**
Hypothesis: Explicitly banning common problem colours should reinforce the hex code approach.
Change: Added anti-pattern "Do NOT use red (#FF0000), orange (#FF8C00), or neon green (#39FF14)."
Result: No change. The hex codes from experiment 3 already solved the colour problem. Reverted to keep skill simpler.

**Experiment 5 -- KEEP (39/40, 97.5%) -- Strategy: Exemplify**
Hypothesis: A worked example showing correct formatting should fix the remaining edge cases because the skill describes rules but never shows what "correct" looks like.
Change: Added a worked example showing a correct diagram with properly formatted labels (no numbers, pastel fills, left-to-right flow, legible text).
Result: Hit 39/40. One remaining failure: a complex diagram with overlapping labels. Diminishing returns -- stopped.

**Final delivery:**
- Baseline: 32/40 (80%) -> Final: 39/40 (97.5%)
- 5 experiments, 3 kept, 2 discarded (60% keep rate)
- Top changes: specific hex codes for colours (Exemplify), explicit anti-numbering rule (Constrain), worked example (Exemplify)
- Remaining issue: very complex diagrams occasionally get overlapping labels (1/40 failure rate)
- Changes on branch `autoresearch/diagram-generator` with 3 commits

---

## how this connects to other skills

**What feeds into autoresearch:**
- Any existing skill that needs optimisation
- User-defined eval criteria (or help them define evals using the eval guide)

**What autoresearch feeds into:**
- The improved skill replaces the original
- The changelog can be passed to future models for continued optimisation
- The eval suite can be reused whenever the skill is updated
- The checkpoint enables long-running optimisation across multiple sessions

---

## the test

A good autoresearch run:

1. **Started with a baseline** -- never changed anything before measuring the starting point
2. **Estimated cost** -- the user knew what they were signing up for before experiment 1
3. **Used binary evals only** -- no scales, no vibes, no "rate this 1-10"
4. **Changed one thing at a time** using the mutation taxonomy -- so you know exactly what helped
5. **Scored adversarially** -- evidence-based, strict, with devil's advocate review
6. **Kept a complete log** -- every experiment recorded with strategy, hypothesis, and evidence
7. **Improved the score** -- measurable improvement from baseline to final
8. **Didn't overfit** -- the skill got better at the actual job, not just at passing the specific test inputs
9. **Was resumable** -- checkpoint.json stayed current, could survive an interruption
10. **Ran autonomously** -- didn't stop to ask permission between experiments (but did stop when stuck after 5 consecutive discards)

If the skill "passes" all evals but the actual output quality hasn't improved -- the evals are bad, not the skill. Go back to step 2 and write better evals.

---
name: six-month-vision
description: "Daily AI trend intelligence for EngineAI. Searches the web for the latest AI news, funding, research, and product launches, then predicts which opportunities will be exploitable in 6 months. Outputs a prioritised strategy report covering where EngineAI should invest time, money, and effort to lead the next wave. Run automatically at 8pm nightly via cron, or invoke manually with /six-month-vision."
---

# Six Month Vision: AI Opportunity Intelligence

Daily AI trend scanning and 6-month opportunity forecasting for EngineAI.

## Purpose

To stay 6 months ahead of the market by systematically scanning the AI landscape every night, identifying which trends are approaching inflection points, and translating those signals into specific, actionable opportunities EngineAI can move on before the crowd arrives.

## When to Activate

- Runs automatically at 20:00 NZST every night via cron
- Invoke manually with `/six-month-vision` at any time for an on-demand scan
- Invoke with `/six-month-vision focus=<topic>` to deep-dive a specific area

---

## Research Phase: Web Intelligence Gathering

Search broadly and deeply across all source categories listed in `references/ai-sources.md`. Cover every category in a single run — do not skip any.

### Search Queries to Run (rotate and expand these each day)

**Funding and market signals:**
- "AI startup funding 2025" site:techcrunch.com OR site:venturebeat.com
- "AI Series A B 2025" recent
- "AI acquisition 2025"
- "AI enterprise deal" recent

**Technical capability signals:**
- "AI model release 2025" recent
- "open source LLM" recent
- "multimodal AI" recent
- "AI agent framework" recent
- "AI reasoning" recent
- "small language model" recent

**Product and adoption signals:**
- "AI product launch" recent
- "AI tool viral" recent
- "ChatGPT competitor" recent
- "AI workflow automation" recent
- "AI coding assistant" recent

**Business model signals:**
- "AI revenue model" recent
- "AI SaaS profitable" recent
- "AI pricing strategy" recent
- "AI B2B enterprise" recent

**Emerging use-case signals:**
- "AI vertical" recent (e.g. legal AI, medical AI, fintech AI)
- "AI agent use case" recent
- "autonomous AI" recent

### Research Depth Requirements

For each source category, surface at minimum:
- 3 specific company/product examples
- 1 funding data point or market size estimate
- 1 quote from a founder, investor, or analyst

---

## Analysis Phase: Pattern Recognition

After gathering raw intelligence, synthesise across all findings before drawing conclusions. Look for:

**Convergence signals** — Multiple independent sources pointing at the same thing. A trend mentioned in funding data, a product launch, AND academic research simultaneously is a strong signal.

**Speed of iteration** — How fast is the capability improving? If the state of the art improved 10× in 3 months, extrapolate where it will be in 6 months.

**Adoption curve position** — Is this in the "tinkerers" phase, "early adopters" phase, or crossing into "early majority"? Opportunities to exploit typically sit just before the early majority inflection point.

**Unmet demand signals** — What are people asking for that doesn't exist yet? Search forums, Reddit, LinkedIn comments, and product reviews for "I wish AI could..." or "why can't AI..."

**Competitor gaps** — Where are established players (OpenAI, Anthropic, Google, Microsoft) moving slowly due to size, regulation, or strategic blindspots? These gaps are where a focused player like EngineAI can win.

**Distribution moats** — Where is proprietary data, existing customer relationships, or regulatory expertise creating a durable advantage that isn't about model quality?

---

## Six-Month Prediction Model

Apply this framework to predict what will be exploitable by the target date (today + 6 months):

### Readiness Score (1–5 per opportunity)

Score each identified opportunity on:

| Dimension | 1 (Not Ready) | 5 (Ready Now) |
|---|---|---|
| **Technical maturity** | Research stage, no reliable demos | Production-grade, multiple working products |
| **Market awareness** | Nobody knows about it yet | Mainstream media coverage |
| **Customer willingness to pay** | No evidence of budget | Active RFPs, pilots being purchased |
| **Build feasibility for EngineAI** | Requires 12+ months R&D | Can ship in 4–8 weeks |
| **Competition density** | Dozens of funded competitors | 0–3 serious players |

**Opportunity sweet spot: 2–3 on Technical maturity, 2–3 on Market awareness, 3–4 on Customer willingness to pay.** Too early = no revenue. Too late = crowded.

### Time-to-Inflection Estimate

For each opportunity, predict the month it crosses the inflection point (when early majority adoption begins). Opportunities with inflection points 4–7 months out are the primary targets — enough time to build, not so far out the market shifts.

---

## EngineAI Strategy Recommendations

Translate analysis into specific, actionable guidance structured as:

### Tier 1: Move Now (build within 60 days)
Opportunities where the inflection is 4–6 months away and EngineAI has a realistic path to being first or best. List maximum 3 items. Include:
- Specific product/feature to build
- Target customer and use case
- Why EngineAI specifically is positioned to win this
- Estimated revenue potential (order of magnitude: $10k/month, $100k/month, $1M/month)
- First concrete action to take tomorrow

### Tier 2: Invest Now, Ship in 90 Days
Opportunities that need 2–3 months of R&D before they're exploitable. Assign a small team or budget now. List maximum 3 items. Include:
- What to build and why
- What needs to be true for this to unlock
- Trigger condition to accelerate (e.g. "if X model is released, pull this forward")

### Tier 3: Watch Closely
Signals that aren't ready yet but could move fast. Assign one person to monitor. List maximum 5 items. Include:
- What to watch for
- Why this matters for EngineAI
- What signal would move it to Tier 1

### Avoid (and Why)
Explicitly call out 2–3 trends that look exciting but are traps — too crowded, wrong timing, or not a fit for EngineAI. Saves the team from chasing noise.

---

## Output Format

Produce the report in this exact structure. Keep it tight — the goal is a 5-minute read that leads to a decision, not a research paper.

```markdown
# Six Month Vision — [DATE]
*AI opportunity intelligence for EngineAI*

---

## This Week's Signal

[3–4 sentence summary of the single most significant thing happening in AI right now. The lead. What's the big story?]

---

## Key Trends Detected

### [Trend 1 Name]
**What's happening:** [2–3 sentences]
**Evidence:** [Specific examples with company names, funding amounts, product names]
**6-month trajectory:** [Where this will be by the target date]
**Readiness score:** [X/5 Technical | X/5 Market | X/5 Customer | X/5 Build | X/5 Competition]

[Repeat for 3–5 trends]

---

## EngineAI Strategy

### TIER 1 — MOVE NOW

**[Opportunity Name]**
- **Build:** [Specific thing to build]
- **For:** [Target customer]
- **Why us:** [EngineAI-specific advantage]
- **Revenue potential:** [Order of magnitude]
- **First action:** [Specific next step for tomorrow]

[2–3 Tier 1 opportunities]

---

### TIER 2 — INVEST NOW, SHIP Q[X]

[2–3 opportunities with build + trigger conditions]

---

### TIER 3 — WATCH LIST

[3–5 signals with what to watch for]

---

### AVOID

[2–3 traps with explicit reasoning]

---

## Wild Card

[One speculative prediction — the thing that seems unlikely but could be massive if it happens. Assign a probability.]

---

*Generated: [TIMESTAMP] | Sources scanned: [N] | Run: /six-month-vision*
```

---

## Quality Standards

Before finalising the report:

- Every trend cited must have at least one named company, product, or data point — no vague generalities
- Every Tier 1 opportunity must have a specific "first action" — not "explore this space" but "build a landing page for X targeting Y and run $500 in ads"
- Revenue estimates must be grounded in comparable products or market sizing, not invented
- The report must be usable by someone who hasn't followed AI news at all this week
- The Avoid section must exist — a report with no "don't do this" is not credible
- Total length: 800–1200 words. Cut aggressively if over.

---

## Cron Configuration

This skill runs as a system cron job at 20:00 NZST (08:00 UTC) every night.

To install the cron job on a new machine, run:
```bash
bash ~/.claude/skills/six-month-vision/scripts/setup-cron.sh
```

Reports are saved to `~/.claude/six-month-vision/reports/YYYY-MM-DD.md` and logged to `~/.claude/six-month-vision/six-month-vision.log`.

To invoke manually:
```bash
bash ~/.claude/skills/six-month-vision/scripts/run-vision.sh
```

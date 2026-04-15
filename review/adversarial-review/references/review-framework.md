# Adversarial Review Framework - Detailed Reference

## Doc Type Detection Heuristics

### PRD Indicators
- Contains "functional requirements", "non-functional requirements", "user journeys"
- Has scope/MVP sections
- References success criteria or acceptance criteria
- BMAD frontmatter with `workflowType: 'prd'`

### Architecture Doc Indicators
- Contains "system design", "data flow", "component diagram"
- References specific infrastructure (databases, queues, caches)
- Has ADR (Architecture Decision Record) sections
- Discusses trade-offs between approaches

### SOW Indicators
- Contains "deliverables", "milestones", "payment schedule"
- References "in scope" / "out of scope"
- Has RACI or responsibility assignments
- Includes pricing or rate cards

### Technical Spec Indicators
- Contains API contracts, schema definitions, endpoint specs
- References specific libraries, versions, configurations
- Has sequence diagrams or state machines
- Discusses error codes and response formats

### GTM/Strategy Doc Indicators
- Contains "market analysis", "competitive landscape", "go-to-market"
- References TAM/SAM/SOM or market sizing
- Has pricing strategy or positioning sections
- Discusses customer segments or personas

### AI Feature Spec Indicators
- References models, prompts, agents, or LLMs
- Contains "evaluation", "guardrails", "hallucination"
- Discusses confidence thresholds or human-in-the-loop
- Has token/cost estimates

---

## AI Model Detection Patterns

### Gemini Indicators
- Heavy use of branded metaphors ("nervous system", "cockpit", "assembly line")
- Extremely symmetrical document structure
- Marketing copy mixed with technical requirements
- Specific number targets without measurement methodology (92%, 100%, 24h)
- References to Google ecosystem products without alternatives analysis
- "What Makes This Special" type framing sections

### GPT/ChatGPT Indicators
- "Certainly", "Absolutely" phrasing patterns
- Overuse of "leverage", "streamline", "robust"
- Bullet-heavy structure with consistent 2-3 sub-points per item
- Generic conclusions ("The future is bright")
- Hedging language ("It's worth noting", "It should be mentioned")

### Claude Indicators
- "I think", "I'd suggest" phrasing (if not stripped)
- Nuanced trade-off analysis that avoids strong recommendations
- Excessive caveating and acknowledgment of limitations
- Clean markdown formatting with consistent heading hierarchy
- Tends toward longer, more structured output

### General AI Document Tells
- No unknowns or assumptions section
- Every question has an answer (real docs have gaps)
- Passive voice on implementation details
- Referenced artifacts that don't exist
- Buzzword count > 5 unique marketing metaphors
- Perfect parallelism in all lists

---

## Architecture Review - Deep Checklist

### Technology Fitness
- [ ] Is each technology used for its intended purpose?
- [ ] Are separate products/services conflated as one?
- [ ] Has an alternatives evaluation been documented?
- [ ] Are version-specific features cited accurately?
- [ ] Do the chosen tools actually support the stated requirements?

### Common Conflation Patterns
- Vercel AI SDK vs Vercel Workflows (streaming/tools vs durable execution)
- MCP vs direct API integration (tool exposure vs full integration)
- LangChain vs LangGraph (chains vs stateful graphs)
- Supabase Auth vs custom RBAC (auth provider vs permission system)
- "Serverless" vs "Durable" (these have different constraints)

### Decision Record Requirements
Each technology choice should have:
1. Context - what problem is being solved
2. Options considered - at least 2-3 alternatives
3. Decision - what was chosen
4. Rationale - why this over alternatives
5. Consequences - trade-offs accepted
6. Status - proposed/accepted/deprecated

---

## Metrics Review - Deep Checklist

### Metric Validation
For each stated metric, check:
- [ ] Is there a baseline (current state)?
- [ ] Is the target specific and bounded?
- [ ] Is the measurement method defined?
- [ ] Is the measurement automated or manual?
- [ ] Is the evaluator independent of the system being evaluated?
- [ ] Is the sampling methodology defined?
- [ ] Is the target realistic (not 0% or 100%)?
- [ ] Is there a timeline for achieving the target?

### Common Fantasy Metrics
- "100% completion rate" (nothing completes 100%)
- "0% error rate" or "0% manual intervention" (not achievable)
- "Real-time" without defining latency bounds
- Accuracy percentages without defining what "accurate" means
- Time targets without defining scope (24h to build... what exactly?)
- "Zero downtime" without defining maintenance windows

---

## Scope Review - Deep Checklist

### MVP Minimality Test
Ask for each MVP feature:
1. Can the product launch without this? If yes, it's not MVP.
2. Can this be manually handled for the first N users? If yes, defer it.
3. Does this feature depend on other features not yet built? If yes, sequence matters.
4. Is this a platform feature or a product feature? Platform features are rarely MVP.

### Phase Boundary Checks
- [ ] Every requirement has a phase label
- [ ] No post-MVP requirements are referenced in MVP success criteria
- [ ] Phase 2 features don't have NFRs that assume they exist in Phase 1
- [ ] Dependencies between phases are explicit

---

## Edge Case Review - Deep Checklist

### Failure Modes
- [ ] What happens when the primary LLM provider is down?
- [ ] What happens when a third-party API rate limits the system?
- [ ] What happens when a long-running process exceeds token budget?
- [ ] What happens when two processes contend for the same resource?
- [ ] What happens when a deployed change needs rollback?
- [ ] What happens when an agent produces incorrect output?
- [ ] What happens when a human doesn't respond to an approval gate?

### Cost and Resource
- [ ] Is there a cost model per operation/workflow/tenant?
- [ ] Are there budget caps or circuit breakers?
- [ ] Is token usage estimated for typical and worst-case scenarios?
- [ ] Are infrastructure costs projected for 1x, 10x, 50x scale?

### Security and Trust
- [ ] Are trust boundaries between agents defined?
- [ ] Can an agent escalate its own permissions?
- [ ] Is there audit logging for all agent actions?
- [ ] Are secrets/credentials scoped per agent?
- [ ] Is multi-tenant data isolation enforced at the infrastructure level?

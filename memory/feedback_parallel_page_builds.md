---
name: Parallel sub-agent workflow for multi-page builds
description: When building/refining multiple Next.js pages, use parallel sub-agents per page with consistency review after
type: feedback
---

When asked to build or refine multiple pages for a Next.js site, use this parallel workflow:

1. Read DESIGN.md and the shared component library to understand the design system
2. Create a sub-agent for EACH page (list provided by user)
3. Each sub-agent should: implement the page, ensure it follows the design system, fix any TypeScript errors, and verify it renders by checking for build errors
4. After all agents complete, do a consistency review across all pages: check spacing, typography, colour usage, and responsive behaviour are uniform
5. Run `npm run build` to catch any cross-page issues
6. Commit each page as a separate commit with descriptive messages

Design constraints come from DESIGN.md or user description. Work autonomously. Only ask if hitting a blocker that requires a subjective design decision.

**Why:** Multi-page website builds (QCC, Engine AI) were spanning multiple sessions with serial page-by-page iteration and recurring CSS/layout friction. Parallel sub-agents compress what was a multi-session build into a single focused session.

**How to apply:** Trigger this workflow when the user asks to build, rebuild, or refine 2+ pages at once. Combine with the UI design process guardrail (read DESIGN.md first, plan before implementing). Each sub-agent gets the same design constraints to ensure consistency.

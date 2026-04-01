---
name: UI design process guardrails
description: Before any UI changes, read DESIGN.md, follow design constraints, and show plan before implementing
type: feedback
---

Before making any UI changes, read DESIGN.md for constraints first. Design rules: Inter font only, colour palette from tailwind.config, mobile-first responsive, no animations unless specified. Show the plan before implementing.

**Why:** Design iteration sessions were burning 3+ rounds because Claude would implement before aligning on constraints. Providing a plan first and following DESIGN.md prevents wasted cycles on rejected font/layout/spacing choices.

**How to apply:** On any UI task, read DESIGN.md and tailwind.config before writing code. Present the approach (layout, components, spacing, typography) for approval before touching files. This applies to all projects with a DESIGN.md.

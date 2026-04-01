---
name: Always check Vercel env vars when API routes fail
description: Vercel env vars are a common root cause when API routes return 500 — check them early in debugging
type: feedback
---

When a Vercel-hosted API route returns 500, check environment variables first with `vercel env ls`.

**Why:** The Engine AI contact form was broken in production because `RESEND_API_KEY` was never added to the Vercel project. The code was correct, the build succeeded, but the runtime blew up on the missing key. Tom tested the form and hit "Failed to send message" for what turned out to be a 30-second fix.

**How to apply:** When debugging Vercel API route failures, run `vercel env ls` before digging into code. Also check env vars after deploying any new project or reconnecting a repo.

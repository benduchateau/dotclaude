---
name: Engine AI live website repo
description: The live engineai.co.nz site deploys from benduchateau/engineai_website (personal repo), NOT engineai-nz/EngineAI-Home (org repo)
type: reference
---

The live Engine AI website at engineai.co.nz is deployed from two separate repos:

- **Live site:** `github.com/benduchateau/engineai_website` — standalone Next.js app, deployed via Vercel project `engineai-website`. This is the one visitors see.
- **Monorepo (future):** `github.com/engineai-nz/EngineAI-Home` — pnpm monorepo with apps/web, apps/admin, agents, Paperclip. Not currently serving the live domain.

Local path: `~/projects/engineai_website/`
Monorepo local path: `~/projects/archive/engineai_monorepo/` (dormant)

Vercel project name: `engineai-website`
Domain: engineai.co.nz, www.engineai.co.nz

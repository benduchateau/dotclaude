---
name: CDP Bridge Setup
description: How to bridge gstack browse from WSL2 to Windows Chrome via CDP. Three-hop architecture, Bun/Playwright incompatibility workaround.
type: reference
---

## WSL2 -> Windows Chrome CDP Bridge

**Architecture:**
Chrome (Win 127.0.0.1:9222) -> Node relay (Win 0.0.0.0:9223) -> Node proxy (WSL 127.0.0.1:9222)

**Why three hops:**
1. Chrome only binds to 127.0.0.1 (ignores --remote-debugging-address)
2. WSL2 NAT can't reach Windows localhost; needs a Windows-side relay on 0.0.0.0
3. WSL-side proxy so browse sees localhost:9222

**Key files:**
- `~/bin/chrome-cdp.sh` - orchestrates all three components
- `~/bin/cdp-proxy.js` - WSL-side TCP proxy (localhost:9222 -> WIN_IP:9223)
- `C:\Users\bendu\cdp-relay.js` - Windows-side TCP relay (0.0.0.0:9223 -> 127.0.0.1:9222)

**Critical discovery: Bun + Playwright connectOverCDP is broken.**
Playwright's `connectOverCDP()` hangs indefinitely under Bun (even locally, no proxy).
Works fine under Node.js. Patched gstack's `browser-manager.ts` to add CDP mode and
`cli.ts` to use `server-node.mjs` (Node) instead of Bun when `BROWSE_CDP_URL` is set.

**Usage:**
```bash
# Start the bridge
~/bin/chrome-cdp.sh start

# Use browse with CDP
BROWSE_CDP_URL=http://localhost:9222 $B goto https://example.com
```

**Prereqs on Windows:**
- Firewall rule: "WSL2 Chrome CDP" allowing inbound TCP on port 9223
- Node.js installed (C:\Program Files\nodejs\node.exe)
- Chrome uses a temp profile (`chrome-cdp-profile`) to avoid flag-ignoring when existing session is running

**Note:** Chrome launched with temp profile won't have login sessions.
To use real logins, close all Chrome windows first, then launch with your real profile.

---
name: openclaw-server-reference
description: OpenClaw server (pillarofautumn) connection details, gateway config, and Tailscale Serve setup for remote dashboard access
type: reference
---

## OpenClaw Server — pillarofautumn

- **Host:** `duchats@192.168.1.20`
- **Tailscale IP:** `100.99.47.22`
- **Tailscale hostname:** `pillarofautumn.tailb4fcd8.ts.net`
- **OS:** Ubuntu 24.04 LTS
- **OpenClaw version:** 2026.2.26

### Gateway Access
- **Dashboard URL (from Atlas):** `https://pillarofautumn.tailb4fcd8.ts.net`
- **Gateway binds to:** `127.0.0.1:18789` (loopback)
- **Tailscale Serve** proxies HTTPS :443 → `http://127.0.0.1:18789`
- **Auth:** token mode with `allowTailscale: true`, `dangerouslyDisableDeviceAuth: true`
- **Gateway token:** stored in `~/.openclaw/openclaw.json` under `gateway.auth.token`

### Systemd Service
- **Service:** `systemctl --user [start|stop|status] openclaw-gateway.service`
- **Enabled on boot:** yes
- **Linger enabled:** yes (survives logout)
- **Entrypoint:** `/usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789`

### Tailscale Network
- pillarofautumn (this box): `100.99.47.22`
- atlas (Windows): `100.78.163.127`
- unraid: `100.122.144.104`
- vmi3073362: `100.89.115.28`
- openclaw-vps: `100.97.111.114` (offline as of 2026-03-13)
- iphone-15-pro: `100.118.187.107` (offline as of 2026-03-13)

### Known Issues (resolved 2026-03-13)
- Gateway config gets overwritten on restart — use `openclaw config set` CLI, not direct file edits
- `dangerouslyDisableDeviceAuth` must be `true` for remote Control UI access via Tailscale Serve
- Tailscale Serve requires `bind: loopback` (not `tailnet`) since it proxies locally

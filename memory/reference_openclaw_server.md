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
- **OpenClaw version:** 2026.2.26 (gateway service reinstalled 2026-03-24 after CLI upgrade caused version drift)

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

### Known Issues
- Gateway config gets overwritten on restart — use `openclaw config set` CLI, not direct file edits (2026-03-13)
- `dangerouslyDisableDeviceAuth` must be `true` for remote Control UI access via Tailscale Serve (2026-03-13)
- Tailscale Serve requires `bind: loopback` (not `tailnet`) since it proxies locally (2026-03-13)
- After CLI upgrades, the systemd service can still point at the old binary. Reinstall with `openclaw gateway install` then strip non-essential env vars from the unit file (2026-03-24)
- Stale plugin entries (`acpx`, `memory-lancedb`, `whatsapp`) in config cause warnings. Remove unused `plugins.entries` keys and verify with `openclaw status` (2026-03-24)
- Plugin SDK resolution: local plugins importing `openclaw/plugin-sdk/*` need a symlink from plugin `node_modules/openclaw` to the installed package (2026-03-24)

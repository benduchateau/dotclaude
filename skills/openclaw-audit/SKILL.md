---
name: openclaw-audit
description: Audit the OpenClaw VM environment (duchats@192.168.1.20) against security, health, update, Docker, and application standards. Use when the user asks to check, audit, or scan the openclaw server, or mentions checking their server environment.
---

# OpenClaw Environment Audit

## Overview

This skill audits the OpenClaw AI assistant VM at `duchats@192.168.1.20` against standard server hardening, system health, and application configuration benchmarks. It runs checks via SSH and reports PASS/WARN/FAIL results with actionable remediation guidance.

## Target

- **Host:** `duchats@192.168.1.20`
- **Application:** [OpenClaw](https://openclaw.ai/) — open-source personal AI assistant (Node.js)
- **Environment:** VM (Linux)

## Running the Audit

### Full audit (all sections)

```bash
ssh duchats@192.168.1.20 'bash -s' < ~/.claude/skills/openclaw-audit/scripts/audit.sh
```

### Single section

```bash
ssh duchats@192.168.1.20 'bash -s' < ~/.claude/skills/openclaw-audit/scripts/audit.sh -- --section security
```

Valid sections: `security`, `health`, `updates`, `docker`, `openclaw`

### Workflow

1. Run the audit script over SSH against the target host
2. Capture and display the full output to the user
3. Summarize findings: count of PASS, WARN, FAIL
4. For any FAIL or WARN items, provide specific remediation steps
5. If the user asks to fix issues, SSH in and apply the remediation (with confirmation before destructive changes)

## Audit Sections

### Security
- SSH hardening (root login, password auth, port)
- Firewall status (UFW / firewalld)
- Open ports listing
- Fail2ban status
- Sensitive file permissions (/etc/shadow, /etc/gshadow)
- Authorized keys review
- Privileged user enumeration

### System Health
- OS and kernel info
- CPU load vs core count
- Memory and swap usage
- Disk usage per mount
- Zombie processes
- OOM kill detection

### Updates & Patches
- Pending package upgrades and security updates
- Unattended upgrades status
- Reboot-required flag
- Node.js version (LTS check)
- npm audit in OpenClaw directories

### Docker
- Daemon status
- Container health (unhealthy, restarting, exited)
- Disk usage and dangling images

### OpenClaw Application
- Process and systemd service detection
- Config file permissions (.env, config.json)
- API key exposure check
- Recent log errors
- SSL/TLS certificate expiry

## Interpreting Results

- **PASS** — meets the standard, no action needed
- **WARN** — not critical but should be reviewed; may indicate drift or upcoming issues
- **FAIL** — does not meet the standard; remediation recommended

For detailed rationale behind each check and threshold, read `references/standards.md`.

## Remediation

When the user asks to fix findings, prioritize:

1. **FAIL items first** — these represent active risk
2. **Security before health** — compromised security can cascade
3. **Confirm before applying** — especially for firewall rules, SSH config changes, and service restarts

Common fixes:
- SSH hardening: edit `/etc/ssh/sshd_config`, then `sudo systemctl restart sshd`
- Enable firewall: `sudo ufw enable` (ensure SSH rule exists first)
- Install fail2ban: `sudo apt install fail2ban && sudo systemctl enable fail2ban`
- Fix file permissions: `sudo chmod 600 <file>`
- Pending updates: `sudo apt update && sudo apt upgrade`
- Docker cleanup: `docker system prune`

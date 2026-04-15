# OpenClaw Audit Standards Reference

This document describes the standards checked by the `audit.sh` script and the rationale behind each check.

---

## Security Standards

### SSH Hardening
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Root login disabled | `PermitRootLogin no` | FAIL | Direct root SSH is the #1 brute-force target |
| Password auth disabled | `PasswordAuthentication no` | WARN | Key-only auth prevents credential stuffing |
| Non-default port | Port != 22 | WARN | Reduces automated scan noise (not a security fix, but defense-in-depth) |

### Firewall
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| UFW or firewalld active | Active state | FAIL | No firewall = all ports exposed to LAN/WAN |

### Fail2ban
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Fail2ban running | Active with jails | WARN | Protects against brute-force; not critical if key-only SSH |

### File Permissions
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| /etc/shadow | 640 or 600 | FAIL | Readable shadow = password hashes exposed |
| /etc/gshadow | 640 or 600 | FAIL | Same as shadow |
| authorized_keys | 600 or 644 | WARN | Overly permissive = other users can inject keys |

### Privileged Users
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| sudo group members listed | Informational | INFO | Awareness of who has root-level access |

---

## System Health Standards

### CPU
| Threshold | Severity | Rationale |
|-----------|----------|-----------|
| >90% load/core | FAIL | System is overloaded, processes may hang |
| >70% load/core | WARN | Approaching capacity |

### Memory
| Threshold | Severity | Rationale |
|-----------|----------|-----------|
| >90% used | FAIL | OOM killer risk |
| >75% used | WARN | Limited headroom |

### Swap
| Threshold | Severity | Rationale |
|-----------|----------|-----------|
| >50% used | WARN | Heavy swap = performance degradation |
| No swap configured | WARN | No safety net for memory pressure |

### Disk
| Threshold | Severity | Rationale |
|-----------|----------|-----------|
| >90% full | FAIL | Writes may fail, logs may stop |
| >75% full | WARN | Plan for cleanup or expansion |

### Processes
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Zombie processes | 0 | WARN | Zombies indicate broken parent processes |
| OOM kills in dmesg | None | WARN | Indicates memory pressure events |

---

## Update Standards

### Packages
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Upgradable packages | 0 | WARN | Outdated packages may have known vulnerabilities |
| Security updates pending | 0 | FAIL | Security patches should be applied promptly |
| Unattended upgrades installed | Yes | WARN | Automatic security patching is best practice |
| Reboot required | No | WARN | Kernel updates need reboot to take effect |

### Node.js
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Version >= 20 LTS | Current LTS | PASS | OpenClaw requires modern Node.js |
| Version 18-19 | Aging LTS | WARN | Still supported but upgrade recommended |
| Version < 18 | EOL | FAIL | No longer receives security patches |

---

## Docker Standards

| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Daemon running | Active | PASS | Required if containers are in use |
| Unhealthy containers | 0 | FAIL | Container health checks failing |
| Restarting containers | 0 | FAIL | Crash loop indicates misconfiguration |
| Dangling images > 5 | Prune | WARN | Wasted disk space |

---

## OpenClaw-Specific Standards

### Process & Service
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Process running | Detected | WARN | OpenClaw should be active if in use |
| Systemd service active | Active | PASS | Proper service management |

### Configuration Security
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| .env file permissions | 600 or 640 | FAIL | API keys must not be world-readable |
| config.json permissions | 600 or 640 | FAIL | Same — contains sensitive credentials |

### Logs
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Errors in last 100 lines | < 10 | WARN/FAIL | Indicates operational issues |

### SSL/TLS
| Check | Expected | Severity | Rationale |
|-------|----------|----------|-----------|
| Certificate expires > 30 days | Valid | PASS | No action needed |
| Certificate expires 7-30 days | Renew soon | WARN | Schedule renewal |
| Certificate expires < 7 days | Critical | FAIL | Immediate renewal required |

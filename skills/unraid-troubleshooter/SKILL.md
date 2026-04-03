---
name: unraid-troubleshooter
description: >
  Comprehensive Unraid server troubleshooting and diagnostics skill. Use this skill
  whenever the user mentions their Unraid server, homelab, NAS, array, parity, Docker
  containers on Unraid, Unraid VMs, plugins, Community Apps, or asks anything like:
  "my Unraid server is doing X", "help me fix my array", "container keeps crashing",
  "parity check failed", "drive showing errors", "VM won't start", "check my server
  health", "something's wrong with my NAS", or "help me SSH into my Unraid box".
  Also trigger for general homelab troubleshooting where Unraid is the likely OS.
  This skill adapts between running commands directly (when SSH/terminal access is
  available) and guiding the user through steps manually — always ask or infer which
  mode applies.
---

# Unraid Troubleshooter

You are an expert Unraid sysadmin helping troubleshoot and manage an Unraid server.
Unraid is a Slackware-based Linux NAS/homelab OS. The user has a mix of Docker
containers, VMs, and a parity-protected disk array.

## How to work

### Determine access mode first

Before diving in, figure out how you're operating:

- **Direct mode** — You have SSH/terminal access and can run commands yourself.
  Diagnose proactively: run the relevant commands, interpret the output, and explain
  what you found. Don't just list commands and wait.
- **Guided mode** — No direct access. Give the user specific commands to run and
  tell them exactly what to look for in the output. Be explicit about what a "good"
  vs "bad" result looks like.
- **Web UI only** — Some tasks (like Docker reinstall or SMART reports) can be done
  entirely via the Unraid WebGUI. Point the user to the right menu path.

If it's ambiguous, ask once: "Do you have SSH/terminal access open, or would you
prefer I walk you through the WebGUI?"

### General approach

1. **Gather before guessing** — Always start with the right diagnostic command for
   the area (see sections below). Don't speculate about root cause until you have
   data.
2. **Triage by area** — Docker, disks/array, VMs, plugins, and general system health
   each have distinct failure patterns. Identify which area first.
3. **Check logs early** — The syslog is the most valuable single source. For
   persistent issues, recommend enabling persistent logging before the next event.
4. **Capture diagnostics before rebooting** — If a reboot is needed, always generate
   the diagnostics package first (Tools > Diagnostics or run `diagnostics` in CLI).
   Syslog is RAM-based and lost on reboot.

---

## Core Locations & Files

| Purpose | Path |
|---|---|
| System log (live) | `/var/log/syslog` |
| Persisted syslog | `/boot/logs/syslog` |
| Previous session log | `/boot/logs/syslog-previous` |
| Diagnostics output | `/boot/logs/` (after running `diagnostics`) |
| Array mounts | `/mnt/disk1/`, `/mnt/disk2/`, etc. |
| User shares | `/mnt/user/` |
| appdata (Docker volumes) | `/mnt/user/appdata/` (typical) |
| VM logs | `/var/log/libvirt/` |
| Boot/config | `/boot/` (USB boot drive) |

---

## Docker Troubleshooting

### Diagnose a container issue

```bash
# View live logs
docker logs <container_name>

# Follow logs in real time
docker logs -f <container_name>

# Check all container states
docker ps -a

# Inspect a container's full config
docker inspect <container_name>

# Check docker.img usage (cache space)
df -h /var/lib/docker
```

### Common Docker failure patterns

**Container crashes on start / exits immediately**
- Run `docker logs <name>` — error is almost always visible there
- Check mapped host paths exist: `ls -la /path/to/mapped/volume`
- Permission issues: container user may not own the appdata path
- Port conflict: `ss -tuln | grep <port>`

**Docker won't start at all / docker.img corrupted**
- Usually caused by cache full or unclean shutdown
- Recovery:
  1. Settings > Docker > Enable Docker = No
  2. Delete `docker.img` (option in Docker settings)
  3. Set desired image size, re-enable Docker
  4. Restore containers: Apps > Previous Apps > reinstall
  5. Restore custom networks: `docker network ls` → `docker network create <name>`
- Note: `appdata` share survives — container data is safe

**Cache drive full**
- `df -h` to check usage
- Mover may not have run: check Settings > Scheduler > Mover
- Run mover manually from Main tab or `mover start`

**Useful extras**
```bash
# Remove stopped containers (safe cleanup)
docker container prune

# See resource usage per container
docker stats --no-stream
```

---

## Disk & Array Troubleshooting

### SMART health check

```bash
# Full SMART report
smartctl -a /dev/sdX

# If device type error, try:
smartctl -a -d ata /dev/sdX
smartctl -a -d nvme /dev/sdX

# Run short self-test (takes ~2 min)
smartctl -t short /dev/sdX

# Run long self-test (can take hours)
smartctl -t long /dev/sdX

# List drives by serial number
ls -l /dev/disk/by-id/ | grep -v part
```

### Critical SMART attributes to watch

| Attr ID | Name | What it means |
|---|---|---|
| 5 | Reallocated Sectors | >0 = drive remapping bad sectors. Growing = replace soon |
| 187 | Uncorrected Errors | Any value >0 = critical. Replace immediately |
| 197 | Current Pending Sectors | Unstable sectors waiting to be reallocated |
| 198 | Uncorrectable Sectors | Data loss has occurred. Replace now |
| 199 | UDMA CRC Errors | Usually a bad cable, not the drive. Reseat SATA cables |
| 188 | Command Timeout | Frequent = check cables/power connector |

**Rule of thumb:** Attributes 5, 187, 197, 198 at zero = healthy. Growing values on
any of these = action required.

### Array and parity

```bash
# Check current array/parity status
cat /proc/mdstat

# View disk error counts (look for read/write errors)
cat /sys/block/mdX/md/rd*/errors 2>/dev/null

# Real-time syslog for array events
tail -f /var/log/syslog | grep -i -E 'md|ata|error|fail'

# Disk speed benchmark (to spot a slow/degraded drive)
hdparm -tT /dev/sdX
```

**Parity check triggered on boot** = unclean shutdown. Normal. Let it complete.
Monitor syslog for errors during the check. Repeated parity errors on the same
drive = suspect that drive.

**Drive showing as disabled** = Unraid took it offline due to errors. Don't stop
the array until you know which drive and have confirmed SMART. Stopping with a
disabled drive may require a rebuild.

### Replacing a drive

1. Stop the array
2. Power off, swap drive
3. Start array → Unraid will prompt to assign new drive
4. Assign and start rebuild
5. Run `smartctl -a /dev/sdX` on new drive during rebuild to confirm health

---

## VM Troubleshooting

### Diagnose a VM issue

```bash
# Check VM logs (replace vmname with actual name)
cat /var/log/libvirt/qemu/<vmname>.log

# List all VMs and their state
virsh list --all

# Start a VM from CLI
virsh start <vmname>

# Forcefully kill a stuck VM
virsh destroy <vmname>

# Check VFIO/GPU passthrough binding
lspci -k | grep -A 3 -i vga
dmesg | grep -i vfio
```

### Common VM failure patterns

**VM won't start**
- Check `/var/log/libvirt/qemu/<vmname>.log` for the error — it's usually specific
- GPU passthrough: verify device is bound to `vfio-pci` not its native driver
- Storage: verify vdisk path exists (`ls -la /mnt/user/domains/`)
- CPU pinning: if cores are pinned, ensure they're valid for your CPU topology

**GPU passthrough issues (AMD especially)**
- AMD GPUs may fail to reset after VM shutdown → VM won't start again
- Workaround: eject GPU from within Windows before shutting down the VM
- Check: `dmesg | grep -i 'reset\|vfio\|amd'`

**VM stuck / unresponsive**
- `virsh destroy <vmname>` to force off
- Check system memory: `free -h`
- Check CPU: `top` — look for qemu process pegging CPU

---

## General System Health

### Quick health overview

```bash
# Overall resource snapshot
top -b -n 1 | head -20

# Memory
free -h

# All disk usage
df -h

# Network interfaces
ip addr show

# Listening services / open ports
ss -tuln

# Recent errors in syslog
tail -100 /var/log/syslog | grep -i -E 'error|warn|fail|critical'

# CPU info + virtualisation support
lscpu
grep -E 'vmx|svm' /proc/cpuinfo | head -1
```

### Network issues

```bash
# Test internet connectivity
ping -c 4 8.8.8.8

# Test DNS resolution
ping -c 4 google.com

# NIC details
ethtool eth0
ethtool -S eth0

# Check routing
ip route show
```

### Plugins & Community Apps

- Plugin issues are usually visible in syslog: `tail -f /var/log/syslog`
- Plugin update failures: try disabling and reinstalling via Apps tab
- Check for conflicts: two plugins that modify the same service can clash
- After any plugin install that modifies networking or Docker, check `docker ps -a`

---

## Persistent Logging (Highly Recommended)

By default syslog is RAM-based and lost on reboot. To keep logs across reboots:

- **Short-term (temporary):** Settings > Syslog Server > Mirror syslog to boot drive
  (writes to `/boot/logs/syslog` — avoid long-term to protect USB wear)
- **Better:** Settings > Syslog Server > Local syslog folder → point to a share on
  the array (e.g., a `logs` share)
- **Best for remote access:** Configure a remote syslog server

Enable this before you reboot to preserve evidence of a crash.

---

## Capturing the Diagnostics Package

Always do this before rebooting when something is wrong.

```bash
# Via CLI
diagnostics
# Output: /boot/logs/<hostname>-diagnostics-<date>.zip
```

Or via WebGUI: Tools > Diagnostics > Generate

Contains: array config, hardware info, logs, plugin list, Docker/VM config.
Does NOT contain: individual container data, VM disk contents.

---

## Quick Reference: Triage by Symptom

| Symptom | Start here |
|---|---|
| Container won't start | `docker logs <name>` |
| Array disk showing errors | `smartctl -a /dev/sdX` |
| Parity check taking forever | `hdparm -tT /dev/sdX` on each drive |
| System running slow | `top`, `free -h`, `df -h` |
| VM won't start | `/var/log/libvirt/qemu/<name>.log` |
| No network access | `ip addr show`, `ping 8.8.8.8` |
| Server crashed / rebooted | `/boot/logs/syslog-previous` |
| Random instability | `tail -200 /var/log/syslog \| grep -i error` |
| Cache full | `df -h`, run Mover |
| Plugin broken | Syslog + disable/reinstall |

---

## Tips for this user (Ben)

- You're comfortable in the CLI, so lean into direct SSH commands rather than
  walking through WebGUI menus unless that's faster for the specific task
- When in doubt, `tail -f /var/log/syslog` open in one terminal while reproducing
  an issue in another is your best friend
- For anything that requires a reboot, always generate diagnostics first

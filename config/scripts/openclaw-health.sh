#!/usr/bin/env bash
# Quick OpenClaw health ping
# Checks gateway process and port on the configured host via SSH.
# Set OPENCLAW_HOST (e.g. "user@10.0.0.2") to enable. Skipped silently otherwise.

HOST="${OPENCLAW_HOST:-}"
if [ -z "$HOST" ]; then
    exit 0
fi

TIMEOUT=5
issues=0

# Check SSH reachability
if ! ssh -o ConnectTimeout=$TIMEOUT -o BatchMode=yes "$HOST" "true" 2>/dev/null; then
    echo "⚠ OpenClaw: pillarofautumn unreachable via SSH"
    exit 0
fi

# Check gateway process
if ssh -o ConnectTimeout=$TIMEOUT -o BatchMode=yes "$HOST" "pgrep -f 'openclaw.*gateway' >/dev/null 2>&1" 2>/dev/null; then
    echo "✓ OpenClaw gateway process running"
else
    echo "⚠ OpenClaw: gateway process not running"
    issues=$((issues + 1))
fi

# Check port 18789 is listening
if ssh -o ConnectTimeout=$TIMEOUT -o BatchMode=yes "$HOST" "ss -tlnp 2>/dev/null | grep -q 18789" 2>/dev/null; then
    echo "✓ OpenClaw gateway port 18789 listening"
else
    echo "⚠ OpenClaw: port 18789 not listening"
    issues=$((issues + 1))
fi

# Quick disk check
disk_pct=$(ssh -o ConnectTimeout=$TIMEOUT -o BatchMode=yes "$HOST" "df / --output=pcent 2>/dev/null | tail -1 | tr -d ' %'" 2>/dev/null)
if [ -n "$disk_pct" ] && [ "$disk_pct" -gt 85 ] 2>/dev/null; then
    echo "⚠ OpenClaw: disk usage at ${disk_pct}%"
    issues=$((issues + 1))
elif [ -n "$disk_pct" ]; then
    echo "✓ OpenClaw disk: ${disk_pct}% used"
fi

if [ "$issues" -eq 0 ]; then
    echo "✓ OpenClaw healthy"
fi

exit 0

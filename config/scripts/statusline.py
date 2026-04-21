#!/usr/bin/env python3
"""Engine AI Status Line for Claude Code.

Reads JSON from stdin, outputs a branded status bar with:
- Model name, context %, duration, project name, git branch, effort level, date/time
- Rate limit progress bars (line 2+)

Colours: Engine AI gold for branding, traffic light (green/yellow/red) for metrics.
"""

import json
import os
import subprocess
import sys
from datetime import datetime

# ── Colours ──────────────────────────────────────
GOLD = "\033[38;2;196;163;90m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
DIM = "\033[2m"
RESET = "\033[0m"
SEP = f"{DIM}{GOLD} \u2502 {RESET}"

# ── Project name mapping ────────────────────────
PROJECT_MAP = {
    "engineai_website": "Engine AI",
    "engineai_website_copy": "Engine AI",
    "copilotagent": "Stellar",
    "Openclaw": "OpenClaw",
    "QCC_website": "QCC",
    "QCC_website_alpha": "QCC",
    "NH-Rugby-Intel-Platform": "NH Rugby",
    "Engineai_CRM": "Engine AI CRM",
    "EngineAI_CRM": "Engine AI CRM",
    "piefunds": "Pie Funds",
    "Project_RFP": "2degrees RFP",
    "duchats": "~",
}


def traffic_light(pct: int) -> str:
    if pct < 50:
        return GREEN
    elif pct < 80:
        return YELLOW
    return RED


def format_duration(ms: int) -> str:
    total_secs = ms // 1000
    mins = total_secs // 60
    secs = total_secs % 60
    return f"{mins}m{secs}s" if mins > 0 else f"{secs}s"


def progress_bar(pct: int) -> str:
    filled = min(max(pct // 10, 0), 10)
    empty = 10 - filled
    clr = traffic_light(pct)
    return f"{clr}{'▓' * filled}{'░' * empty}{RESET}"


def git_info() -> str:
    try:
        branch = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True, text=True, timeout=2
        ).stdout.strip()
        if not branch:
            return ""
        dirty = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, timeout=2
        ).stdout.strip()
        return f"{branch}{RED}*{RESET}" if dirty else branch
    except Exception:
        return ""


def read_effort() -> str:
    try:
        settings_path = os.path.expanduser("~/.claude/settings.json")
        with open(settings_path) as f:
            return json.load(f).get("effortLevel", "high")
    except Exception:
        return "high"


def format_reset(resets_at: int) -> str:
    if not resets_at:
        return ""
    now = int(datetime.now().timestamp())
    diff = resets_at - now
    if diff < 0:
        return ""
    if diff < 86400:
        return datetime.fromtimestamp(resets_at).strftime("%H:%M")
    if diff < 604800:
        return datetime.fromtimestamp(resets_at).strftime("%a")
    days = diff // 86400
    hours = (diff % 86400) // 3600
    return f"{days}d{hours}h"


def main():
    try:
        data = json.loads(sys.stdin.read())
    except Exception:
        data = {}

    # ── Parse fields ─────────────────────────────
    model = data.get("model", {}).get("display_name", "unknown")
    ctx_pct = int(data.get("context_window", {}).get("used_percentage", 0))
    duration_ms = int(data.get("cost", {}).get("total_duration_ms", 0))
    current_dir = data.get("workspace", {}).get("current_dir", "")
    dir_name = os.path.basename(current_dir) if current_dir else ""

    project = PROJECT_MAP.get(dir_name, dir_name)
    effort = read_effort()
    branch = git_info()
    now = datetime.now().strftime("%H:%M  %a %d %b")

    # ── Shell identity (from PS1: \u@\h:\w) ─────
    try:
        user = subprocess.run(["whoami"], capture_output=True, text=True, timeout=2).stdout.strip()
    except Exception:
        user = os.environ.get("USER", "")
    try:
        host = subprocess.run(["hostname", "-s"], capture_output=True, text=True, timeout=2).stdout.strip()
    except Exception:
        host = ""
    shell_id = f"{GREEN}{user}@{host}{RESET}:{GREEN}{current_dir or '~'}{RESET}"

    # ── Build main line ──────────────────────────
    parts = [
        f"{GOLD}\u25b8{RESET} {model}",
        f"{traffic_light(ctx_pct)}{ctx_pct}%{RESET}",
        f"\u23f1\ufe0f {format_duration(duration_ms)}",
        shell_id,
        f"{GOLD}{project}{RESET}",
    ]

    if branch:
        parts.append(branch)

    parts.append(f"\u26a1{effort}")
    parts.append(f"{DIM}{now}{RESET}")

    print(SEP.join(parts))

    # ── Rate limit bars ──────────────────────────
    rate_limits = data.get("rate_limits", {})
    labels = [
        ("\u23f1\ufe0f 5h ", "five_hour"),
        ("\U0001f4c5 7d ", "seven_day"),
        ("\U0001f4dc S  ", "seven_day_sonnet"),
        ("\U0001f4b0 Ext", "extra_usage"),
    ]

    for label, key in labels:
        rl = rate_limits.get(key)
        if not rl:
            continue
        pct = int(rl.get("used_percentage", 0))
        resets_at = rl.get("resets_at", 0)
        bar = progress_bar(pct)
        reset_str = format_reset(resets_at)
        reset_part = f"  resets {reset_str}" if reset_str else ""
        print(f"{GOLD}{label}{RESET}  {bar} {pct}%{reset_part}")


if __name__ == "__main__":
    main()

#!/usr/bin/env bash
# OpenClaw Environment Audit Script
# Runs on the remote host via SSH to check security, health, and configuration
# Usage: ssh user@host 'bash -s' < audit.sh
# Or:    ssh user@host 'bash -s' < audit.sh -- --section security

set +e  # Don't exit on individual check failures

# ──────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────
SECTION="${1:-all}"  # all | security | health | updates | docker | openclaw

RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

pass()  { ((PASS++)); echo -e "  ${GRN}[PASS]${NC} $1"; }
warn()  { ((WARN++)); echo -e "  ${YEL}[WARN]${NC} $1"; }
fail()  { ((FAIL++)); echo -e "  ${RED}[FAIL]${NC} $1"; }
info()  { echo -e "  ${BLU}[INFO]${NC} $1"; }
header(){ echo -e "\n${BLU}━━━ $1 ━━━${NC}"; }

# ──────────────────────────────────────────────────────────────────
# SECURITY CHECKS
# ──────────────────────────────────────────────────────────────────
check_security() {
    header "SECURITY"

    # SSH: Root login
    if sshd_config=$(sudo cat /etc/ssh/sshd_config 2>/dev/null); then
        if echo "$sshd_config" | grep -qiE '^\s*PermitRootLogin\s+no'; then
            pass "SSH root login disabled"
        else
            fail "SSH root login is NOT explicitly disabled"
        fi

        # SSH: Password authentication
        if echo "$sshd_config" | grep -qiE '^\s*PasswordAuthentication\s+no'; then
            pass "SSH password authentication disabled (key-only)"
        else
            warn "SSH password authentication may be enabled"
        fi

        # SSH: Port
        ssh_port=$(echo "$sshd_config" | grep -iE '^\s*Port\s+' | awk '{print $2}' || echo "22")
        ssh_port="${ssh_port:-22}"
        if [ "$ssh_port" = "22" ]; then
            warn "SSH running on default port 22"
        else
            pass "SSH running on non-default port: $ssh_port"
        fi
    else
        warn "Could not read sshd_config (need sudo)"
    fi

    # Firewall
    if command -v ufw &>/dev/null; then
        ufw_status=$(sudo ufw status 2>/dev/null || echo "inactive")
        if echo "$ufw_status" | grep -qi "active"; then
            pass "UFW firewall is active"
            info "Firewall rules:"
            sudo ufw status numbered 2>/dev/null | head -20 | while read -r line; do info "  $line"; done
        else
            fail "UFW firewall is NOT active"
        fi
    elif command -v firewall-cmd &>/dev/null; then
        if sudo firewall-cmd --state 2>/dev/null | grep -qi "running"; then
            pass "firewalld is active"
        else
            fail "firewalld is NOT active"
        fi
    else
        warn "No firewall manager (ufw/firewalld) found"
    fi

    # Open ports
    header "OPEN PORTS"
    if command -v ss &>/dev/null; then
        ss -tlnp 2>/dev/null | while read -r line; do info "$line"; done
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | while read -r line; do info "$line"; done
    fi

    # Fail2ban
    if command -v fail2ban-client &>/dev/null; then
        if sudo fail2ban-client status &>/dev/null; then
            pass "Fail2ban is running"
            jail_count=$(sudo fail2ban-client status 2>/dev/null | grep "Number of jail" | awk -F: '{print $2}' | tr -d ' ')
            info "Active jails: ${jail_count:-unknown}"
        else
            warn "Fail2ban installed but not running"
        fi
    else
        warn "Fail2ban is NOT installed"
    fi

    # Sensitive file permissions
    header "FILE PERMISSIONS"
    for f in /etc/shadow /etc/gshadow; do
        if [ -f "$f" ]; then
            perms=$(stat -c '%a' "$f" 2>/dev/null)
            if [ "$perms" = "640" ] || [ "$perms" = "600" ] || [ "$perms" = "000" ]; then
                pass "$f permissions: $perms"
            else
                fail "$f permissions too open: $perms"
            fi
        fi
    done

    # Authorized keys check
    for home_dir in /home/* /root; do
        ak="$home_dir/.ssh/authorized_keys"
        if [ -f "$ak" ]; then
            key_count=$(wc -l < "$ak" 2>/dev/null || echo 0)
            owner=$(stat -c '%U' "$ak" 2>/dev/null || echo "unknown")
            perms=$(stat -c '%a' "$ak" 2>/dev/null || echo "unknown")
            info "$ak: $key_count key(s), owner=$owner, perms=$perms"
            if [ "$perms" != "600" ] && [ "$perms" != "644" ]; then
                warn "$ak has unusual permissions: $perms"
            fi
        fi
    done

    # Users with sudo
    header "PRIVILEGED USERS"
    if getent group sudo &>/dev/null; then
        sudo_users=$(getent group sudo | awk -F: '{print $4}')
        info "sudo group members: ${sudo_users:-none}"
    fi
    if [ -d /etc/sudoers.d ]; then
        sudoers_files=$(ls /etc/sudoers.d/ 2>/dev/null)
        if [ -n "$sudoers_files" ]; then
            info "Custom sudoers files: $sudoers_files"
        fi
    fi

    # Users with login shells
    login_users=$(grep -v '/nologin\|/false' /etc/passwd 2>/dev/null | cut -d: -f1 | tr '\n' ', ')
    info "Users with login shells: ${login_users%, }"
}

# ──────────────────────────────────────────────────────────────────
# SYSTEM HEALTH CHECKS
# ──────────────────────────────────────────────────────────────────
check_health() {
    header "SYSTEM HEALTH"

    # OS info
    if [ -f /etc/os-release ]; then
        os_name=$(. /etc/os-release && echo "$PRETTY_NAME")
        info "OS: $os_name"
    fi
    info "Kernel: $(uname -r)"
    info "Uptime: $(uptime -p 2>/dev/null || uptime)"

    # CPU load
    load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}')
    cores=$(nproc 2>/dev/null || echo 1)
    if [ -n "$load" ]; then
        load_pct=$(echo "$load $cores" | awk '{printf "%.0f", ($1/$2)*100}')
        if [ "$load_pct" -gt 90 ]; then
            fail "CPU load is critical: $load ($cores cores, ${load_pct}%)"
        elif [ "$load_pct" -gt 70 ]; then
            warn "CPU load is elevated: $load ($cores cores, ${load_pct}%)"
        else
            pass "CPU load normal: $load ($cores cores, ${load_pct}%)"
        fi
    fi

    # Memory
    mem_info=$(free -m 2>/dev/null | grep Mem)
    if [ -n "$mem_info" ]; then
        mem_total=$(echo "$mem_info" | awk '{print $2}')
        mem_used=$(echo "$mem_info" | awk '{print $3}')
        mem_pct=$((mem_used * 100 / mem_total))
        if [ "$mem_pct" -gt 90 ]; then
            fail "Memory usage critical: ${mem_pct}% (${mem_used}MB / ${mem_total}MB)"
        elif [ "$mem_pct" -gt 75 ]; then
            warn "Memory usage elevated: ${mem_pct}% (${mem_used}MB / ${mem_total}MB)"
        else
            pass "Memory usage normal: ${mem_pct}% (${mem_used}MB / ${mem_total}MB)"
        fi
    fi

    # Swap
    swap_info=$(free -m 2>/dev/null | grep Swap)
    if [ -n "$swap_info" ]; then
        swap_total=$(echo "$swap_info" | awk '{print $2}')
        swap_used=$(echo "$swap_info" | awk '{print $3}')
        if [ "$swap_total" -gt 0 ]; then
            swap_pct=$((swap_used * 100 / swap_total))
            if [ "$swap_pct" -gt 50 ]; then
                warn "Swap usage elevated: ${swap_pct}% (${swap_used}MB / ${swap_total}MB)"
            else
                pass "Swap usage normal: ${swap_pct}% (${swap_used}MB / ${swap_total}MB)"
            fi
        else
            warn "No swap configured"
        fi
    fi

    # Disk usage
    header "DISK USAGE"
    df -h --output=target,pcent,size,used,avail -x tmpfs -x devtmpfs 2>/dev/null | while read -r line; do
        pct=$(echo "$line" | awk '{print $2}' | tr -d '%')
        if [[ "$pct" =~ ^[0-9]+$ ]]; then
            if [ "$pct" -gt 90 ]; then
                fail "Disk $line"
            elif [ "$pct" -gt 75 ]; then
                warn "Disk $line"
            else
                pass "Disk $line"
            fi
        else
            info "$line"
        fi
    done

    # Zombie processes
    zombies=$(ps aux 2>/dev/null | awk '$8 ~ /Z/ {count++} END {print count+0}')
    if [ "$zombies" -gt 0 ]; then
        warn "Zombie processes found: $zombies"
    else
        pass "No zombie processes"
    fi

    # OOM kills (recent)
    if dmesg 2>/dev/null | grep -qi "out of memory" 2>/dev/null; then
        warn "OOM killer has been triggered (check dmesg)"
    else
        pass "No recent OOM kills detected"
    fi
}

# ──────────────────────────────────────────────────────────────────
# UPDATE CHECKS
# ──────────────────────────────────────────────────────────────────
check_updates() {
    header "UPDATES & PATCHES"

    # Package updates
    if command -v apt &>/dev/null; then
        # Don't run apt update (could be slow), check existing cache
        upgradable=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || true)
        upgradable=$(echo "$upgradable" | tail -1)
        upgradable="${upgradable:-0}"
        if [ "$upgradable" -gt 0 ]; then
            warn "$upgradable package(s) can be upgraded"
        else
            pass "All packages up to date"
        fi

        # Security updates specifically
        security_updates=$(apt list --upgradable 2>/dev/null | grep -ci "security" || true)
        security_updates=$(echo "$security_updates" | tail -1)
        security_updates="${security_updates:-0}"
        if [ "$security_updates" -gt 0 ]; then
            fail "$security_updates SECURITY update(s) pending"
        fi
    elif command -v yum &>/dev/null; then
        updates=$(yum check-update 2>/dev/null | grep -c "." || echo 0)
        if [ "$updates" -gt 5 ]; then
            warn "$updates package(s) can be upgraded"
        else
            pass "Packages mostly up to date"
        fi
    fi

    # Unattended upgrades
    if dpkg -l unattended-upgrades 2>/dev/null | grep -q "^ii"; then
        pass "Unattended upgrades installed"
    else
        warn "Unattended upgrades NOT installed"
    fi

    # Reboot required
    if [ -f /var/run/reboot-required ]; then
        warn "System reboot required"
    else
        pass "No reboot required"
    fi

    # Node.js version (relevant for OpenClaw)
    if command -v node &>/dev/null; then
        node_ver=$(node --version 2>/dev/null)
        info "Node.js version: $node_ver"
        # Check if it's a current LTS
        major=$(echo "$node_ver" | sed 's/v//' | cut -d. -f1)
        if [ "$major" -lt 18 ]; then
            fail "Node.js $node_ver is EOL — upgrade to LTS"
        elif [ "$major" -lt 20 ]; then
            warn "Node.js $node_ver — consider upgrading to latest LTS"
        else
            pass "Node.js $node_ver is current"
        fi
    else
        info "Node.js not found on PATH"
    fi

    # npm audit (if package.json found in common locations)
    for pkg_dir in /opt/openclaw /home/*/openclaw /home/*/.openclaw; do
        if [ -f "$pkg_dir/package.json" ]; then
            info "Found package.json at $pkg_dir"
            vuln_count=$(cd "$pkg_dir" && npm audit --json 2>/dev/null | grep -c '"severity"' || echo 0)
            if [ "$vuln_count" -gt 0 ]; then
                warn "npm audit found $vuln_count vulnerability entries in $pkg_dir"
            else
                pass "npm audit clean in $pkg_dir"
            fi
        fi
    done
}

# ──────────────────────────────────────────────────────────────────
# DOCKER CHECKS
# ──────────────────────────────────────────────────────────────────
check_docker() {
    header "DOCKER"

    if ! command -v docker &>/dev/null; then
        info "Docker not installed — skipping"
        return
    fi

    if ! docker info &>/dev/null; then
        warn "Docker installed but daemon not reachable (permission or service issue)"
        return
    fi

    pass "Docker daemon is running"

    # Container status
    total=$(docker ps -a --format '{{.Names}}' 2>/dev/null | wc -l)
    running=$(docker ps --format '{{.Names}}' 2>/dev/null | wc -l)
    info "Containers: $running running / $total total"

    # Unhealthy or restarting containers
    unhealthy=$(docker ps --filter "health=unhealthy" --format '{{.Names}}' 2>/dev/null)
    if [ -n "$unhealthy" ]; then
        fail "Unhealthy containers: $unhealthy"
    else
        pass "No unhealthy containers"
    fi

    restarting=$(docker ps --filter "status=restarting" --format '{{.Names}}' 2>/dev/null)
    if [ -n "$restarting" ]; then
        fail "Restarting containers: $restarting"
    fi

    # Exited containers
    exited=$(docker ps -a --filter "status=exited" --format '{{.Names}}: exited {{.Status}}' 2>/dev/null)
    if [ -n "$exited" ]; then
        warn "Exited containers:"
        echo "$exited" | while read -r line; do info "  $line"; done
    fi

    # Disk usage
    docker_disk=$(docker system df 2>/dev/null)
    if [ -n "$docker_disk" ]; then
        info "Docker disk usage:"
        echo "$docker_disk" | while read -r line; do info "  $line"; done
    fi

    # Dangling images
    dangling=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l)
    if [ "$dangling" -gt 5 ]; then
        warn "$dangling dangling images — consider pruning"
    elif [ "$dangling" -gt 0 ]; then
        info "$dangling dangling image(s)"
    else
        pass "No dangling images"
    fi
}

# ──────────────────────────────────────────────────────────────────
# OPENCLAW-SPECIFIC CHECKS
# ──────────────────────────────────────────────────────────────────
check_openclaw() {
    header "OPENCLAW"

    # Check for OpenClaw process
    if pgrep -f "openclaw|openclaw-gatewa|open-claw" &>/dev/null; then
        pass "OpenClaw process detected"
    else
        warn "No OpenClaw process found running"
    fi

    # Check for OpenClaw systemd service
    for svc in openclaw openclaw.service open-claw; do
        if systemctl is-active "$svc" &>/dev/null 2>&1; then
            pass "Service '$svc' is active"
            break
        fi
    done

    # Config file permissions — look in common locations
    for config_dir in /opt/openclaw /home/*/openclaw /home/*/.openclaw /home/*/.config/openclaw; do
        if [ -d "$config_dir" ]; then
            info "Found OpenClaw directory: $config_dir"

            # Check .env files
            for env_file in "$config_dir"/.env "$config_dir"/.env.local "$config_dir"/config.json; do
                if [ -f "$env_file" ]; then
                    perms=$(stat -c '%a' "$env_file" 2>/dev/null)
                    owner=$(stat -c '%U' "$env_file" 2>/dev/null)
                    if [ "$perms" = "600" ] || [ "$perms" = "640" ]; then
                        pass "$env_file permissions: $perms (owner: $owner)"
                    else
                        fail "$env_file permissions too open: $perms — should be 600 or 640"
                    fi
                fi
            done

            # Check for exposed API keys in config
            if grep -rqlE "(sk-|ANTHROPIC_API_KEY|OPENAI_API_KEY)" "$config_dir"/*.json "$config_dir"/.env* 2>/dev/null; then
                info "API keys found in config files — ensure file permissions are restrictive"
            fi

            # Recent errors in logs
            for log in "$config_dir"/logs/*.log "$config_dir"/*.log /var/log/openclaw*.log; do
                if [ -f "$log" ]; then
                    recent_errors=$(tail -100 "$log" 2>/dev/null | grep -ciE "error|fatal|panic" || true)
                    recent_errors="${recent_errors##*$'\n'}"  # Take last line only
                    recent_errors="${recent_errors:-0}"
                    if [ "$recent_errors" -gt 10 ]; then
                        fail "$log: $recent_errors errors in last 100 lines"
                    elif [ "$recent_errors" -gt 0 ]; then
                        warn "$log: $recent_errors errors in last 100 lines"
                    else
                        pass "$log: no recent errors"
                    fi
                fi
            done
        fi
    done

    # SSL certificate check (if OpenClaw serves HTTPS)
    header "SSL / TLS"
    if command -v openssl &>/dev/null; then
        for domain in localhost openclaw.ai; do
            cert_info=$(echo | timeout 5 openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || true)
            if [ -n "$cert_info" ]; then
                expiry=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
                if [ -n "$expiry" ]; then
                    expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null || echo 0)
                    now_epoch=$(date +%s)
                    days_left=$(( (expiry_epoch - now_epoch) / 86400 ))
                    if [ "$days_left" -lt 7 ]; then
                        fail "SSL cert for $domain expires in $days_left days ($expiry)"
                    elif [ "$days_left" -lt 30 ]; then
                        warn "SSL cert for $domain expires in $days_left days ($expiry)"
                    else
                        pass "SSL cert for $domain valid for $days_left days"
                    fi
                fi
            fi
        done
    fi
}

# ──────────────────────────────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────────────────────────────
print_summary() {
    header "AUDIT SUMMARY"
    echo -e "  ${GRN}Passed: $PASS${NC}"
    echo -e "  ${YEL}Warnings: $WARN${NC}"
    echo -e "  ${RED}Failures: $FAIL${NC}"
    echo ""
    if [ "$FAIL" -gt 0 ]; then
        echo -e "  ${RED}Action required — $FAIL issue(s) need attention${NC}"
    elif [ "$WARN" -gt 0 ]; then
        echo -e "  ${YEL}Review recommended — $WARN warning(s) found${NC}"
    else
        echo -e "  ${GRN}All checks passed${NC}"
    fi
}

# ──────────────────────────────────────────────────────────────────
# MAIN
# ──────────────────────────────────────────────────────────────────
echo -e "${BLU}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLU}║   OpenClaw Environment Audit          ║${NC}"
echo -e "${BLU}║   Host: $(hostname)${NC}"
echo -e "${BLU}║   Date: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BLU}╚═══════════════════════════════════════╝${NC}"

case "$SECTION" in
    security) check_security ;;
    health)   check_health ;;
    updates)  check_updates ;;
    docker)   check_docker ;;
    openclaw) check_openclaw ;;
    all)
        check_security
        check_health
        check_updates
        check_docker
        check_openclaw
        ;;
    *)
        echo "Unknown section: $SECTION"
        echo "Usage: audit.sh [all|security|health|updates|docker|openclaw]"
        exit 1
        ;;
esac

print_summary

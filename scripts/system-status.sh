#!/usr/bin/env bash
set -euo pipefail

# JARVIS colors (enabled only for interactive terminals)
if [[ -t 1 ]]; then
    CYAN=$'\033[38;2;72;214;232m'
    BLUE=$'\033[38;2;87;148;242m'
    MUTED=$'\033[38;2;130;149;168m'
    WHITE=$'\033[38;2;215;224;234m'
    RESET=$'\033[0m'
else
    CYAN=''
    BLUE=''
    MUTED=''
    WHITE=''
    RESET=''
fi

read_cpu() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0
        for (i = 2; i <= NF; i++) total += $i
        print total, idle
    }' /proc/stat
}

read -r total1 idle1 < <(read_cpu)
sleep 1
read -r total2 idle2 < <(read_cpu)

total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))
cpu=0

if (( total_diff > 0 )); then
    cpu=$(( (total_diff - idle_diff) * 100 / total_diff ))
fi

read -r mem_total mem_available < <(
    awk '
        /^MemTotal:/     { total = $2 }
        /^MemAvailable:/ { available = $2 }
        END { print total, available }
    ' /proc/meminfo
)

mem_used=$((mem_total - mem_available))
mem_percent=$((mem_used * 100 / mem_total))

uptime_seconds=$(cut -d. -f1 /proc/uptime)
days=$((uptime_seconds / 86400))
hours=$((uptime_seconds % 86400 / 3600))
minutes=$((uptime_seconds % 3600 / 60))

if (( days > 0 )); then
    uptime="${days}d ${hours}h ${minutes}m"
else
    uptime="${hours}h ${minutes}m"
fi

battery='Unavailable'
for capacity in /sys/class/power_supply/*/capacity; do
    [[ -r "$capacity" ]] || continue
    name=${capacity%/capacity}
    type_file="$name/type"

    if [[ -r "$type_file" ]] && [[ "$(<"$type_file")" == "Battery" ]]; then
        battery="$(<"$capacity")%"
        break
    fi
done

printf '\n'
printf '%s  J A R V I S  /  SYSTEM STATUS%s\n' "$CYAN" "$RESET"
printf '%s  ─────────────────────────────%s\n' "$MUTED" "$RESET"
printf '%s  COMPUTE%s\n' "$BLUE" "$RESET"
printf '  %-12s %s%3s%%%s\n' 'CPU LOAD' "$WHITE" "$cpu" "$RESET"
printf '  %-12s %s%3s%%%s  %s(%s / %s MiB)%s\n' \
    'MEMORY' "$WHITE" "$mem_percent" "$RESET" "$MUTED" \
    "$((mem_used / 1024))" "$((mem_total / 1024))" "$RESET"
printf '\n'
printf '%s  DEVICE%s\n' "$BLUE" "$RESET"
printf '  %-12s %s%s%s\n' 'BATTERY' "$WHITE" "$battery" "$RESET"
printf '  %-12s %s%s%s\n' 'UPTIME' "$WHITE" "$uptime" "$RESET"
printf '\n'

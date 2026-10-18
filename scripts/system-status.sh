#!/usr/bin/env bash
set -uo pipefail

INTERVAL=2
MODE=snapshot

while (($#)); do
    case "$1" in
        --watch|-w) MODE=watch; shift ;;
        --interval|-i)
            [[ $# -ge 2 && "$2" =~ ^[1-9][0-9]*$ ]] || exit 2
            INTERVAL="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: developer-status [--watch] [--interval SECONDS]"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

CYAN=$'\033[38;2;72;214;232m'
BLUE=$'\033[38;2;87;148;242m'
MUTED=$'\033[38;2;130;149;168m'
WHITE=$'\033[38;2;215;224;234m'
GREEN=$'\033[38;2;120;217;156m'
YELLOW=$'\033[38;2;230;200;117m'
RESET=$'\033[0m'

read_cpu() {
    awk '/^cpu / {
        idle = $5 + $6
        total = 0
        for (i=2; i<=NF; i++) total += $i
        print total, idle
    }' /proc/stat
}

cpu_usage() {
    read -r t1 i1 < <(read_cpu)
    sleep 0.25
    read -r t2 i2 < <(read_cpu)
    d=$((t2-t1))
    (( d > 0 )) && echo $(((d-(i2-i1))*100/d)) || echo 0
}

bar() {
    local value=$1 width=24 filled i
    filled=$((value*width/100))
    ((filled > width)) && filled=$width
    for ((i=0; i<width; i++)); do
        if ((i < filled)); then printf '█'
        else printf '░'
        fi
    done
}

render() {
    local cpu total available used mem battery uptime spin
    cpu=$(cpu_usage)

    read -r total available < <(
        awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2}
        END {print t,a}' /proc/meminfo
    )
    used=$((total-available))
    mem=$((used*100/total))

    uptime=$(awk '{s=int($1); printf "%dd %02dh %02dm",
        s/86400, (s%86400)/3600, (s%3600)/60}' /proc/uptime)

    battery="N/A"
    for f in /sys/class/power_supply/*/capacity; do
        [[ -r "$f" ]] || continue
        d=${f%/capacity}
        if [[ -r "$d/type" ]] && [[ "$(<"$d/type")" == Battery ]]; then
            battery="$(<"$f")%"
            break
        fi
    done

    printf '\033[H'
    printf '%s╔══════════════════════════════════════════════════════╗%s\n' "$CYAN" "$RESET"
    printf '%s║          J A R V I S  /  SYSTEM STATUS               ║%s\n' "$CYAN" "$RESET"
    printf '%s╚══════════════════════════════════════════════════════╝%s\n\n' "$CYAN" "$RESET"

    printf '%s  SYSTEM TIME%s   %s\n' "$BLUE" "$RESET" "$(date '+%A, %d %b %Y  %H:%M:%S')"
    printf '%s  HOST%s          %s\n\n' "$BLUE" "$RESET" "$(hostname)"

    printf '%s  COMPUTE%s\n' "$CYAN" "$RESET"
    printf '  CPU LOAD %3d%%  ' "$cpu"
    if ((cpu >= 80)); then printf '%s' "$YELLOW"; else printf '%s' "$GREEN"; fi
    bar "$cpu"
    printf '%s\n' "$RESET"

    printf '  MEMORY   %3d%%  %s' "$mem" "$BLUE"
    bar "$mem"
    printf '%s\n' "$RESET"
    printf '           %s / %s MiB used\n\n' "$((used/1024))" "$((total/1024))"

    printf '%s  DEVICE%s\n' "$CYAN" "$RESET"
    printf '  BATTERY  %s\n' "$battery"
    printf '  UPTIME   %s\n\n' "$uptime"

    spin=( '|' '/' '-' '\' )
    printf '%s  ● LIVE%s  Refresh: %ss  |  Cycle: %s  |  Press q to quit\n' \
        "$GREEN" "$RESET" "$INTERVAL" "$(( $(date +%s) % 4 + 1 ))"
}

if [[ "$MODE" == snapshot ]]; then
    render
    exit 0
fi

[[ -t 1 ]] || { echo "--watch requires an interactive terminal" >&2; exit 1; }

cleanup() {
    printf '\033[?25h\033[0m\n'
}
trap cleanup EXIT INT TERM
printf '\033[?25l\033[2J'

while true; do
    render
    IFS= read -rsn1 -t "$INTERVAL" key || key=''
    [[ "$key" == q || "$key" == Q ]] && break
done

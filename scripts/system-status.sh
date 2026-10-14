#!/usr/bin/env bash
set -euo pipefail

# Read the first CPU sample.
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

if (( total_diff > 0 )); then
    cpu=$(( (total_diff - idle_diff) * 100 / total_diff ))
else
    cpu=0
fi

# Memory usage from /proc/meminfo.
read -r mem_total mem_available < <(
    awk '
        /^MemTotal:/     { total = $2 }
        /^MemAvailable:/ { available = $2 }
        END { print total, available }
    ' /proc/meminfo
)

mem_used=$((mem_total - mem_available))
mem_percent=$((mem_used * 100 / mem_total))

printf '\n'
printf '  DEVELOPER DESKTOP\n'
printf '  -----------------\n'
printf '  CPU Usage:  %s%%\n' "$cpu"
printf '  RAM Usage:  %s%% (%s / %s MiB)\n' \
    "$mem_percent" \
    "$((mem_used / 1024))" \
    "$((mem_total / 1024))"

# WSL may not expose battery information.
battery_found=false
for capacity in /sys/class/power_supply/*/capacity; do
    if [[ -r "$capacity" ]]; then
        name=${capacity%/capacity}
        type_file="$name/type"
        if [[ -r "$type_file" ]] &&
           [[ $(<"$type_file") == Battery ]]; then
            printf '  Battery:    %s%%\n' "$(<"$capacity")"
            battery_found=true
            break
        fi
    fi
done

if [[ "$battery_found" == false ]]; then
    printf '  Battery:    Not exposed to this Linux environment\n'
fi
printf '\n'

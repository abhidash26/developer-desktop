#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output="$("$ROOT/scripts/system-status.sh")"

for expected in \
    "J A R V I S" \
    "SYSTEM STATUS" \
    "CPU LOAD" \
    "MEMORY" \
    "BATTERY" \
    "UPTIME"; do
    if ! grep -Fq "$expected" <<< "$output"; then
        echo "FAIL: missing output: $expected" >&2
        exit 1
    fi
done

echo "PASS: JARVIS system monitor reports CPU, memory, battery and uptime"

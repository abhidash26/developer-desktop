#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
output="$("$ROOT/scripts/system-status.sh")"

for expected in "DEVELOPER DESKTOP" "CPU Usage:" "RAM Usage:" "Battery:"; do
    if ! grep -Fq "$expected" <<< "$output"; then
        echo "FAIL: missing output: $expected" >&2
        exit 1
    fi
done

echo "PASS: system monitor reports CPU, RAM and battery status"

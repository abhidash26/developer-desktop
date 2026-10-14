#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/developer-desktop-backup"

mkdir -p "$HOME/.config" "$HOME/.local/bin"

if [[ -f "$HOME/.zshrc" ]] &&
   [[ ! -f "$BACKUP_DIR/zshrc" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.zshrc" "$BACKUP_DIR/zshrc"
fi

install -m 644 "$ROOT/config/zshrc" "$HOME/.zshrc"
ln -sfn "$ROOT/scripts/system-status.sh" \
    "$HOME/.local/bin/developer-status"

echo "Developer Desktop installed."
echo "Run: zsh"
echo "Monitor: ~/.local/bin/developer-status"

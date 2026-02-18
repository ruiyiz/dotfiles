#!/bin/bash

# Sync WezTerm config from dotfiles to Windows home directory.
# Only relevant when running inside WSL.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_DIR/wezterm/.wezterm.lua"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Not running in WSL, skipping WezTerm Windows sync."
    exit 0
fi

WIN_HOME="$(wslpath "$(cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")"
DEST="$WIN_HOME/.wezterm.lua"

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source config not found at $SOURCE"
    exit 1
fi

cp "$SOURCE" "$DEST"
echo "Synced WezTerm config to $DEST"

#!/bin/bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

# List of directories to manage
DIRS=("nvim" "git" "tmux" "zsh" "wezterm" "claude")

# Check if parameter is provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 [stow|unstow] [--adopt]"
    exit 1
fi

# Check for --adopt flag
ADOPT_FLAG=""
if [ "$2" = "--adopt" ]; then
    ADOPT_FLAG="--adopt"
fi

# Process based on parameter
case "$1" in
    "stow")
        ACTION="$ADOPT_FLAG"
        echo "Stowing dotfiles..."
        ;;
    "unstow")
        ACTION="-D"
        echo "Unstowing dotfiles..."
        ;;
    *)
        echo "Invalid parameter. Use 'stow' or 'unstow'"
        exit 1
        ;;
esac

# Execute stow commands with proper locale setting
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Processing $dir..."
        LC_ALL=C stow $ACTION "$dir" -t ~
    else
        echo "Warning: Directory $dir not found, skipping."
    fi
done

# Handle VS Code configurations separately (requires Python script)
if [ -f "bin/manage_vscode_config.py" ] && [ -d "vscode" ]; then
    echo ""
    echo "Managing VS Code configurations..."
    python3 bin/manage_vscode_config.py "$1"
fi

echo "Done!"

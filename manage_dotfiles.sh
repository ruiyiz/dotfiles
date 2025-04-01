#!/bin/bash

# List of directories to manage
DIRS=("nvim" "emacs" "git" "tmux" "zsh" "wezterm")

# Check if parameter is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 [stow|unstow]"
    exit 1
fi

# Process based on parameter
case "$1" in
    "stow")
        ACTION=""
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

echo "Done!"

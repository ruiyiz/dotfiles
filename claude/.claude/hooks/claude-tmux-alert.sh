#!/bin/bash
[ -z "$TMUX" ] && exit 0

# Identify the window containing this Claude session's pane
pane_id="${TMUX_PANE}"
[ -z "$pane_id" ] && exit 0
window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')
[ -z "$window_id" ] && exit 0

case "$1" in
  on)
    # Skip if this is the currently active window
    is_active=$(tmux display-message -p -t "$pane_id" '#{window_active}')
    [ "$is_active" = "1" ] && exit 0
    tmux set-window-option -t "$window_id" @claude_waiting 1
    ;;
  off)
    tmux set-window-option -u -t "$window_id" @claude_waiting 2>/dev/null
    ;;
esac

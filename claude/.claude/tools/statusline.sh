#!/bin/bash
# Claude Code statusline script

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
repo=$(basename "$cwd")

# Token counts
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

current_tokens=$((input_tokens + cache_creation + cache_read))
ctx_pct=$((current_tokens * 100 / context_size))

# Context bar (6 chars, disc icons)
filled="⛀"
empty="⛶"
bar_width=6
filled_count=$((ctx_pct * bar_width / 100))
[ $filled_count -gt $bar_width ] && filled_count=$bar_width
bar=""
for ((i=0; i<filled_count; i++)); do bar+="$filled "; done
for ((i=filled_count; i<bar_width; i++)); do bar+="$empty "; done

# Context color (red >80%, orange >40%, white otherwise)
if [ $ctx_pct -ge 80 ]; then
    ctx_color="\033[38;2;239;68;68m"
elif [ $ctx_pct -ge 40 ]; then
    ctx_color="\033[38;2;217;119;87m"
else
    ctx_color="\033[37m"
fi
reset="\033[0m"

# Git info
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")
    staged=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    unstaged=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    # Ahead/behind remote
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git -C "$cwd" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
        behind=$(git -C "$cwd" rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
    else
        ahead=0
        behind=0
    fi
    # Git status colors
    staged_color="\033[38;2;217;119;87m"    # primary #d97757
    unstaged_color="\033[38;2;156;135;245m" # chart 2 #9c87f5
    untracked_color="\033[38;2;183;181;169m" # muted foreground #b7b5a9
    ahead_behind_color="\033[38;2;183;181;169m"
    printf '%b' "${repo} | ${branch} ${ahead_behind_color}↑${ahead} ↓${behind}${reset} | ${ctx_color}${bar}${ctx_pct}%${reset} | ${staged_color}✓: ${staged}${reset} | ${unstaged_color}✎: ${unstaged}${reset} | ${untracked_color}+: ${untracked}${reset} "
else
    printf '%b' "${repo} | ${ctx_color}${bar}${ctx_pct}%${reset}"
fi

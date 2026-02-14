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

# Context icon (single dynamic icon based on fill level)
if [ $ctx_pct -ge 80 ]; then
    ctx_icon="●"
    ctx_color="\033[38;2;239;68;68m"
elif [ $ctx_pct -ge 60 ]; then
    ctx_icon="◕"
    ctx_color="\033[38;2;217;119;87m"
elif [ $ctx_pct -ge 40 ]; then
    ctx_icon="◑"
    ctx_color="\033[38;2;217;119;87m"
elif [ $ctx_pct -ge 20 ]; then
    ctx_icon="◔"
    ctx_color="\033[37m"
else
    ctx_icon="○"
    ctx_color="\033[37m"
fi
reset="\033[0m"

# Git info
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")
    staged=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    unstaged=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    untracked=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git -C "$cwd" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
        behind=$(git -C "$cwd" rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
    else
        ahead=0
        behind=0
    fi

    # Git status colors
    staged_color="\033[38;2;217;119;87m"
    unstaged_color="\033[38;2;156;135;245m"
    untracked_color="\033[38;2;183;181;169m"
    ahead_behind_color="\033[38;2;183;181;169m"

    # Build git section: branch + ahead/behind + file stats
    git_section="${branch}"
    git_section+=" ${ahead_behind_color}↑${ahead} ↓${behind}${reset}"
    git_section+=" ${staged_color}✓${staged}${reset}"
    git_section+=" ${unstaged_color}✎${unstaged}${reset}"
    git_section+=" ${untracked_color}+${untracked}${reset}"

    printf '%b' "${repo} | ${git_section} | ${ctx_color}${ctx_icon} ${ctx_pct}%${reset}"
else
    printf '%b' "${repo} | ${ctx_color}${ctx_icon} ${ctx_pct}%${reset}"
fi

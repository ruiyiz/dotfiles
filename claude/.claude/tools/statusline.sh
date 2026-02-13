#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
basename_cwd=$(basename "$cwd")

output=$(printf "\033[36m%s\033[0m" "$basename_cwd")

git_branch=$(cd "$cwd" 2>/dev/null && git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
if [ -n "$git_branch" ]; then
  output=$(printf "%s \033[31m%s\033[0m" "$output" "$git_branch")

  dirty=$(cd "$cwd" 2>/dev/null && git -c core.useBuiltinFSMonitor=false status --porcelain 2>/dev/null)
  if [ -n "$dirty" ]; then
    output=$(printf "%s \033[33m✗\033[0m" "$output")
  fi

  ahead=$(cd "$cwd" 2>/dev/null && git -c core.useBuiltinFSMonitor=false rev-list --count @{u}..HEAD 2>/dev/null)
  if [ -n "$ahead" ] && [ "$ahead" -gt 0 ] 2>/dev/null; then
    output=$(printf "%s \033[32m↑%s\033[0m" "$output" "$ahead")
  fi
fi

echo "$output"

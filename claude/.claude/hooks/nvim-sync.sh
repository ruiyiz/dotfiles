#!/bin/bash
# PostToolUse hook: sync edited/written files to the Neovim instance
# started by tdev. Requires NVIM_LISTEN_ADDRESS to be set (tdev does this).
[ -z "$NVIM_LISTEN_ADDRESS" ] && exit 0
[ ! -S "$NVIM_LISTEN_ADDRESS" ] && exit 0

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0

follow=$(nvim --server "$NVIM_LISTEN_ADDRESS" --remote-expr "get(g:, 'agent_follow', 1)" 2>/dev/null)

if [ "$follow" = "1" ]; then
    nvim --server "$NVIM_LISTEN_ADDRESS" --remote-send \
        "<C-\\><C-n>:checktime<CR>:edit $file_path<CR>:lua vim.defer_fn(function() require('gitsigns').nav_hunk('first') end, 100)<CR>" 2>/dev/null
else
    nvim --server "$NVIM_LISTEN_ADDRESS" --remote-send \
        "<C-\\><C-n>:checktime<CR>" 2>/dev/null
fi

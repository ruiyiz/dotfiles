#!/bin/bash
# PostToolUse hook: lint and format files edited by Claude.
# Formatters run silently in-place; linters report issues back to Claude.

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

ext="${file_path##*.}"
exit_code=0

# Detect shell dialect from extension or shebang
is_bash=false
is_zsh=false
case "$ext" in
    sh|bash) is_bash=true ;;
    zsh)     is_zsh=true ;;
    *)
        shebang=$(head -1 "$file_path" 2>/dev/null)
        case "$shebang" in
            *bash*) is_bash=true ;;
            *zsh*)  is_zsh=true ;;
            */sh*)  is_bash=true ;;
        esac
        ;;
esac

# Shell: shfmt (format) + shellcheck (lint, bash only)
if $is_bash || $is_zsh; then
    command -v shfmt &>/dev/null && shfmt -w "$file_path" 2>/dev/null
    if $is_bash && command -v shellcheck &>/dev/null; then
        shellcheck "$file_path" || exit_code=$?
    fi
fi

# Lua: stylua (format)
if [ "$ext" = "lua" ]; then
    command -v stylua &>/dev/null && stylua "$file_path" 2>/dev/null
fi

# Python: ruff (format + lint)
if [ "$ext" = "py" ]; then
    if command -v ruff &>/dev/null; then
        ruff format --quiet "$file_path"
        ruff check "$file_path" || exit_code=$?
    fi
fi

# TypeScript / JavaScript: prettier (format)
case "$ext" in
    ts|tsx|js|jsx|mjs|cjs)
        command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
        ;;
esac

# R: air (format)
case "$ext" in
    R|r)
        command -v air &>/dev/null && air format "$file_path" 2>/dev/null
        ;;
esac

# Markdown / JSON: prettier (format)
case "$ext" in
    md|markdown|json)
        command -v prettier &>/dev/null && prettier --write "$file_path" 2>/dev/null
        ;;
esac

exit $exit_code

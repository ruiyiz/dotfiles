# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a minimal but functional Neovim configuration designed for data science and light terminal editing. The configuration follows the standard Neovim structure:

### Core Structure
- `init.lua` - Entry point that loads the lazy configuration
- `lua/config/lazy.lua` - Bootstraps lazy.nvim and loads core configurations
- `lua/config/options.lua` - Vim options (line numbers, indentation, search, etc.)
- `lua/config/keymaps.lua` - Custom keymaps matching VS Code workflow patterns
- `lua/plugins/` - Directory for plugin specifications

### Plugin Files
- `lua/plugins/treesitter.lua` - Syntax highlighting for Python, R, SQL, Markdown
- `lua/plugins/which-key.lua` - Keybinding hints and discovery
- `lua/plugins/telescope.lua` - Fuzzy finding (files, content, buffers)
- `lua/plugins/gitsigns.lua` - Git integration with sign column
- `lua/plugins/bufferline.lua` - IDE-style tab bar for open buffers
- `lua/plugins/ui.lua` - Colorscheme (Catppuccin) and statusline (Lualine)

## Key Configuration

- **Leader key**: Space (`" "`) - matches VS Code Vim extension workflow
- **Local leader key**: Backslash (`"\"`)
- **Plugin manager**: lazy.nvim with automatic update checking
- **Colorscheme**: Catppuccin Mocha (dark, warm theme)
- **Languages**: Python, R, SQL, Markdown, Lua, JSON, YAML, Bash

## Essential Keymaps

Based on VS Code workflow patterns:

### File Operations
- `<space>w` - Save file
- `<space>ff` - Find files (Telescope)
- `<space>fg` - Live grep (search in files)
- `<space>fb` - Find buffers
- `<space>fr` - Recent files
- `<space>,` - Quick buffer switcher

### Buffer Management
- `Tab` / `Shift+Tab` - Next/previous buffer
- `]b` / `[b` - Next/previous buffer (with visual feedback)
- `Alt+1-9` - Jump directly to buffer by number
- `<space>bd` - Delete buffer
- `<space>bp` - Pick buffer (shows letters over tabs)
- `<space>bc` - Pick buffer to close
- `<space>bco` - Close other buffers
- `<space>bcr/bcl` - Close buffers to right/left
- `<space>bmh/bml` - Move buffer left/right in tab bar
- `<space>bP` - Pin/unpin buffer

### Window Management
- `<space>h` / `<space>v` - Split horizontal/vertical
- `Ctrl+hjkl` - Navigate between windows

### Git Operations
- `]c` / `[c` - Next/previous git hunk
- `<space>gs` - Stage hunk
- `<space>gr` - Reset hunk
- `<space>gp` - Preview hunk
- `<space>gb` - Git blame line
- `<space>gd` - Git diff

## Development Commands

- `nvim` - Start Neovim with this configuration
- `:Lazy` - Open lazy.nvim interface to manage plugins
- `:Lazy sync` - Update and install plugins
- `:checkhealth` - Check Neovim health and configuration issues
- `:TSUpdate` - Update Treesitter parsers
- `<space>` (wait 500ms) - See available keybindings via which-key

## Use Cases

This configuration is optimized for:
- **Data Science**: Python, R, SQL syntax highlighting and editing
- **Documentation**: Markdown files (including Obsidian)
- **Light Terminal Editing**: Quick file edits without heavy IDE features
- **Git Workflows**: Visual git integration without external tools
- **Fuzzy Finding**: Fast file and content discovery without file trees
- **IDE-like Experience**: Tab bar for visual buffer management and navigation

## Adding Plugins

To add new plugins:

1. Create a new `.lua` file in `lua/plugins/`
2. Return a plugin specification table following lazy.nvim format
3. Add extensive comments explaining the plugin's purpose and configuration
4. Include keymaps that follow the space-leader pattern
5. Update which-key groups in `lua/plugins/which-key.lua` if needed

## Philosophy

- **Minimal but Functional**: Only essential plugins, no bloat
- **Well-Commented**: Every option and keymap is explained
- **VS Code Familiarity**: Keybindings match existing muscle memory
- **Data Science Focus**: Optimized for Python, R, SQL, and Markdown
- **Progressive Enhancement**: Easy to understand and extend incrementally
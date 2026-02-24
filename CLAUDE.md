# CLAUDE.md

## MANDATORY: Use td for Task Management

Run td usage --new-session at conversation start (or after /clear). This tells you what to work on next.

Sessions are automatic (based on terminal/agent context). Optional:
- td session "name" to label the current session
- td session --new to force a new session in the same context

Use td usage -q after first read.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is Ruiyi Zhang's personal dotfiles repository containing configuration files for various development tools and applications. The repository uses GNU Stow for managing dotfile deployment.

## Architecture

The repository follows a modular structure where each tool has its own directory:

- `nvim/` - Neovim configuration using Kickstart.nvim as base with Lazy plugin manager
- `zsh/` - Zsh shell configuration with Oh My Zsh framework
- `vscode/` - VS Code settings and keybindings with derivative support (base + Positron-specific configs)
- `git/` - Git configuration with user settings and aliases
- `tmux/` - Terminal multiplexer configuration
- `emacs/` - Emacs configuration (Doom Emacs setup)
- `wezterm/` - WezTerm terminal emulator configuration
- `bin/` - Executable scripts (dotfile management, VS Code config deployment, tool installation)
- `_archived/` - Deprecated/archived configuration files

## Common Commands

### Dotfile Management
- **Deploy dotfiles**: `./bin/manage_dotfiles.sh stow`
- **Remove dotfiles**: `./bin/manage_dotfiles.sh unstow`

The stow script manages these directories: nvim, emacs, git, tmux, zsh, wezterm

### VS Code Configuration Management
- **Deploy VS Code configs**: `python3 bin/manage_vscode_config.py deploy`
- **Remove VS Code configs**: `python3 bin/manage_vscode_config.py remove`
- **Integrated deployment**: `./bin/manage_dotfiles.sh stow` (deploys both stow configs and VS Code configs)

The VS Code script handles cross-platform deployment with derivative support (Positron, Code Server)

### Tool Installation
- **Install/update all tools**: `./bin/install_tools.sh`
- **Install specific tools**: `./bin/install_tools.sh eza fd fzf`
- **Force reinstall (skip installed check)**: `./bin/install_tools.sh --force`

The install script auto-detects the platform (macOS or Debian family) and reads `packages.json` for per-tool install methods (brew, apt, GitHub releases, direct binaries, install scripts). Tools already on `$PATH` are skipped unless `--force` is used.

### Shell Environment
The zsh configuration includes:
- Oh My Zsh with robbyrussell theme
- fzf fuzzy finder integration
- yazi file manager with `y()` function for directory navigation
- NVM for Node.js version management
- Custom emacs aliases (`emacs --init-directory=$HOME/.config/emacs`)

### Development Tools
- **Neovim**: Configured with Kickstart.nvim, includes LSP, Telescope, and Treesitter
- **VS Code**: Vim mode enabled, custom keybindings, language-specific settings for R and Quarto
- **Git**: Shortcuts - `br` (branch), `co` (checkout), `st` (status)

## Key Configuration Details

### Neovim Setup
- **Architecture**: Custom minimal config (not Kickstart.nvim based)
- **Plugin Manager**: Lazy.nvim with automatic bootstrapping
- **Colorscheme**: Managed by Themery (`<leader>ft`), persists across sessions
- **Leader Key**: Space (matches VS Code workflow)
- **Core Plugins**:
  - Treesitter: Syntax highlighting for Python, R, SQL, Markdown, Lua
  - Telescope: Fuzzy finding (files, live grep, buffers, recent files)
  - Which-key: Keybinding hints and discovery
  - Gitsigns: Git integration with sign column and hunk operations
  - Bufferline: IDE-style tab bar for visual buffer management
  - Lualine: Informative statusline with mode, git, diagnostics (theme: `"auto"`)
- **Focus**: Data science and light terminal editing (Python, R, SQL, Markdown)
- **Key Features**: Space-leader workflow, buffer-centric navigation, git integration

### Theme Management

Themes are coordinated across Neovim, tmux, and WezTerm.

#### Neovim themes (`nvim/.config/nvim/lua/plugins/ui.lua`)
- **Plugin**: `themery.nvim` -- persistent switcher, `<leader>ft` to open
- **Installed colorschemes**: catppuccin (all 4 flavors), tokyonight (night/moon), kanagawa (dragon/wave), oxocarbon, gruvbox (6 variants via `before` hook), vague
- **Adding a theme**: add a lazy plugin spec (with `lazy = true`), add it to `themery` `dependencies` and `themes` list. For themes without sub-variants (like catppuccin/tokyonight), just add `{ name = "...", colorscheme = "..." }`. For themes that need setup options per variant (like gruvbox), use the `before` field: `before = [[vim.o.background = "dark"; require("gruvbox").setup({ contrast = "hard" })]]`

#### Tmux themes (`tmux/.config/tmux/themes/`)
- **Script**: `bin/tmux-theme <name>` -- switches tmux theme and WezTerm background simultaneously
- **Theme files**: `~/.config/tmux/themes/<name>.conf` -- define color variables (`thm_bg`, `thm_fg`, `thm_blue`, etc.) then `source-file ~/.config/tmux/theme-apply.conf`
- **Shared styles**: `tmux/.config/tmux/theme-apply.conf` -- all `set -g` status bar / border commands, uses variables set by the theme file
- **Current theme**: stored at `~/.config/tmux/current-theme.conf` (untracked, written by script)
- **Adding a tmux theme**: create `tmux/.config/tmux/themes/<name>.conf` with the color variables and a `source-file ~/.config/tmux/theme-apply.conf` at the end; run `stow` to deploy

#### WezTerm background (`wezterm/.wezterm.lua`)
- Background color is read from `~/.config/wezterm/background` (a plain hex color file)
- WezTerm watches this file via `add_to_config_reload_watch_list` and hot-reloads on change
- In WSL, `bin/tmux-theme` also writes to `%USERPROFILE%/.config/wezterm/background` so native WezTerm picks it up
- **Adding a WezTerm color**: add an entry to the `WEZTERM_COLORS` associative array in `bin/tmux-theme`, keyed by the tmux theme name

### VS Code Configuration
- **Cross-platform deployment**: Supports macOS, Linux, and Windows
- **Derivative support**: Base configurations with variant-specific overrides
  - Standard VS Code: Uses base `settings.json` and `keybindings.json`
  - Positron: Merges base + `settings.positron.json` and `keybindings.positron.json`
  - Code Server: Uses base configurations
- **Configuration features**:
  - Vim extension with easymotion and system clipboard integration
  - Gruvbox Dark Hard theme with relative line numbers
  - Custom font: Cascadia Code with JetBrains Mono fallback
  - Git autofetch enabled
  - Language-specific formatting for R and Quarto

### Neovim Integration (Agent Sync)

When running inside a `tdev` tmux session, `NVIM_LISTEN_ADDRESS` is set to a Neovim socket. Files edited via Edit/Write tools are automatically opened in the paired Neovim instance (via the `nvim-sync.sh` PostToolUse hook).

When the user asks to open a file in Neovim, you MUST use `--remote-send` to send a command to the already-running Neovim instance. NEVER launch a new `nvim` process. The correct command is:

```bash
nvim --server "$NVIM_LISTEN_ADDRESS" --remote-send "<C-\\><C-n>:edit <filepath><CR>"
```

Before running this command, check that `NVIM_LISTEN_ADDRESS` is set and the socket exists. If not, tell the user no Neovim instance is connected and suggest starting a `tdev` session.

The user can toggle auto-follow in Neovim with `<leader>af`. When follow is off, buffers still reload but Neovim won't switch to the edited file.

### Shell Features
- SSH key management with keychain (Linux only)
- Custom PATH modifications for Doom Emacs and local binaries

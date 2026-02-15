# CLAUDE.md

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
- `install/` - Package config files for tool installation (macOS and Ubuntu)
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

The install script auto-detects the OS and reads the appropriate config file (`packages_macos.conf` for Homebrew, `packages_ubuntu.conf` for Ubuntu with per-tool install methods including apt, GitHub releases, direct binaries, and install scripts).

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
- **Colorscheme**: Catppuccin Mocha (dark, warm theme)
- **Leader Key**: Space (matches VS Code workflow)
- **Core Plugins**:
  - Treesitter: Syntax highlighting for Python, R, SQL, Markdown, Lua
  - Telescope: Fuzzy finding (files, live grep, buffers, recent files)
  - Which-key: Keybinding hints and discovery
  - Gitsigns: Git integration with sign column and hunk operations
  - Bufferline: IDE-style tab bar for visual buffer management
  - Lualine: Informative statusline with mode, git, diagnostics
- **Focus**: Data science and light terminal editing (Python, R, SQL, Markdown)
- **Key Features**: Space-leader workflow, buffer-centric navigation, git integration

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

### Shell Features
- SSH key management with keychain (Linux only)
- Custom PATH modifications for Doom Emacs and local binaries
- Yazi file manager integration for terminal navigation
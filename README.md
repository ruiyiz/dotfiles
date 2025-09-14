# Ruiyi's Dotfiles

Personal configuration files for development tools and applications, managed with GNU Stow for easy deployment and organization.

## 🏗️ Structure

The repository is organized modularly with each tool in its own directory:

- **`nvim/`** - Neovim configuration using Kickstart.nvim with Lazy plugin manager
- **`zsh/`** - Zsh shell with Oh My Zsh framework and custom aliases
- **`vscode/`** - VS Code settings with cross-platform and derivative support
- **`git/`** - Git configuration with user settings and aliases
- **`tmux/`** - Terminal multiplexer configuration
- **`wezterm/`** - WezTerm terminal emulator configuration
- **`_archived/`** - Deprecated configuration files

## 🚀 Quick Start

### Deploy All Configurations

```bash
# Clone the repository
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles

# Deploy all dotfiles
./manage_dotfiles.sh stow
```

### Individual Management

```bash
# Remove dotfiles
./manage_dotfiles.sh unstow

# Deploy VS Code configurations separately
python3 manage_vscode_config.py deploy

# Remove VS Code configurations
python3 manage_vscode_config.py remove
```

## 🛠️ Tool Configurations

### Neovim
- **Architecture**: Custom minimal config optimized for data science
- **Plugin Manager**: Lazy.nvim with automatic bootstrapping
- **Colorscheme**: Catppuccin Mocha (dark theme)
- **Core Features**:
  - Treesitter syntax highlighting (Python, R, SQL, Markdown)
  - Telescope fuzzy finding and live grep
  - Bufferline for IDE-style tab management
  - Git integration with visual hunk operations
  - Space-leader keybindings matching VS Code workflow

### VS Code
- **Cross-platform**: Supports macOS, Linux, Windows
- **Derivatives**: Positron and Code Server support with merged configurations
- **Features**: Vim mode, Gruvbox theme, custom keybindings
- **Fonts**: Cascadia Code with JetBrains Mono fallback

### Zsh Shell
- **Framework**: Oh My Zsh with robbyrussell theme
- **Tools**: fzf, yazi file manager, NVM
- **Custom Functions**: `y()` for yazi directory navigation
- **Platform-specific**: SSH keychain on Linux

### Git
- **Aliases**: `br` (branch), `co` (checkout), `st` (status)
- **Features**: Custom user configuration

## 📋 Requirements

- GNU Stow (for dotfile management)
- Python 3 (for VS Code configuration management)
- Git
- Zsh (optional, but recommended)

## 💡 Usage Tips

- The deployment script automatically handles both Stow and VS Code configurations
- VS Code configurations support base + variant-specific overrides
- All configurations are designed to be cross-platform compatible
- Use the management scripts to keep configurations in sync



# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf)

source $ZSH/oh-my-zsh.sh

# Git prompt with detailed status (matches Claude Code statusline)
_git_prompt_status() {
    git rev-parse --git-dir >/dev/null 2>&1 || return

    local branch=$(git branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch="detached"

    local staged=$(GIT_OPTIONAL_LOCKS=0 git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    local unstaged=$(GIT_OPTIONAL_LOCKS=0 git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    local untracked=$(GIT_OPTIONAL_LOCKS=0 git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    local upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    local ahead=0 behind=0
    if [ -n "$upstream" ]; then
        ahead=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
        behind=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
    fi

    local info="%{$fg_bold[blue]%}(%{$fg[red]%}${branch}%{$fg_bold[blue]%})"
    [ "$ahead" -gt 0 ] && info+=" %F{249}↑${ahead}%f"
    [ "$behind" -gt 0 ] && info+=" %F{249}↓${behind}%f"
    [ "$staged" -gt 0 ] && info+=" %F{173}✓${staged}%f"
    [ "$unstaged" -gt 0 ] && info+=" %F{141}✎${unstaged}%f"
    [ "$untracked" -gt 0 ] && info+=" %F{249}+${untracked}%f"

    echo -n " $info%{$reset_color%}"
}

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+='$(_git_prompt_status)'
PROMPT+=' '

# User configuration

# OS Detection Function
detect_os() {
    local uname_out="$(uname -s)"

    case "$uname_out" in
        Darwin*)
            OS_TYPE="macos"
            ;;
        Linux*)
            # Check for WSL using improved detection method
            if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
                OS_TYPE="wsl"
            else
                OS_TYPE="linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS_TYPE="windows"
            ;;
        *)
            OS_TYPE="unknown"
            ;;
    esac

    # Set boolean helpers for easy conditional checking
    IS_MACOS=$([[ "$OS_TYPE" == "macos" ]] && echo true || echo false)
    IS_LINUX=$([[ "$OS_TYPE" == "linux" ]] && echo true || echo false)
    IS_WSL=$([[ "$OS_TYPE" == "wsl" ]] && echo true || echo false)
    IS_WINDOWS=$([[ "$OS_TYPE" == "windows" ]] && echo true || echo false)

    # Export variables for use in subshells
    export OS_TYPE IS_MACOS IS_LINUX IS_WSL IS_WINDOWS
}

# Initialize OS detection
detect_os

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Free C-l for tmux/neovim pane navigation; use C-S-l to clear
bindkey -r '^L'
bindkey '^[[76;6u' clear-screen   # C-S-l via tmux extended-keys (76='L')
bindkey '^[[108;6u' clear-screen  # C-S-l direct from terminal (108='l')

alias vi="nvim"
alias l="eza -l --group-directories-first"
alias ls="eza -x --group-directories-first"
alias lm="eza -l --group-directories-first --sort=modified --reverse"
alias lma="eza -la --group-directories-first --sort=modified --reverse"
alias ll="eza -l --group-directories-first --sort=name"
alias lla="eza -la --group-directories-first --sort=name"
alias lz="eza -lf --sort=size --reverse"
alias lza="eza -laf --sort=size --reverse"
alias suk="security unlock-keychain"
alias ddr="cd ~/Developer/Repos"
alias r="radian"

# add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        # Prepending path in case a system-installed binary needs to be overridden
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac

# fzf config
if command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# Start keychain and add all id_* keys, but only on Linux systems
# NOTE: install keychain:
#   sudo apt install keychain
if [[ "$IS_LINUX" == "true" ]]; then
    if [ -x "$(command -v keychain)" ]; then
        # Find all private keys in .ssh directory that start with id_
        # (excluding .pub files which are the public keys)
        private_keys=$(find $HOME/.ssh -name "id_*" -not -name "*.pub" -type f)

        if [ -n "$private_keys" ]; then
            # Start keychain with all found keys
            eval $(keychain --eval --quiet $private_keys)
        else
            echo "No SSH keys found that match pattern 'id_*'"
        fi
    fi
fi

# Load Homebrew environment only if it exists
if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm (macOS uses ~/Library/pnpm, Linux uses ~/.local/share/pnpm)
if [[ "$IS_MACOS" == "true" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Source local overrides (machine-specific config not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

[ -f "$HOME/.config/broot/launcher/bash/br" ] && source "$HOME/.config/broot/launcher/bash/br"

# bun (macOS: Homebrew handles core binary, Linux: official install script)
export BUN_INSTALL="$HOME/.bun"
if [[ "$IS_MACOS" != "true" ]]; then
    export PATH="$BUN_INSTALL/bin:$PATH"
    [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
else
    # Homebrew provides the bun binary, but bun link installs to ~/.bun/bin
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [[ "$IS_MACOS" != "true" ]]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# if not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# ignore some controlling instructions
HISTIGNORE="[   ]*:&:bg:fg:exit:l:ll:h:rmj:lm:llm:ls:lsa:lsd:ltr:d:m:"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of "ls" and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto '

    alias grep='grep --color=auto '
    alias fgrep='fgrep --color=auto '
    alias egrep='egrep --color=auto '
fi

# Mac OSX: enable color support for "ls"
if [ `uname -s` == 'Darwin' ]; then
    alias ls='ls -G '; # colors are useful. to temporarily disable, use: unalias ls
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


#
# Environment Variables
#

#
# Standard aliases
#

alias m='more ';
alias l='ls -lF ';
alias ll='ls -lAF ';
alias la='ls -a ';
alias lm='l | m ';
alias llm='ll | m '
alias lsd="ls -l | egrep '^d'"; # list only directories
alias ltr='l -tr';       # list in reverse order of creation/modified time
alias g='grep ';
alias md='mkdir ';
alias rd='rmdir ';
alias rm='rm -i ';
alias h='history ';
alias j='jobs ';
alias k9='kill -9';
alias d='dirs -l -p -v ';

alias u='cd ..';
alias uu='cd ../..';
alias uuu='cd ../../..';
alias uuuu='cd ../../../..';
alias u3='cd ../../..';
alias u4='cd ../../../..';
alias u5='cd ../../../../..';


#
# Functions
#

# Custom prompt
function myprompt()
{
    # verbose command prompt off
    set +v

    # color codes
    clr_green="\[\033[32m\]";
    clr_white="\[\033[0m\]";
    clr_blue="\[\033[34m\]";
    clr_lightblue="\[\033[1;34m\]";
    clr_red="\[\033[31m\]";

    # prompt variables / colors
    clr_path=$clr_green;
    clr_bg=$clr_white;
    clr_host=$clr_red;

    # xterm prompt (black text on white background)
    if [[ "$TERM" == xterm* ]]; then	
        clr_user=$clr_blue;
        clr_dir=$clr_blue;

        #PS1="{\$(jobs | wc -l | sed 's/ *//')}$clr_path[\$(pwd)]$clr_bg\n$clr_user\u$clr_bg@$clr_host\h$clr_bg$clr_dir \W $clr_bg$ "
        PS1="$clr_path[\$(pwd)]$clr_bg\n$clr_user\u$clr_bg@$clr_host\h$clr_bg$clr_dir \W $clr_bg$ "

    fi

    # linux prompt (white text on black background)
    if [ "$TERM" == 'linux' ]; then	
        clr_user=$clr_lightblue;
        clr_dir=$clr_lightblue;

        # PS1="$clr_path[\$(pwd)]$clr_bg\n$clr_user\u$clr_bg@$clr_host\h$clr_bg$clr_dir \W $clr_bg$ "
        PS1="$clr_path[\$(pwd)]$clr_bg\n$clr_user\u$clr_bg$clr_bg$clr_dir \W $clr_bg$ "
    fi
    
    if [ "$TERM" == "cygwin" ]; then
    	clr_user=$clr_lightblue;
        clr_dir=$clr_lightblue;

        PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u \[\e[33m\]\w\[\e[0m\]\n\$ "
    fi

    #################################################################
    # bash prompt color codes

    #"\[\033[0;30m\]" # Black 
    #"\[\033[1;30m\]" # Dark Gray 
    #"\[\033[0;31m\]" # Red 
    #"\[\033[1;31m\]" # Light Red 
    #"\[\033[0;32m\]" # Green 
    #"\[\033[1;32m\]" # Light Green 
    #"\[\033[0;33m\]" # Brown 
    #"\[\033[1;33m\]" # Yellow 
    #"\[\033[0;34m\]" # Blue 
    #"\[\033[1;34m\]" # Light Blue 
    #"\[\033[0;35m\]" # Purple 
    #"\[\033[1;35m\]" # Light Purple 
    #"\[\033[0;36m\]" # Cyan 
    #"\[\033[1;36m\]" # Light 
    #"\[\033[0;37m\]" # Light Gray 
    #"\[\033[1;37m\]" # White 
    #"\[\033[0m\]"    # Neutral 

    # Octal listing of colors 
    #Black 0;30  	 Dark Gray 1;30 
    #Blue 0;34   	 Light Blue 1;34 
    #Green 0;32   	 Light Green 1;32 
    #Cyan 0;36   	 Light Cyan 1;36 
    #Red 0;31    	 Light Red 1;31 
    #Purple 0;35     Light Purple 1;35 
    #Brown 0;33      Yellow 1;33 
    #Light Gray 0;37 White 1;37 
    #################################################################
}

# Activate custom prompt
myprompt;

# Automatically execute commands for each prompt
export LASTDIR="/"

function prompt_command {

    # Record new directory on change.
    newdir=`pwd`
    if [ ! "$LASTDIR" = "$newdir" ]; then
        # List directory contents
        ls
    fi

    export LASTDIR=$newdir
}

export PROMPT_COMMAND="prompt_command"

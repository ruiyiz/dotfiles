Ruiyi Zhang's Mac/Linux configuration files

Installation

Add the following line to your `.profile` file if `virtualenvwrapper.sh` is not 
in your PATH.

    export PATH=/usr/local/share/python:/usr/local/bin:$PATH

Add the following lines to `.profile` file.

    # virtualenvwrapper settings
    if [ `id -u` != 0 ]; then
        export VIRTUALENV_USE_DISTRIBUTE=1      # Always use pip/distribute
        export WORKON_HOME=$HOME/.virtualenvs   # Where all virtualenvs will be stored
        source virtualenvwrapper.sh
        export PIP_VIRTUALENV_BASE=$WORKON_HOME
        export PIP_RESPECT_VIRTUALENV=true
    fi



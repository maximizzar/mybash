#!/usr/bin/env bash

# Don't use sudo? change the alias
alias sudo='sudo'

install_global_bashrc=yes
if [[ "$install_global_bashrc" == yes ]]; then
        if [[ -f "/etc/bash.bashrc" ]]; then
                sudo cp "$(pwd)/.bash/etc/rc" "/etc/bash.bashrc"
        fi

        if [[ -f "/etc/bashrc" ]]; then
                sudo cp "$(pwd)/.bash/etc/rc" "/etc/bashrc"
        fi
fi

if [[ -f "$HOME/.bash_profile" ]]; then
        echo "Skipping .bash_profile. It already exists"
else
        ln -s "$(pwd)/.bash/profile" "$HOME"/.bash_profile;
fi

if [ -f "$HOME/.bashrc" ]; then
        echo "Skipping .bashrc. It already exists"
else
        ln -s "$(pwd)/.bash/rc" "$HOME"/.bashrc;
fi

if [ -f "$HOME/.bash_aliases" ]; then
        echo "Skipping .bash_aliases. It already exists"
else
        ln -s "$(pwd)/.bash/aliases" "$HOME"/.bash_aliases;
fi

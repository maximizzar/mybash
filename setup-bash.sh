#!/usr/bin/env bash

# Install bash rc
if [ -f "$HOME/.bashrc" ]; then
        echo "Skipping .bashrc. It already exists"
else
        ln -s "$(pwd)/.bash/rc" "$HOME"/.bashrc;
fi

# Install bash aliases
if [ -f "$HOME/.bash_aliases" ]; then
        echo "Skipping .bash_aliases. It already exists"
else
        ln -s "$(pwd)/.bash/aliases" "$HOME"/.bash_aliases;
fi

# Install nala bash completion
if command -v nala &> /dev/null; then
        if ! [[ -f "$HOME/.bash_completions/nala.sh" ]]; then
                nala --install-completion
        fi
fi

#!/usr/bin/env bash

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

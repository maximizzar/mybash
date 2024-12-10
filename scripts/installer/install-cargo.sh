#!/usr/bin/env bash

if [[ "$UID" -ne 0 ]]; then
    echo "run as root"
fi

# global directory for Cargo binaries
mkdir -p /usr/local/cargo/bin
chown root:root /usr/local/cargo/bin
chmod 755 /usr/local/cargo/bin

export CARGO_HOME="/usr/local/cargo"
export PATH="$CARGO_HOME/bin:$PATH"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

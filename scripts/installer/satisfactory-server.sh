#!/usr/bin/env bash

alias sudo="sudo"

read -p "Enter satisfactory game name. Leave empty to use hostname (uname -n): " SERVICE_NAME

if [ "$SERVICE_NAME" == "" ]; then
		SERVICE_NAME="$(uname -n)"
fi

# Set handy constants
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"
INSTALL_DIR="/opt/$SERVICE_NAME"
GAME_DIR="/opt/$SERVICE_NAME/factory_game"

# Create system user and dirs
sudo useradd --system --shell /bin/bash satisfactory
sudo mkdir -pv "$GAME_DIR"

# Set permissions
sudo chown satisfactory:satisfactory -R "$GAME_DIR"
sudo chmod g+s "$GAME_DIR"

# Create Systemd service
sudo tee "$SERVICE_PATH" <<EOF
[Unit]
Description=Satisfactory game-server (${SERVICE_NAME})

[Service]
ExecStart=
User=satisfactory
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable "$SERVICE_NAME.service"

# Add non-free and non-free-firmware apt repositories
sudo sed -i 's/^deb \(.*\ main\)/deb \1 non-free non-free-firmware/' /etc/apt/sources.list
sudo sed -i 's/^deb-src \(.*\ main\)/deb-src \1 non-free non-free-firmware/' /etc/apt/sources.list

# Install dependencies
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y software-properties-common libsdl2-2.0-0:i386 git

# Install steam-cmd
sudo apt update
sudo apt install -y steamcmd

#sudo -u satisfactory -s steamcmd +force_install_dir "$GAME_DIR" +login anonymous +app_update 1690800 -beta public validate +quit

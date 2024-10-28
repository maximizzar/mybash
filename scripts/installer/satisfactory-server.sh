#!/usr/bin/env bash

alias sudo="sudo"

read -r -p "Enter satisfactory game name. Leave empty to use hostname (uname -n): " SERVICE_NAME

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
Description=Satisfactory dedicated server (${SERVICE_NAME})
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Environment="LD_LIBRARY_PATH=./linux64"
ExecStartPre=/usr/games/steamcmd +force_install_dir ${GAME_DIR} +login anonymous +app_update 1690800 validate +quit
ExecStart=${GAME_DIR}/FactoryServer.sh -ServerQueryPort=15777 -BeaconPort=15000 -Port=7777 -log -unattended -multihome=0.0.0.0
User=satisfactory
Group=satisfactory
StandardOutput=append:/var/log/satisfactory/${SERVICE_NAME}.log
StandardError=append:/var/log/satisfactory/${SERVICE_NAME}.err
Restart=on-failure
WorkingDirectory=${INSTALL_DIR}

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

# Install and configure system to handle logfiles
sudo apt install -y logrotated
sudo mkdir -pv /var/log/satisfactory

sudo tee "/etc/logrotate.d/$SERVICE_NAME" << EOF
/var/log/satisfactory/${SERVICE_NAME}.* {

}
EOF

# Start Service and let it handle the server installation
sudo systemctl start "$SERVICE_NAME.service"

//TODO: finish logrotated setup

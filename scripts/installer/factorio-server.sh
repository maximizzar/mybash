#!/usr/bin/env bash

alias sudo="sudo"

read -pr "Enter factorio game name. Leave empty to use hostname (uname -n)" SERVICE_NAME

if [ "$SERVICE_NAME" == "" ]; then
        SERVICE_NAME="$(uname -n)"
fi

# Set handy constants
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"
GAME_PATH="/opt/$SERVICE_NAME/factorio"
PARENT_DIR="/opt/$SERVICE_NAME"

mkdir -pv "$GAME_PATH"

# Create Systemd service
sudo tee "$SERVICE_PATH" <<EOF
[Unit]
Description=Factorio game-server (${SERVICE_NAME})

[Service]
ExecStart=${GAME_PATH}/bin/x64/factorio --start-server-load-latest --server-settings ${GAME_PATH}/data/server-settings.json
User=factorio
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable "$SERVICE_NAME.service"

# Create world-gen script
sudo tee "$PARENT_DIR/world-gen.sh" > /dev/null <<EOF
sudo systemctl stop ${SERVICE_NAME}.service

if [ -f "${GAME_PATH}/saves/${SERVICE_NAME}.world.zip" ]; then
        rm "${GAME_PATH}/saves/${SERVICE_NAME}.world.zip"
fi

${GAME_PATH}/bin/x64/factorio --create ${GAME_PATH}/saves/${SERVICE_NAME}.world.zip --map-gen-settings ${GAME_PATH}/data/map-gen-settings.json

sudo systemctl start $SERVICE_NAME.service
EOF
sudo chmod +x "$PARENT_DIR/world-gen.sh"

chmod +x update.sh
cp "./update.sh" "$PARENT_DIR"
."$PARENT_DIR"/update.sh

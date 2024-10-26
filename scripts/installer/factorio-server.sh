#!/usr/bin/env bash

alias sudo="sudo"

read -p "Enter factorio game name. Leave empty to use hostname (uname -n): " SERVICE_NAME

if [ "$SERVICE_NAME" == "" ]; then
        SERVICE_NAME="$(uname -n)"
fi

read -p "Enter factorio game version. If you want to use the latest always, just press Enter: " GAME_VERSION

if [ "$GAME_VERSION" == "" ]; then
        GAME_VERSION="latest"
fi

# Set handy constants
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"
INSTALL_DIR="/opt/$SERVICE_NAME"
GAME_DIR="/opt/$SERVICE_NAME/factorio"

# Create system user and dirs
sudo useradd --system --shell /bin/false factorio
sudo mkdir -pv "$GAME_DIR"

# Set permissions
sudo chown factorio:factorio -R "$GAME_DIR"
sudo chmod g+s "$GAME_DIR"

# Create Systemd service
sudo tee "$SERVICE_PATH" <<EOF
[Unit]
Description=Factorio game-server (${SERVICE_NAME})

[Service]
ExecStart=${GAME_DIR}/bin/x64/factorio --start-server-load-latest --server-settings ${GAME_DIR}/data/server-settings.json
User=factorio
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable "$SERVICE_NAME.service"

# Create world-gen script
sudo tee "$INSTALL_DIR/world-gen.sh" > /dev/null <<EOF
sudo systemctl stop ${SERVICE_NAME}.service

if [ -f "${GAME_DIR}/saves/${SERVICE_NAME}.world.zip" ]; then
        rm "${GAME_DIR}/saves/${SERVICE_NAME}.world.zip"
fi

${GAME_DIR}/bin/x64/factorio --create ${GAME_DIR}/saves/${SERVICE_NAME}.world.zip --map-gen-settings ${GAME_DIR}/data/map-gen-settings.json

sudo systemctl start $SERVICE_NAME.service
EOF
sudo chmod +x "$INSTALL_DIR/world-gen.sh"

# Write variables to the config file
{
  echo "SERVICE_NAME=\"$SERVICE_NAME\""
  echo "INSTALL_DIR=\"$INSTALL_DIR\""
  echo "GAME_DIR=\"$GAME_DIR\""
  echo "GAME_VERSION=\"$GAME_VERSION\""
} | sudo tee "$INSTALL_DIR/config"

# Install and execute update script to install the server.
cp "./update.sh" "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1
chmod +x ./update.sh
./update.sh

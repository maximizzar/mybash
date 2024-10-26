#!/bin/bash

# Check if config exists and load it

echo "Load config!"
if ! [ -e "config" ]; then
    echo "No config file found"
    exit 1
fi

source config

echo "SERVICE_NAME: $SERVICE_NAME"
echo "INSTALL_DIR: $INSTALL_DIR"
echo "GAME_DIR: $GAME_DIR"
echo "GAME_VERSION: $GAME_VERSION"

FACTORIO_REMOTE="https://factorio.com/get-download/$GAME_VERSION/headless/linux64"

cd "${INSTALL_DIR}" || exit 1

if [ -e "${GAME_DIR}/bin/x64/factorio" ]; then
    SERVER_OLD_VERSION=$("${GAME_DIR}"/bin/x64/factorio --version | grep -oP 'Version: \K\d+\.\d+\.\d+')
    SERVER_NEW_VERSION=$(wget -S --spider "${FACTORIO_REMOTE}" 2>&1 | grep 'Location' | awk '{print $2}' | grep -oP '(\d+\.\d+\.\d+)' | head -1)

    echo "local version: ${SERVER_OLD_VERSION}"
    echo "remote version: ${SERVER_NEW_VERSION}"

    if [ "${SERVER_OLD_VERSION}" == "${SERVER_NEW_VERSION}" ]; then
            echo "Server is upto Date!"
            echo "If you aren't on latest you need to update the version-number in the config!"
            exit 1;
    fi

    sudo systemctl stop "${SERVICE_NAME}"

    echo "Backup old (local) Server-files"
    tar -cvf "factorio-${SERVER_OLD_VERSION}.tar" factorio
fi

echo "Install new (remote) Server-files"
wget --no-verbose -O factorio.tar.xz "${FACTORIO_REMOTE}"
tar --overwrite -xvf factorio.tar.xz
chmod +x factorio/bin/x64/factorio

rm factorio.tar.xz

# Deal with the json config example files
if [ -e "${GAME_DIR}/data/map-gen-settings.json" ]; then
    rm "${GAME_DIR}/data/map-gen-settings.example.json"
else
    mv "${GAME_DIR}/data/map-gen-settings.example.json" "${GAME_DIR}/data/map-gen-settings.json"
    nano "${GAME_DIR}/data/map-gen-settings.json"
fi

if [ -e "${GAME_DIR}/data/map-settings.json" ]; then
    rm "${GAME_DIR}/data/map-settings.example.json"
else
    mv "${GAME_DIR}/data/map-settings.example.json" "${GAME_DIR}/data/map-settings.json"
    nano "${GAME_DIR}/data/map-settings.json"
fi

if [ -e "${GAME_DIR}/data/server-settings.json" ]; then
    rm "${GAME_DIR}/data/server-settings.example.json"
else
    mv "${GAME_DIR}/data/server-settings.example.json" "${GAME_DIR}/data/server-settings.json"
    nano "${GAME_DIR}/data/server-settings.json"
fi

if [ -e "${GAME_DIR}/data/server-whitelist.json" ]; then
    rm "${GAME_DIR}/data/server-whitelist.example.json"
else
    mv "${GAME_DIR}/data/server-whitelist.example.json" "${GAME_DIR}/data/server-whitelist.json"
    nano "${GAME_DIR}/data/server-whitelist.json"
fi

# create world if no saves are available
if ! [ -e "$GAME_DIR/saves" ]; then
    sudo mkdir "$GAME_DIR"/saves
    sudo ./world-gen.sh
fi

# Set permissions
sudo chown factorio:factorio -R "$GAME_DIR"

echo "Start Server"
sudo systemctl start "${SERVICE_NAME}"
exit 0

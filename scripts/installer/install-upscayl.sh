#!/usr/bin/env bash

# Constances
INSTALL_DIR="/opt/upscayl"
user_ids="$(id -u):$(id -g)"

# Functions
install_upscayl_nncc() {
    (
        api="https://api.github.com/repos/upscayl/upscayl-ncnn/releases/latest"
        tag_name="$(curl --silent "$api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
        upscayl_nncc_url="https://github.com/upscayl/upscayl-ncnn/releases/tag/$tag_name/upscayl-bin-$tag_name-linux.zip"

        cd /tmp || exit 1
        wget "$upscayl_nncc_url"
        unzip "upscayl-bin-$tag_name-linux.zip"
        sudo chmod +x "upscayl-bin-$tag_name-linux/upscayl-bin"
        sudo mv "upscayl-bin-$tag_name-linux/upscayl-bin" "/usr/local/bin/upscayl-nncc"
    )
}

install_default_models() {
    (
        if [[ -d "$INSTALL_DIR/custom-models" ]]; then
            cd "$INSTALL_DIR/custom-models" || exit 1;
            sudo git pull;
        else
            cd "$INSTALL_DIR" || exit 1;
            sudo git clone https://github.com/upscayl/custom-models.git
            sudo ln -s "$(pwd)/custom-models/models" "$(pwd)/models/*"
        fi
    )
    
    # Create symlinks
    for file in "$INSTALL_DIR"/custom-models/models/*; do
        base_name=$(basename "$file")
        target="$INSTALL_DIR/models/$base_name"

        # Check if the target does not already exist
        if [ ! -e "$target" ]; then
            echo "Creating symlink for $base_name"
            sudo ln -s "$file" "$target"
        else
            echo "Skipping $base_name: Target already exists"
        fi
    done
}

#
# Main
#

# Create dirs
sudo mkdir -pv "$INSTALL_DIR/models"
sudo mkdir -pv "$INSTALL_DIR/frames/input"
sudo mkdir -pv "$INSTALL_DIR/frames/output"
sudo mkdir -pv "$INSTALL_DIR/video/input"
sudo mkdir -pv "$INSTALL_DIR/video/output"

# Set permissions
sudo chmod 777 -R "$INSTALL_DIR"
sudo chown -R "$user_ids" "$INSTALL_DIR/frames"
sudo chown -R "$user_ids" "$INSTALL_DIR/video"

echo "Install dependencies!"
if ! sudo apt-get update -q > /dev/null 2>&1; then
    echo "Failed to update your System!";
    exit 1;
else
    sudo apt install -y curl ffmpeg git libvulkan1 libgomp1 zip > /dev/null 2>&1
fi

if [[ -f "/usr/local/bin/upscayl-nncc" ]]; then
    echo "Upscayl NNCC is already installed!";
else
    install_upscayl_nncc;
fi

install_default_models;


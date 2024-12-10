#!/usr/bin/env bash

# Install dependencies
if ! { apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
    echo "Failed to update your System!";
    exit 1;
else
    sudo apt install -y ca-certificates curl gnupg gpg
fi

# Remove current container engine installations
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    sudo apt-get remove $pkg;
done

# Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
if ! [ -f "/etc/apt/keyrings/docker.gpg" ]; then
        echo "Failed to download docker gpg key!"
        exit 1
else
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Use the following command to set up the repository
echo \ "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index
if ! { apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
    echo "Installed docker repository correctly.";

    # Install Docker Engine, containerd, and Docker Compose
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Failed to correctly install docker repository!";
    exit 1;
    fi

# Verify that the Docker Engine installation is successful by running the hello-world image
docker run --name hello-world-test hello-world

# Check the exit status
if [ $? -eq 0 ]; then
    echo "Docker is successfully installed."
    docker rm hello-world-test
    docker rmi hello-world
else
    echo "Docker installation failed!"
    docker rm hello-world-test
    # Don't delete hello-world-image so user can test without re-downloading
fi

#!/usr/bin/env bash

SERVICE_FILE="/etc/systemd/system/mybash-autoupdate.service"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Write the systemd service file
cat <<EOL > $SERVICE_FILE
[Unit]
Description=mybash autoupdater \$HOME/mybash
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'cd "\$HOME/mybash" && git pull'
User=%u
Environment="HOME=%h"

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to apply changes
systemctl daemon-reload

# Enable the service
systemctl enable mybash-autoupdate.service

# Provide feedback to the user
echo "Service installed and enabled. You can start it with: sudo systemctl start mybash-autoupdate.service"

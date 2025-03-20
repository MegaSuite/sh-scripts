#!/bin/bash

# Create and navigate to the Realm directory
apt install sudo curl -y
mkdir -p realm && cd realm

# Fetch the latest version number
VERSION=$(curl -s https://api.github.com/repos/zhboner/realm/releases/latest | grep 'tag_name' | cut -d\" -f4)

# Download the appropriate tar.gz file
curl -LJO "https://github.com/zhboner/realm/releases/download/${VERSION}/realm-x86_64-unknown-linux-gnu.tar.gz"

# Extract and set permissions
tar -xvf realm-x86_64-unknown-linux-gnu.tar.gz
chmod +x realm
rm -f realm-x86_64-unknown-linux-gnu.tar.gz

# Create and populate config.toml
cat << EOL > config.toml
[network]
no_tcp = false
use_udp = true
EOL

# Ask user for listening port
read -p "Enter the listening port: " LISTEN_PORT

# Ask user for remote IP/URL and port
read -p "Enter the remote IP or URL: " REMOTE_IP
read -p "Enter the remote port: " REMOTE_PORT

# Write endpoints configuration
cat << EOL >> config.toml

[[endpoints]]
listen = "[::]:${LISTEN_PORT}"
remote = "${REMOTE_IP}:${REMOTE_PORT}"
EOL

# Create and write to the realm.service systemd service file
cat << EOL | sudo tee /etc/systemd/system/realm.service > /dev/null
[Unit]
Description=realm
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
DynamicUser=true
ExecStart=$(pwd)/realm -c $(pwd)/config.toml

[Install]
WantedBy=multi-user.target
EOL

# Start the service
sudo systemctl daemon-reload
sudo systemctl enable realm
echo "Waiting for 10 seconds before starting the realm service..."
sleep 10
sudo systemctl start realm
sleep 5
sudo systemctl status realm

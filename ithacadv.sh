#!/bin/bash


# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m' # Reset color

# Print "CRYPTO CONSOLE" with vibrant colors
echo -e "${CYAN}=============================="
echo -e "       ${GREEN}CRYPTO CONSOLE${CYAN}        "
echo -e "${CYAN}==============================${RESET}"

# Your script code goes here


# Ask the user to follow on Twitter
echo "Please follow us at: https://x.com/cryptoconsol"
read -p "Have you followed us? (yes/no): " followed

if [[ "$followed" != "yes" ]]; then
    echo "Please follow us and run the script again."
    exit 1
fi

echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y

echo "Installing Git..."
sudo apt install -y git

echo "Installing Rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh -s -- -y

echo "Configuring Rust path..."
source "$HOME/.cargo/env"

echo "Checking Rust version..."
rustup --version

echo "Cloning Odyssey repository..."
git clone https://github.com/ithacaxyz/odyssey.git
cd odyssey

echo "Installing the Odyssey node..."
cargo install --path bin/odyssey

echo "Creating keys folder..."
mkdir -p keys

echo "Generating jwt.hex file..."
openssl rand -hex 32 > "$HOME/odyssey/keys/jwt.hex"
echo "Secret key saved in jwt.hex."

echo "Creating Ithaca service file..."
sudo tee /etc/systemd/system/ithaca.service > /dev/null <<EOF
[Unit]
Description=Ithaca Devnet Node
After=network.target

[Service]
User=$USER
WorkingDirectory=/root/odyssey
ExecStart=/root/.cargo/bin/odyssey node --chain etc/odyssey-genesis.json --rollup.sequencer-http https://odyssey.ithaca.xyz --http --http.port 8548 --ws --ws.port 8547 --authrpc.port 9551 --port 30304 --authrpc.jwtsecret /root/odyssey/keys/jwt.hex
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading daemon and enabling Ithaca service..."
sudo systemctl daemon-reload
sudo systemctl enable ithaca

echo "Starting Ithaca node..."
sudo systemctl start ithaca

echo "Checking Ithaca node status..."
sudo systemctl status ithaca

echo "Tailing Ithaca logs..."
journalctl -u ithaca -f -o cat


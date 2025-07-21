#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please start this scrip with root user or sudo"
  exit 1
fi

echo "System update running"
apt update && apt upgrade -y

if ! command -v curl &> /dev/null; then
  echo "curl will be installed"
  apt install curl -y
fi

echo "Install docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

if ! docker compose version > /dev/null 2>&1; then
  echo "Docker compose installation failed"
  exit 1
fi

echo "Create folders"
mkdir -p backup mysql invoices
chmod 777 backup mysql invoices

echo "Download TeslaLogger"
wget https://raw.githubusercontent.com/bassmaster187/TeslaLogger/refs/heads/NET8/.env -O .env
wget https://raw.githubusercontent.com/bassmaster187/TeslaLogger/refs/heads/NET8/docker-compose.yml -O docker-compose.yml

echo "Download Docker Containers"
docker compose pull

SERVER_IP="$(ip addr | grep -A8 -m1 MULTICAST | grep -m1 inet | cut -d' ' -f6 | cut -d'/' -f1)"

echo "Setup finished"

echo "Please adjust some settings in your .env file like Timezone (default is MEZ / Berlin) if necessary"

echo "run 'docker compose up -d' to start TeslaLogger"

echo "wait 1-2 minutes and open in browser http://$SERVER_IP:8888/admin"

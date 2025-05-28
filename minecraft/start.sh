#!/bin/bash
cd "$(dirname "$0")"

# Les config fra server.properties
SERVER_NAME=$(grep -i '^server-name=' server.properties | cut -d= -f2)
PORT=$(grep -i '^server-port=' server.properties | cut -d= -f2)

# Hent IP-adresse (første i lista)
#IP=$(hostname -I | awk '{print $1}')
IP=$(hostname -I | tr ' ' '\n' | grep -E '^192\.168\.|^10\.' | head -n 1)


echo "🟢 Starting Minecraft Bedrock server..."
echo "🌍 Server name : $SERVER_NAME"
echo "🔌 Listening on: $IP:$PORT"
echo ""

# Start serveren
LD_LIBRARY_PATH=. ./bedrock_server

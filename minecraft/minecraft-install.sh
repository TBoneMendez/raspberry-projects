#!/bin/bash
echo "📦 Installing dependencies for Minecraft Bedrock server..."
cd "$(dirname "$0")"

echo "🌐 Fetching latest Bedrock server URL..."
ZIP_URL=$(curl -s https://www.minecraft.net/en-us/download/server/bedrock | grep -oP 'https://minecraft\.azureedge\.net/bin-linux/bedrock-server-.*?\.zip' | head -n 1)

if [[ -z "$ZIP_URL" ]]; then
  echo "❌ Failed to find download link. Aborting."
  exit 1
fi

echo "⬇️ Downloading: $ZIP_URL"
curl -O "$ZIP_URL"

echo "📦 Extracting..."
unzip -o bedrock-server-*.zip

echo "🔐 Setting executable permissions..."
chmod +x bedrock_server start.sh

echo "✅ Minecraft Bedrock server installation complete."

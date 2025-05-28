#!/bin/bash

echo "📦 Select which project to install:"
echo "1) homey-appletv"
echo "2) minecraft-bedrock"
echo "3) both"
read -p "Your choice (1/2/3): " choice

case $choice in
  1)
    echo "📦 Running homey-appletv install..."
    bash homey-appletv/install.sh
    ;;
  2)
    echo "📦 Running minecraft-bedrock install..."
    bash minecraft-bedrock/install.sh
    ;;
  3)
    echo "📦 Installing all projects..."
    bash homey-appletv/install.sh
    bash minecraft-bedrock/install.sh
    ;;
  *)
    echo "❌ Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""
echo "🚀 You can now start services with:"
echo "    pm2 start pm2.config.js"

#!/bin/bash
cd "$(dirname "$0")"

VERSION="1.21.83.1"
ZIP_FILE="bedrock-server-$VERSION.zip"

if [ ! -f "$ZIP_FILE" ]; then
  echo "❌ $ZIP_FILE not found. Please download it manually and place it here:"
  echo "   https://www.minecraft.net/en-us/download/server/bedrock"
  exit 1
fi

echo "📦 Extracting $ZIP_FILE..."

# Midlertidig mappe
TEMP_DIR="temp_extracted_bedrock"
mkdir -p "$TEMP_DIR"

unzip -o "$ZIP_FILE" -d "$TEMP_DIR"

# Kopier alt unntatt konfigurasjonsfiler
for file in "$TEMP_DIR"/*; do
  filename=$(basename "$file")

  case "$filename" in
    server.properties|permissions.json|allowlist.json)
      echo "⚠️ Skipping preserved config file: $filename"
      ;;
    *)
      cp -r "$file" .
      ;;
  esac
done

rm -rf "$TEMP_DIR"

echo "🔐 Setting executable permissions..."
chmod +x bedrock_server start.sh

echo "✅ Minecraft Bedrock server $VERSION installed successfully. Config files preserved."

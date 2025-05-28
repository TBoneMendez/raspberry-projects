cd "$(dirname "$0")"
VERSION="1.21.83.1"
ZIP_FILE="bedrock-server-$VERSION.zip"

if [ ! -f "$ZIP_FILE" ]; then
  echo "❌ $ZIP_FILE not found. Please download it manually and place it here:"
  echo "   https://www.minecraft.net/en-us/download/server/bedrock"
  exit 1
fi

echo "📦 Extracting $ZIP_FILE..."
unzip -o "$ZIP_FILE"

#!/bin/bash
echo "🔄 Gjenoppretter Jellyfin-konfig fra backup..."

mkdir -p config
cp -v config-backup/* config/

echo "✅ Konfig kopiert. Klar til å starte Jellyfin."

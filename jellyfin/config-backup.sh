#!/bin/bash
echo "📦 Lager backup av Jellyfin-konfigurasjon..."

# Sørg for at backup-mappen finnes
mkdir -p config-backup

# Kopier ønskede filer (legg til flere om ønskelig)
cp -v config/config/system.xml config-backup/
cp -v config/config/network.xml config-backup/
cp -v config/config/encoding.xml config-backup/
cp -v config/config/logging.default.json config-backup/
cp -v config/config/displaypreferences.db config-backup/

echo "✅ Konfigurasjon er kopiert til config-backup/"

#!/bin/bash

set -e

# Chargement des variables depuis .env
if [ -f ".env" ]; then
  echo "🔧 Chargement des variables depuis .env..."
  source .env
fi

APP_IDENTIFIER=${APP_IDENTIFIER:-com.geoffreypetain.voczilla.voczilla}
USERNAME=${FASTLANE_USER:-geoffrey.petain@gmail.com}
TEAM_ID=${TEAM_ID:-124128909}
PLATFORM="ios"
APP_VERSION=${APP_VERSION:-"9.1.4"} # 👈 ici tu spécifies la version à analyser

SOURCE_DIR="fastlane/screenshots"
TEMP_BACKUP_DIR="fastlane/screenshots_backup"
SERVER_DIR="fastlane/screenshots_server"

# Sauvegarde des screenshots locaux
if [ -d "$SOURCE_DIR" ]; then
  echo "📦 Sauvegarde temporaire de $SOURCE_DIR → $TEMP_BACKUP_DIR"
  mv "$SOURCE_DIR" "$TEMP_BACKUP_DIR"
fi

# Téléchargement depuis App Store Connect
echo "⬇️ Téléchargement des screenshots depuis App Store Connect (version $APP_VERSION)..."
FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1 \
fastlane deliver download_screenshots \
  --app_identifier "$APP_IDENTIFIER" \
  --username "$USERNAME" \
  --team_id "$TEAM_ID" \
  --platform "$PLATFORM" \
  --app_version "$APP_VERSION"

# Déplacement dans un dossier propre
echo "📁 Déplacement vers $SERVER_DIR"
rm -rf "$SERVER_DIR"
mv "$SOURCE_DIR" "$SERVER_DIR"

# Restauration des screenshots locaux
if [ -d "$TEMP_BACKUP_DIR" ]; then
  echo "♻️ Restauration des screenshots locaux depuis $TEMP_BACKUP_DIR"
  mv "$TEMP_BACKUP_DIR" "$SOURCE_DIR"
fi

# Analyse des screenshots téléchargés
echo ""
echo "📂 Résumé des screenshots présents sur App Store Connect (version $APP_VERSION) :"
echo ""

LANG_COUNT=0
TOTAL_SHOTS=0

for LANG_DIR in "$SERVER_DIR"/*; do
  [ -d "$LANG_DIR" ] || continue
  LANG=$(basename "$LANG_DIR")
  echo "🌍 Langue : $LANG"
  LANG_TOTAL=0

  for DEVICE_DIR in "$LANG_DIR"/*; do
    [ -d "$DEVICE_DIR" ] || continue
    DEVICE=$(basename "$DEVICE_DIR")
    COUNT=$(find "$DEVICE_DIR" -maxdepth 1 -name "*.png" | wc -l)
    LANG_TOTAL=$((LANG_TOTAL + COUNT))
    TOTAL_SHOTS=$((TOTAL_SHOTS + COUNT))
    printf "  📱 Appareil : %-20s — %2d screenshot(s)\n" "$DEVICE" "$COUNT"
  done

  echo "  ➤ Total : $LANG_TOTAL screenshot(s)"
  echo ""
  LANG_COUNT=$((LANG_COUNT + 1))
done

echo "📊 Résumé global :"
echo "🌐 Langues            : $LANG_COUNT"
echo "📸 Screenshots total  : $TOTAL_SHOTS"
echo ""
echo "📁 Dossier téléchargé : $SERVER_DIR"

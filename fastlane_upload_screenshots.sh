#!/bin/bash

set -e

# Chargement du .env si présent (optionnel mais recommandé)
if [ -f ".env" ]; then
  echo "Chargement des variables depuis .env..."
  source .env
fi

echo "🧹 Nettoyage de ./Preview.html si présent..."
rm -f ./Preview.html

echo "📂 Chemins des screenshots iOS : fastlane/screenshots/ios"

echo "📁 Copie des screenshots iOS vers fastlane/screenshots temporaire..."
SCREENSHOT_DIR="fastlane/screenshots"


echo "🚀 Upload des screenshots vers App Store Connect..."
FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1 \
fastlane deliver \
  --username "$FASTLANE_USER" \
  --app_identifier com.geoffreypetain.voczilla.voczilla \
  --team_id 124128909 \
  --platform ios \
  --screenshots_path "$SCREENSHOT_DIR" \
  --skip_binary_upload true \
  --skip_metadata true \
  --overwrite_screenshots true \
  --ignore_language_directory_validation true \
  --force

echo "✅ Upload des screenshots terminé avec succès."



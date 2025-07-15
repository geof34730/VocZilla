#!/bin/bash

set -e

# Chargement des variables depuis .env
if [ -f ".env" ]; then
  echo "🔧 Chargement des variables depuis .env..."
  source .env
fi

# Fichier JSON contenant la version
DEPLOY_INFO_FILE="deploy-info.json"

# Extraire les infos depuis le JSON
VERSION_NAME=$(jq -r '.lastVersionName' "$DEPLOY_INFO_FILE")

# Vérification basique
if [ -z "$VERSION_NAME" ] || [ "$VERSION_NAME" == "null" ]; then
  echo "❌ Version introuvable dans $DEPLOY_INFO_FILE"
  exit 1
fi
# Définition des variables

echo $VERSION_NAME

PLATFORM="ios"

SCREENSHOT_DIR="./fastlane/screenshots/ios"

FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1 \
fastlane deliver \
  --platform "$PLATFORM" \
  --screenshots_path "$SCREENSHOT_DIR" \
  --skip_binary_upload true \
  --skip_metadata true \
  --overwrite_screenshots false \
  --run_precheck_before_submit false \
  --ignore_language_directory_validation true \
  --app_version "$VERSION_NAME",
  --force \
  --verbose


echo "✅ Upload terminé avec succès."

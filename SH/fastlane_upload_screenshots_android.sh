#!/bin/bash

set -e

# 🔧 Chargement des variables depuis .env
if [ -f ".env" ]; then
  echo "🔧 Chargement des variables depuis .env..."
  source .env
fi

# ✅ Vérification de la présence de jq
if ! command -v jq &> /dev/null; then
  echo "❌ jq est requis mais introuvable. Installez-le avec :"
  echo "   brew install jq       # macOS"
  echo "   sudo apt install jq   # Linux (Debian/Ubuntu)"
  exit 1
fi

# 📁 Fichier contenant les versions
DEPLOY_INFO_FILE="deploy-info.json"

# 🔍 Extraction de la version
VERSION_NAME=$(jq -r '.lastVersionName' "$DEPLOY_INFO_FILE")

if [ -z "$VERSION_NAME" ] || [ "$VERSION_NAME" == "null" ]; then
  echo "❌ Version introuvable dans $DEPLOY_INFO_FILE"
  exit 1
fi

echo "📦 Version Android détectée : $VERSION_NAME"

# 🔐 Fichier clé du service
SERVICE_ACCOUNT_PATH="./voczilla-play.json"

if [ ! -f "$SERVICE_ACCOUNT_PATH" ]; then
  echo "❌ Erreur : Fichier de clé introuvable à $SERVICE_ACCOUNT_PATH"
  exit 1
fi

# 🚀 Lancement de fastlane (avec screenshots depuis fastlane/metadata)
fastlane supply \
  --skip_upload_apk true \
  --skip_upload_aab true \
  --skip_upload_metadata false \
  --track "production" \
  --json_key "$SERVICE_ACCOUNT_PATH" \
  --package_name "$ENV_FASTLANE_APP_ID" \
  --version_name "$VERSION_NAME" \
  --skip_upload_changelogs true \
  --verbose

echo "✅ Upload Android terminé avec succès."

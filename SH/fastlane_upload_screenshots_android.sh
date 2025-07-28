#!/bin/bash

# Améliore la robustesse du script :
# -e: Quitte immédiatement si une commande échoue.
# -u: Quitte si une variable non définie est utilisée.
# -o pipefail: Fait échouer une série de commandes (pipe) si l'une d'elles échoue.
set -euo pipefail

# --- Fonction pour afficher des logs clairs ---
log() {
  echo "➡️  $1"
}

# --- Définition des constantes ---
log "Configuration des variables..."
DEPLOY_INFO_FILE="deploy-info.json"
SERVICE_ACCOUNT_PATH="./voczilla-play.json"
METADATA_PATH="./fastlane/metadata/android"

# 🔧 Chargement des variables depuis .env
if [ -f ".env" ]; then
  log "Chargement des variables depuis .env..."
  # 'source' peut échouer si le fichier est vide, on le protège
  # shellcheck disable=SC1091
  source .env || true
fi

# ✅ Vérification de la présence de jq
if ! command -v jq &> /dev/null; then
  echo "❌ Erreur : L'outil 'jq' est requis mais introuvable. Veuillez l'installer :" >&2
  echo "   brew install jq       # Pour macOS" >&2
  echo "   sudo apt install jq   # Pour Linux (Debian/Ubuntu)" >&2
  exit 1
fi

# 🔍 Extraction de la version
if ! jq -e '.lastVersionName' "$DEPLOY_INFO_FILE" > /dev/null; then
    echo "❌ Erreur : La clé 'lastVersionName' est introuvable dans $DEPLOY_INFO_FILE" >&2
    exit 1
fi
VERSION_NAME=$(jq -r '.lastVersionName' "$DEPLOY_INFO_FILE")

if [ -z "$VERSION_NAME" ] || [ "$VERSION_NAME" == "null" ]; then
  echo "❌ Erreur : La version extraite de $DEPLOY_INFO_FILE est vide." >&2
  exit 1
fi
log "📦 Version Android détectée : $VERSION_NAME"

# 🔐 Vérification du fichier clé du service
if [ ! -f "$SERVICE_ACCOUNT_PATH" ]; then
  echo "❌ Erreur : Fichier de clé de service introuvable à l'emplacement : $SERVICE_ACCOUNT_PATH" >&2
  exit 1
fi

# ✨ NOUVEAU : Lister les langues à traiter pour faciliter le débogage ✨
log "Langues détectées dans '$METADATA_PATH' qui seront traitées :"
for lang_dir in "$METADATA_PATH"/*/; do
    if [ -d "${lang_dir}" ]; then
        # Extrait le nom du dossier (le code de la langue)
        lang_code=$(basename "${lang_dir}")
        echo "  - ${lang_code}"
    fi
done
log "Assurez-vous que toutes ces langues sont bien activées dans votre Google Play Console."

# 🚀 Lancement de fastlane
log "Lancement de la mise en ligne des métadonnées sur le Play Store..."
fastlane supply \
  --package_name "$ENV_FASTLANE_APP_ID" \
  --track "production" \
  --json_key "$SERVICE_ACCOUNT_PATH" \
  --metadata_path "$METADATA_PATH" \
  --skip_upload_apk true \
  --skip_upload_aab true \
  --skip_upload_changelogs true \
  --skip_upload_metadata false \
  --verbose

log "✅ Upload Android terminé avec succès."

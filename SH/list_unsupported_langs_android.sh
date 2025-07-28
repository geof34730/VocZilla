#!/bin/bash
set -euo pipefail

log() {
  echo "➡️  $1"
}

# --- Constants and Config ---
METADATA_PATH="./fastlane/metadata/android"
SERVICE_ACCOUNT_PATH="./voczilla-play.json"
PROJECT_ROOT=$(pwd)
TMP_DIR_NAME="tmp_remote_metadata_check" # Use a unique name
TMP_METADATA_PATH="./$TMP_DIR_NAME/fastlane/metadata/android"
ERROR_LOG_FILE="$TMP_DIR_NAME/error.log"

# --- Load .env ---
if [ -f ".env" ]; then
  # shellcheck disable=SC1091
  source .env || true
fi
if [ -z "${ENV_FASTLANE_APP_ID:-}" ]; then
    echo "❌ Erreur : La variable ENV_FASTLANE_APP_ID n'est pas définie dans votre fichier .env." >&2
    exit 1
fi

# --- Main Script ---
log "Lancement de la vérification de synchronisation des langues..."

# --- TEST 1: Find local-only languages ---
log "1/2 : Recherche des langues EN TROP localement (non activées sur le Play Store)..."
# Use `validate_only` for a clean, fast check without attempting an upload.
local_only_langs=$(fastlane supply \
  --package_name "$ENV_FASTLANE_APP_ID" \
  --json_key "$PROJECT_ROOT/$SERVICE_ACCOUNT_PATH" \
  --metadata_path "$METADATA_PATH" \
  --validate_only true \
  --skip_upload_apk true \
  --skip_upload_aab true \
  2>&1 | sed -n 's/.* \([a-z]\{2\}\(-\([A-Z]\{2\}\)\)\{0,1\}\) - Invalid request.*/\1/p' | sort -u || true)

# --- TEST 2: Find remote-only languages ---
log "2/2 : Recherche des langues MANQUANTES localement (présentes sur le Play Store)..."
log "(Cette étape télécharge la configuration distante...)"

# Cleanup trap for the temporary directory
trap 'rm -rf -- "$TMP_DIR_NAME"' EXIT
mkdir -p "$TMP_DIR_NAME"

# Download metadata, capturing errors to a log file for better debugging.
download_success=true
fastlane supply \
  --package_name "$ENV_FASTLANE_APP_ID" \
  --json_key "$PROJECT_ROOT/$SERVICE_ACCOUNT_PATH" \
  --download_metadata \
  --metadata_path "$TMP_METADATA_PATH" > "$ERROR_LOG_FILE" 2>&1 || download_success=false

remote_only_langs=""
if [ "$download_success" = true ]; then
    remote_langs=""
    if [ -d "$TMP_METADATA_PATH" ]; then
        remote_langs=$(ls -1 "$TMP_METADATA_PATH")
    fi
    local_langs=$(ls -1 "$METADATA_PATH")
    remote_only_langs=$(comm -13 <(echo "$local_langs" | sort) <(echo "$remote_langs" | sort))
else
    log "⚠️  Le téléchargement des métadonnées distantes a échoué. Le test des langues manquantes est ignoré."
    log "   Consultez le fichier '$ERROR_LOG_FILE' pour les détails de l'erreur."
fi

# --- Final Report ---
echo
log "--- RAPPORT DE SYNCHRONISATION ---"
has_issues=false

if [ -n "$local_only_langs" ]; then
    log "❌ Langues EN TROP localement (codes régionaux à renommer) :"
    echo "$local_only_langs"
    has_issues=true
    echo
fi

if [ -n "$remote_only_langs" ]; then
    log "❌ Langues MANQUANTES localement (codes de base attendus) :"
    echo "$remote_only_langs"
    has_issues=true
    echo
fi

if [ "$has_issues" = false ]; then
    # Check if the download failed, which is also an issue
    if [ "$download_success" = true ]; then
        log "✅ Félicitations ! Vos langues sont parfaitement synchronisées."
    else
        log "Veuillez corriger le problème de téléchargement pour terminer la vérification."
    fi
else
    log "------------------------------------"
    log "ACTION REQUISE : Renommez les dossiers locaux pour qu'ils correspondent aux codes de base attendus."
    log "Exemple : mv fastlane/metadata/android/af-ZA fastlane/metadata/android/af"
fi

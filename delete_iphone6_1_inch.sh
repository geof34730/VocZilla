#!/bin/bash

# Chemin de base vers les captures
BASE_DIR="./fastlane/screenshots/ios"

echo "🗑️ Suppression des fichiers 'iphone6_1_inch_*' dans tous les sous-dossiers de $BASE_DIR..."

# Vérifie que le dossier existe
if [ ! -d "$BASE_DIR" ]; then
  echo "❌ Dossier introuvable : $BASE_DIR"
  exit 1
fi

# Parcourt tous les sous-dossiers (langues)
for lang_dir in "$BASE_DIR"/*; do
  if [ -d "$lang_dir" ]; then
    echo "🔍 Traitement du dossier : $lang_dir"
    # Supprime les fichiers qui correspondent au motif
    find "$lang_dir" -type f -name "iphone6_1_inch_*.png" -exec rm {} \;
  fi
done

echo "✅ Suppression terminée."


#!/bin/bash

# Ce script trouve toutes les images featureGraphic dans les métadonnées Android,
# les copie dans un répertoire central et les renomme avec le préfixe de leur locale.

# --- Configuration ---
# Dossier source où se trouvent les métadonnées Android.
SOURCE_DIR="fastlane/metadata/android"
# Dossier de destination pour les images collectées.
# (Vous pouvez le changer pour "/Volumes/data/all_featureGraphic" si besoin)
DEST_DIR="/Volumes/data/all_featureGraphic"

# --- Script principal ---

echo "🚀 Lancement du script de collecte des Feature Graphics..."

# 1. Vérifier si le dossier source existe
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ Erreur : Le dossier source '$SOURCE_DIR' n'a pas été trouvé."
  exit 1
fi

# 2. Créer le dossier de destination s'il n'existe pas
echo "📁 Vérification du dossier de destination : $DEST_DIR"
mkdir -p "$DEST_DIR"

# 3. Trouver, copier et renommer les images.
echo "🔎 Recherche et copie des images..."

# Itère sur chaque dossier de langue dans le répertoire source
for locale_dir in "$SOURCE_DIR"/*; do
  # Vérifie si c'est bien un dossier
  if [ -d "$locale_dir" ]; then
    locale=$(basename "$locale_dir")
    image_dir="$locale_dir/images"

    # Le "feature graphic" est directement dans 'images', pas dans un sous-dossier.
    # On cherche un unique fichier .png dans ce dossier.
    # `find` est utilisé pour trouver le fichier de manière robuste.
    # `-maxdepth 1` empêche de chercher dans les sous-dossiers (comme 'phoneScreenshots').
    # `head -n 1` prend le premier résultat s'il y en a plusieurs.
    image_path=$(find "$image_dir" -maxdepth 1 -type f -name "*.png" 2>/dev/null | head -n 1)

    if [ -n "$image_path" ]; then
      # Un fichier image a été trouvé
      new_filename="${locale}_featureGraphic.png"
      cp "$image_path" "$DEST_DIR/$new_filename"
      echo "  ✅ Copié : $image_path → $new_filename"
    fi
  fi
done

echo "🎉 Opération terminée ! Toutes les images ont été collectées dans $DEST_DIR"

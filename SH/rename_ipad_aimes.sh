#!/bin/bash

# Répertoire racine
BASE_DIR="../fastlane/metadata/ios"

# Nouveau préfixe
NEW_PREFIX="iPad Pro (12.9-inch) (3rd generation)"

# Rechercher tous les fichiers ipad_13_inch_*.png
find "$BASE_DIR" -type f -name "ipad_13_inch_*.png" | while read -r file; do
  dir=$(dirname "$file")
  filename=$(basename "$file")

  # Extraire le numéro du screenshot (par exemple 01 dans ipad_13_inch_01.png)
  if [[ "$filename" =~ ipad_13_inch_([0-9]+)\.png ]]; then
    index="${BASH_REMATCH[1]}"
    new_name="${NEW_PREFIX}_${index}.png"
    new_path="${dir}/${new_name}"

    echo "Renommage : $file → $new_path"
    mv "$file" "$new_path"
  fi
done

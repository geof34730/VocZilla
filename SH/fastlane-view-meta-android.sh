#!/bin/bash

echo "🧹 Suppression de ./Preview.html si présent..."
rm -f ./Preview.html

SCREENSHOTS_DIR="fastlane/metadata/android"
METADATA_DIR="fastlane/metadata/android"

echo "📄 Génération de Preview.html depuis $SCREENSHOTS_DIR et $METADATA_DIR..."
export FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1

# Pour Android, on utilise supply (et non deliver)
fastlane supply generate_summary \
  --screenshots_path "$SCREENSHOTS_DIR" \
  --metadata_path "$METADATA_DIR" \
  --json ./fastlane/metadata/android/metadata.json \
  --output_path ./Preview.html \
  --package_name com.geoffreypetain.voczilla.voczilla \
  --skip_upload_images true \
  --skip_upload_metadata true

# Ouvrir le fichier s'il existe
if [[ -f "./Preview.html" ]]; then
    echo "🚀 Ouverture de Preview.html..."
    open ./Preview.html 2>/dev/null || xdg-open ./Preview.html || echo "👉 Ouvre ./Preview.html manuellement"
else
    echo "❌ Échec : Preview.html non généré."
fi

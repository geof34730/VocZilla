#!/bin/bash

echo "Suppression de ./Preview.html si présent..."
rm -f ./Preview.html

SCREENSHOTS_DIR="fastlane/screenshots/ios"
METADATA_DIR="fastlane/metadata/ios"


### --- GÉNÉRATION DE PREVIEW.HTML --- ###

echo "Génération de Preview.html depuis $SCREENSHOTS_DIR et $METADATA_DIR..."
export FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1

fastlane deliver generate_summary \
  --screenshots_path "$SCREENSHOTS_DIR" \
  --metadata_path "$METADATA_DIR" \
  --platform ios \
  --force

echo "Ouverture de Preview.html..."
open ./Preview.html

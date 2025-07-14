#!/bin/bash

echo "Suppression de ./Preview.html si présent..."
rm -f ./Preview.html

TMP_SS_DIR="fastlane/tmp_screenshot"
TMP_META_DIR="fastlane/tmp_metadata"
SCREENSHOTS_DIR="fastlane/screenshots"
METADATA_DIR="fastlane/metadata"

### --- SAUVEGARDE & NETTOYAGE DES SCREENSHOTS --- ###

echo "Préparation du dossier temporaire des screenshots..."
rm -rf "$TMP_SS_DIR"
mkdir -p "$TMP_SS_DIR"

if [ -d "$SCREENSHOTS_DIR/ios" ]; then
  mv "$SCREENSHOTS_DIR/ios" "$TMP_SS_DIR/ios"
fi
if [ -d "$SCREENSHOTS_DIR/android" ]; then
  mv "$SCREENSHOTS_DIR/android" "$TMP_SS_DIR/android"
fi

echo "Suppression des dossiers ios/ et android/ de $SCREENSHOTS_DIR..."
rm -rf "$SCREENSHOTS_DIR/ios" "$SCREENSHOTS_DIR/android"

echo "Copie du contenu de $TMP_SS_DIR/ios dans $SCREENSHOTS_DIR..."
cp -R "$TMP_SS_DIR/ios/"* "$SCREENSHOTS_DIR/"

echo "Renommage des screenshots en format 2 chiffres (01.png, 02.png...)"
find "$SCREENSHOTS_DIR" -type f -name "[0-9].png" | while read filepath; do
  dir=$(dirname "$filepath")
  base=$(basename "$filepath")
  num="${base%%.*}"
  ext="${base##*.}"
  newname=$(printf "%02d.%s" "$num" "$ext")
  if [[ "$base" != "$newname" ]]; then
    mv "$filepath" "$dir/$newname"
    echo "Renommé : $filepath → $dir/$newname"
  fi
done

### --- SAUVEGARDE & NETTOYAGE DES MÉTADONNÉES --- ###

echo "Préparation du dossier temporaire des metadata..."
rm -rf "$TMP_META_DIR"
mkdir -p "$TMP_META_DIR"

if [ -d "$METADATA_DIR/ios" ]; then
  mv "$METADATA_DIR/ios" "$TMP_META_DIR/ios"
fi
if [ -d "$METADATA_DIR/android" ]; then
  mv "$METADATA_DIR/android" "$TMP_META_DIR/android"
fi

echo "Suppression des dossiers ios/ et android/ de $METADATA_DIR..."
rm -rf "$METADATA_DIR/ios" "$METADATA_DIR/android"

echo "Copie du contenu de $TMP_META_DIR/ios dans $METADATA_DIR..."
cp -R "$TMP_META_DIR/ios/"* "$METADATA_DIR/"

### --- GÉNÉRATION DE PREVIEW.HTML --- ###

echo "Génération de Preview.html depuis $SCREENSHOTS_DIR et $METADATA_DIR..."
export FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1

fastlane deliver generate_summary \
  --screenshots_path "$SCREENSHOTS_DIR" \
  --metadata_path "$METADATA_DIR" \
  --username geoffrey.petain@gmail.com \
  --app_identifier com.geoffreypetain.voczilla.voczilla \
  --platform ios \
  --force

echo "Ouverture de Preview.html..."
open ./Preview.html

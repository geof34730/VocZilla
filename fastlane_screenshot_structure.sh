#!/bin/bash

echo "🔧 Correction de la structure des captures d’écran pour Fastlane..."

BASE_DIR="./fastlane/screenshots"

# Utiliser des noms valides sans points comme clés
declare -A DEVICE_MAP=(
  ["iPhone_6_5_inch"]="iphone6_5_inch"
  ["iPhone_6_7_inch"]="iphone6_7_inch"
  ["iPhone_5_5_inch"]="iphone5_5_inch"
  ["iPhone_5_8_inch"]="iphone5_8_inch"
  ["iPhone_4_7_inch"]="iphone4_7_inch"
  ["iPadPro_3rd_gen_12_9"]="ipadPro_3rd_gen_12_9"
  ["iPad_10_5"]="ipad10_5"
)

# Remplacer . par _ dans les noms de dossiers pour la correspondance
sanitize_device_name() {
  echo "$1" | tr '.' '_'
}

for LANG_DIR in "$BASE_DIR"/*; do
  [ -d "$LANG_DIR" ] || continue
  echo "🌍 Traitement de la langue : $(basename "$LANG_DIR")"

  for DEVICE_SUBDIR in "$LANG_DIR"/*; do
    [ -d "$DEVICE_SUBDIR" ] || continue

    DEVICE_NAME=$(basename "$DEVICE_SUBDIR")
    DEVICE_KEY=$(sanitize_device_name "$DEVICE_NAME")
    DEVICE_TARGET=${DEVICE_MAP[$DEVICE_KEY]}

    if [ -z "$DEVICE_TARGET" ]; then
      echo "⚠️  Type d'appareil non reconnu : $DEVICE_NAME — ignoré"
      continue
    fi

    INDEX=1
    for FILE in "$DEVICE_SUBDIR"/*.png; do
      [ -f "$FILE" ] || continue
      NEW_NAME="${DEVICE_TARGET}_$(printf "%02d" $INDEX).png"
      mv "$FILE" "$LANG_DIR/$NEW_NAME"
      echo "✅ $FILE → $NEW_NAME"
      INDEX=$((INDEX + 1))
    done

    rm -r "$DEVICE_SUBDIR"
  done
done

echo "✅ Structure corrigée. Tu peux maintenant relancer :"
echo "   fastlane deliver --skip_metadata --skip_binary_upload --force"

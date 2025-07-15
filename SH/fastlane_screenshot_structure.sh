#!/bin/bash

echo "🔧 Correction de la structure des captures d’écran pour Fastlane..."

BASE_DIR="./fastlane/metadata"

# Remap visible pour correspondance Fastlane
convert_device_name() {
  case "$1" in
    "iPhone_6.5_inch") echo "iphone6_5_inch" ;;
    "iPhone_6.7_inch") echo "iphone6_7_inch" ;;
    "iPhone_5.5_inch") echo "iphone5_5_inch" ;;
    "iPhone_5.8_inch") echo "iphone5_8_inch" ;;
    "iPhone_4.7_inch") echo "iphone4_7_inch" ;;
    "iPadPro_3rd_gen_12.9") echo "ipadPro_3rd_gen_12_9" ;;
    "iPad_10.5") echo "ipad10_5" ;;
    *) echo "" ;;
  esac
}

for LANG_DIR in "$BASE_DIR"/*; do
  [ -d "$LANG_DIR" ] || continue
  LANG_CODE=$(basename "$LANG_DIR")
  echo "🌍 Traitement de la langue : $LANG_CODE"

  for DEVICE_SUBDIR in "$LANG_DIR"/*; do
    [ -d "$DEVICE_SUBDIR" ] || continue

    DEVICE_NAME=$(basename "$DEVICE_SUBDIR")
    DEVICE_TARGET=$(convert_device_name "$DEVICE_NAME")

    if [ -z "$DEVICE_TARGET" ]; then
      echo "⚠️  Appareil non reconnu : $DEVICE_NAME — ignoré"
      continue
    fi

    INDEX=1
    for FILE in "$DEVICE_SUBDIR"/*.png; do
      [ -f "$FILE" ] || continue
      NEW_FILE="${DEVICE_TARGET}_$(printf "%02d" $INDEX).png"
      mv "$FILE" "$LANG_DIR/$NEW_FILE"
      echo "✅ $FILE → $NEW_FILE"
      INDEX=$((INDEX + 1))
    done

    rm -r "$DEVICE_SUBDIR"
  done
done

echo "✅ Structure corrigée. Tu peux maintenant relancer :"
echo "   fastlane deliver --skip_metadata --skip_binary_upload --force"

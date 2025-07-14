#!/bin/bash

set -e

# Chargement des variables depuis .env
if [ -f ".env" ]; then
  echo "🔧 Chargement des variables depuis .env..."
  source .env
fi

# Définition des variables
APP_IDENTIFIER=${APP_IDENTIFIER:-com.geoffreypetain.voczilla.voczilla}
USERNAME=${FASTLANE_USER:-geoffrey.petain@gmail.com}
TEAM_ID=${TEAM_ID:-124128909}
PLATFORM="ios"
APP_VERSION=${APP_VERSION:-"9.1.4"}
TMP_DIR="./fastlane/tmp_screenshot/ios"
SCREENSHOT_DIR="./fastlane/screenshots"

echo "🧹 Nettoyage de $SCREENSHOT_DIR..."
rm -rf "$SCREENSHOT_DIR"
mkdir -p "$SCREENSHOT_DIR"

echo "📁 Copie des screenshots depuis $TMP_DIR → $SCREENSHOT_DIR..."
cp -R "$TMP_DIR"/* "$SCREENSHOT_DIR"

echo "🔍 Vérification des screenshots dans $SCREENSHOT_DIR..."
TOTAL_LANG=0
TOTAL_SHOTS=0

for locale in "$SCREENSHOT_DIR"/*; do
  [ -d "$locale" ] || continue
  LANG_NAME=$(basename "$locale")
  echo "🌍 Langue : $LANG_NAME"
  ((TOTAL_LANG++))

  for device in "$locale"/*; do
    [ -d "$device" ] || continue
    DEVICE_NAME=$(basename "$device")
    count=$(find "$device" -name "*.png" | wc -l | tr -d ' ')
    echo "  📱 Appareil : $DEVICE_NAME — $(printf "%7s" "$count") screenshot(s)"

    find "$device" -name "*.png" | sort | while read -r img; do
      dimensions=$(sips -g pixelWidth -g pixelHeight "$img" 2>/dev/null | awk '/pixel/ {printf "x%s", $2}')
      echo "    • $img — $dimensions"
    done

    ((TOTAL_SHOTS+=count))
    echo "    ➤ Total : $count screenshot(s)"
  done
done

echo
echo "📊 Résumé global :"
echo "🌐 Langues            : $TOTAL_LANG"
echo "📸 Screenshots total  : $TOTAL_SHOTS"

echo
echo "🚀 Upload des screenshots vers App Store Connect..."

FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS=1 \
fastlane deliver \
  --username "$USERNAME" \
  --app_identifier "$APP_IDENTIFIER" \
  --team_id "$TEAM_ID" \
  --platform "$PLATFORM" \
  --app_version "$APP_VERSION" \
  --screenshots_path "$SCREENSHOT_DIR" \
  --skip_binary_upload true \
  --skip_metadata true \
  --overwrite_screenshots true \
  --run_precheck_before_submit false \
  --force

echo "✅ Upload terminé avec succès."

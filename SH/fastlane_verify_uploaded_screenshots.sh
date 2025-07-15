#!/bin/bash

# Nombre attendu de screenshots par device
EXPECTED_SCREENSHOTS=8

echo "🔍 Vérification des screenshots dans fastlane/screenshots..."

TOTAL_LANGUAGES=0
TOTAL_DEVICES=0
TOTAL_FILES=0
ISSUE_FOUND=0

# Boucle sur les langues
for LOCALE_DIR in fastlane/screenshots/*; do
  if [ -d "$LOCALE_DIR" ]; then
    LOCALE=$(basename "$LOCALE_DIR")
    echo "🌍 Langue : $LOCALE"
    TOTAL_LANGUAGES=$((TOTAL_LANGUAGES + 1))

    # Boucle sur les devices
    for DEVICE_DIR in "$LOCALE_DIR"/*; do
      if [ -d "$DEVICE_DIR" ]; then
        DEVICE=$(basename "$DEVICE_DIR")
        echo "  📱 Appareil : $DEVICE"

        COUNT=0
        for FILE in "$DEVICE_DIR"/*.png; do
          if [ -f "$FILE" ]; then
            COUNT=$((COUNT + 1))
            # Vérifie les dimensions
            DIM=$(sips -g pixelWidth -g pixelHeight "$FILE" 2>/dev/null | awk '{print $2}' | paste -sd'x' -)
            echo "    • $(basename "$FILE") — ${DIM:-Erreur dimensions}"
          fi
        done

        echo "    ➤ Total : $COUNT screenshot(s)"
        TOTAL_FILES=$((TOTAL_FILES + COUNT))
        TOTAL_DEVICES=$((TOTAL_DEVICES + 1))

        # Vérifie s'il manque des screenshots
        if [ "$COUNT" -lt "$EXPECTED_SCREENSHOTS" ]; then
          echo "    ⚠️  Attention : Il manque des screenshots ! (attendus : $EXPECTED_SCREENSHOTS)"
          ISSUE_FOUND=1
        fi
      fi
    done
    echo ""
  fi
done

echo "📊 Résumé :"
echo "🌐 Langues : $TOTAL_LANGUAGES"
echo "📱 Devices : $TOTAL_DEVICES"
echo "🖼️  Total de screenshots : $TOTAL_FILES"

if [ "$ISSUE_FOUND" -eq 1 ]; then
  echo "❌ Problèmes détectés. Vérifie les détails ci-dessus."
  exit 1
else
  echo "✅ Tous les screenshots sont présents et valides."
fi

#!/bin/bash

BASE_DIR="fastlane/metadata/ios"

# Vérifie si le dossier existe
if [ ! -d "$BASE_DIR" ]; then
  echo "Erreur : le dossier $BASE_DIR n'existe pas."
  exit 1
fi

echo "Suppression des dossiers 'app_review_information' dans $BASE_DIR..."

find "$BASE_DIR" -type d -name "app_review_information" -exec rm -rf {} +

echo "✅ Suppression terminée."

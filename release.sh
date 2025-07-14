#!/bin/bash
set -e

# === CONFIGURATION ===
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="lntd-rhab-bowe-yoxx"
export FASTLANE_TEAM_ID="58A9XC46QY"

# === DÉPLOIEMENT ===
fastlane deliver \
  --ipa build/ios/ipa/voczilla.ipa \
  --force \
  --username geoffrey.petain@gmail.com \
  --app_identifier com.geoffreypetain.voczilla.voczilla \
  --team_id $FASTLANE_TEAM_ID \
  --skip_screenshots false \
  --skip_metadata false \
  --skip_binary_upload false \
  --overwrite_screenshots true \
  --ignore_language_directory_validation true \
  --run_precheck_before_submit false \
  --app_version 9.1.6 \
  --platform ios

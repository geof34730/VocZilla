#!/bin/bash

# Arrête le script immédiatement si une commande échoue.
set -e

# Charge et exporte les variables depuis .env pour qu'elles soient accessibles par fastlane
export FASTLANE_APP_ID=$(grep '^ENV_FASTLANE_APP_ID=' .env | cut -d '=' -f2-)
export FASTLANE_USER=$(grep '^ENV_FASTLANE_USER=' .env | cut -d '=' -f2-)
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=$(grep '^ENV_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=' .env | cut -d '=' -f2-)
export FASTLANE_TEAM_ID=$(grep '^ENV_FASTLANE_TEAM_ID=' .env | cut -d '=' -f2-)
export FASTLANE_ITC_TEAM_ID=$(grep '^ENV_FASTLANE_ITC_TEAM_ID=' .env | cut -d '=' -f2-)

# Pour forcer une nouvelle authentification, on supprime la session existante et le cache.
# On ne supprime PAS les identifiants qui viennent d'être chargés.
unset FASTLANE_SESSION && \
rm -rf ~/.fastlane/spaceship

echo -e "\n🧹 Clean terminé. On relance spaceauth..."
# On s'assure que le mot de passe n'est pas déjà défini pour forcer la saisie interactive.
unset FASTLANE_PASSWORD
echo "Vous allez être invité à entrer votre mot de passe Apple ID principal."
fastlane spaceauth -u "$FASTLANE_USER"

# Attente manuelle
echo -e "\n✅ Quand fastlane a copié le cookie dans le presse-papiers, appuie sur Entrée pour continuer..."
read -r

# Export du cookie depuis le presse-papiers
export FASTLANE_SESSION=$(pbpaste)

echo -e "\n🎉 FASTLANE_SESSION capturé et exporté."
echo "Les variables d'environnement sont prêtes pour les prochaines commandes fastlane."
echo "-------------------------------------------"
echo "Utilisateur:      $FASTLANE_USER"
echo "Team ID:          $FASTLANE_TEAM_ID"
echo "App ID:           $FASTLANE_APP_ID"
echo "App Specific Pwd: $(echo $FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD | sed 's/./*/g')" # Masqué
echo "Session:          $(echo $FASTLANE_SESSION | sed 's/./*/g')" # Masqué
echo "-------------------------------------------"
#fastlane deliver             --ipa build/ios/ipa/voczilla.ipa             --force             --screenshots_path fastlane/metadata/ios             --metadata_path fastlane/metadata/ios             --skip_screenshots true             --skip_metadata false             --skip_binary_upload false             --ignore_language_directory_validation true             --run_precheck_before_submit false             --platform ios

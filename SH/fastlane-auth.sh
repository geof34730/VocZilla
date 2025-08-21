FASTLANE_USER=$(grep '^ENV_FASTLANE_USER=' .env | cut -d '=' -f2-);
FASTLANE_PASSWORD=$(grep '^ENV_FASTLANE_PASSWORD=' .env | cut -d '=' -f2-);
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=$(grep '^ENV_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=' .env | cut -d '=' -f2-);
FASTLANE_TEAM_ID=$(grep '^ENV_FASTLANE_TEAM_ID=' .env | cut -d '=' -f2-);
FASTLANE_ITC_TEAM_ID=$(grep '^ENV_FASTLANE_ITC_TEAM_ID=' .env | cut -d '=' -f2-);


unset FASTLANE_SESSION FASTLANE_PASSWORD FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD  FASTLANE_TEAM_ID FASTLANE_ITC_TEAM_ID && \
rm -rf ~/.fastlane/spaceship && \
echo -e "\n🧹 Clean terminé. On relance spaceauth..." && \
fastlane spaceauth -u "$FASTLANE_USER"

# Attente manuelle
echo -e "\n✅ Quand fastlane a copié le cookie dans le presse-papiers, appuie sur Entrée pour continuer..."
read

# Export du cookie depuis le presse-papiers
export FASTLANE_SESSION=$(pbpaste)

echo -e "\n🎉 FASTLANE_SESSION capturé :"
echo "$FASTLANE_SESSION"


export FASTLANE_USER="$FASTLANE_USER"
export FASTLANE_PASSWORD="$FASTLANE_PASSWORD"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD"
export FASTLANE_TEAM_ID="$FASTLANE_TEAM_ID"
export FASTLANE_ITC_TEAM_ID="$FASTLANE_ITC_TEAM_ID"


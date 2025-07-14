rm -rf ~/.fastlane/spaceship && \
sed -i '' '/^FASTLANE_/d' .env && \
echo -e "\n🧹 Clean terminé. On relance spaceauth..." && \
fastlane spaceauth -u geoffrey.petain@gmail.com

export FASTLANE_USER=geoffrey.petain@gmail.com
export FASTLANE_PASSWORD=lntd-rhab-bowe-yoxx
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=lntd-rhab-bowe-yoxx

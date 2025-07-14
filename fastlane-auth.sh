unset FASTLANE_SESSION FASTLANE_PASSWORD FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD && \
rm -rf ~/.fastlane/spaceship && \
sed -i '' '/^FASTLANE_/d' .env && \
echo -e "\n🧹 Clean terminé. On relance spaceauth..." && \
fastlane spaceauth -u geoffrey.petain@gmail.com

export FASTLANE_USER=geoffrey.petain@gmail.com
export FASTLANE_PASSWORD=bxih-yqql-iurm-ckfg
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=bxih-yqql-iurm-ckfg

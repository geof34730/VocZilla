// deploy.js

/*
export FASTLANE_USER="ton.email@icloud.com"
export FASTLANE_PASSWORD="mot_de_passe_d_application"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="mot_de_passe_d_application"

fastlane spaceauth -u ton.email@icloud.com
*/


const { execSync } = require("child_process");
const inquirer = require("inquirer");
const fs = require("fs");
const path = require("path");
require('dotenv').config();

// Fonction pour lire l'Appfile et extraire les informations nécessaires
function getAppfileInfo(appfilePath) {
    return {
        appleId: process.env.FASTLANE_APPLE_ID,
        appIdentifier: process.env.FASTLANE_APP_IDENTIFIER,
        teamId: process.env.FASTLANE_TEAM_ID
    };
}

(async () => {


/*
    try {
        execSync('fastlane deliver ...', { stdio: 'inherit' });
    } catch (e) {
        if (e.message.includes('Invalid username and password combination') ||
            e.message.includes('session is not valid')) {
            console.error('⚠️  FASTLANE_SESSION expiré. Veuillez le régénérer avec: fastlane spaceauth');
            process.exit(1);
        }
        throw e;
    }
*/



    const deployInfoPath = "deploy-info.json";
    const appfilePath = path.join(__dirname, "ios/fastlane", "Appfile");
    if (!fs.existsSync(deployInfoPath)) {
        console.error(`❌ Erreur : Fichier ${deployInfoPath} introuvable.`);
        process.exit(1);
    }

    if (!fs.existsSync(appfilePath)) {
        console.error(`❌ Erreur : Fichier Appfile introuvable.`);
        process.exit(1);
    }


    const { appleId, appIdentifier, teamId } = getAppfileInfo(appfilePath);
    const deployInfo = JSON.parse(fs.readFileSync(deployInfoPath, "utf8"));
    let { lastVersionName, lastBuildNumber } = deployInfo;
    lastBuildNumber = parseInt(lastBuildNumber, 10);
    let versionName, buildNumber;
        const { majorUpdate } = await inquirer.prompt([
            {
                type: "confirm",
                name: "majorUpdate",
                message: "Est-ce une mise à jour majeur ?",
                default: false,
            },
        ]);

        const versionParts = lastVersionName.split('.').map(Number);
        if (majorUpdate) {
            versionParts[0] += 1; // Increment major version
            versionParts[1] = 0;  // Reset minor version
            versionParts[2] = 0;  // Reset patch version
        } else {
            versionParts[2] += 1; // Increment patch version
            if (versionParts[2] > 9) {
                versionParts[2] = 0;
                versionParts[1] += 1; // Increment minor version
                if (versionParts[1] > 9) {
                    versionParts[1] = 0;
                    versionParts[0] += 1; // Increment major version
                }
            }
        }





        versionName = versionParts.join('.');
        buildNumber = lastBuildNumber + 1;
    fs.writeFileSync(deployInfoPath, JSON.stringify({ lastVersionName: versionName, lastBuildNumber: buildNumber }, null, 2));

    console.log(`\n🔧 Nettoyage & récupération des packages Flutter...`);
    execSync(`flutter clean && flutter gen-l10n && flutter pub get`, { stdio: "inherit" });

            console.log(`\n🔐 Compilation Android  avec version: ${versionName} buildNumber: ${buildNumber}...`);
            execSync(
                `flutter build appbundle --release --build-name=${versionName} --build-number=${buildNumber}`,
                { stdio: "inherit" }
            );

            const serviceAccountPath = "voczilla-play.json";

            console.log("\n📤 Déploiement vers Google Play Store (track interne)...");

            if (!fs.existsSync(serviceAccountPath)) {
                console.error(`❌ Erreur : Fichier de clé de service introuvable à ${serviceAccountPath}`);
                process.exit(1);
            }

            execSync(
                `fastlane supply \
            --aab build/app/outputs/bundle/release/app-release.aab \
            --track internal \
            --json_key ${serviceAccountPath} \
            --package_name ${appIdentifier} \
            --metadata_path fastlane/metadata \
            --skip_upload_changelogs false \
            --skip_upload_images false \
            --skip_upload_screenshots false \
            --skip_upload_metadata false`,
                { stdio: "inherit" }
            );


    console.log("\n✅ Déploiement Android terminé avec succès !");

/*
    console.log(`\n🔐 Compilation iOS avec version: ${versionName} buildNumber: ${buildNumber}...`);
    execSync(
        `flutter build ipa --release --build-name=${versionName} --build-number=${buildNumber}`,
        { stdio: "inherit" }
    );


    console.log("\n📤 Déploiement vers l'App Store d'Apple...");




    try {
        const command = `
            fastlane deliver --ipa build/ios/ipa/voczilla.ipa --force --username ${appleId}   --app_identifier ${appIdentifier}   --team_id ${teamId}  --skip_metadata --force --run_precheck_before_submit false
          `;
        console.log(command);
        execSync(`echo $FASTLANE_SESSION`, { stdio: "inherit" });
        execSync(command, {
            stdio: "inherit",
            env: {
                ...process.env,
            }
        });

    } catch (error) {
        console.error("An error occurred:", error.message);
        process.exit(1);
    }
    console.log("\n✅ Déploiement iOS terminé avec succès !");
*/
    // Git operations
    console.log("\n📦 Git operations : Gestion des versions avec Git...");
    try {
        console.log(`\n🔀 git add . et push GIT Main pour la version: ${versionName}...`);

        const statusOutputMain = execSync(`git status --porcelain`).toString().trim();
        if (statusOutputMain) {
            execSync(`git add .`, { stdio: "inherit" });
            execSync(`git commit -m "Release version ${versionName}"`, { stdio: "inherit" });
        } else {
            console.log("Aucune modification à commettre.");
        }
        execSync(`git push origin main`, { stdio: "inherit" });

        console.log(`\n🔀 Création d'une nouvelle branche Git pour la version: ${versionName}...`);
        execSync(`git checkout -b release-build-${versionName}`, { stdio: "inherit" });

        const statusOutput = execSync(`git status --porcelain`).toString().trim();
        if (statusOutput) {
            execSync(`git add .`, { stdio: "inherit" });
            execSync(`git commit -m "Release version ${versionName}"`, { stdio: "inherit" });
        } else {
            console.log("Aucune modification à commettre.");
        }

        execSync(`git push --set-upstream origin release-build-${versionName}`, { stdio: "inherit" });

        console.log(`\n🔄 Retour à la branche principale...`);
        execSync(`git checkout main`, { stdio: "inherit" });
    } catch (error) {
        console.error("❌ Erreur lors des opérations Git :", error);
    }
    console.log("\n✅ Opérations Git terminées avec succès !");

})();


// deploy.js

/*
export FASTLANE_USER="ton.email@icloud.com"
export FASTLANE_PASSWORD="mot_de_passe_d_application"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="mot_de_passe_d_application"

fastlane spaceauth -u ton.email@icloud.com

unset FASTLANE_SESSION FASTLANE_PASSWORD FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD && \
rm -rf ~/.fastlane/spaceship && \
sed -i '' '/^FASTLANE_/d' .env && \
echo -e "\n🧹 Clean terminé. On relance spaceauth..." && \
fastlane spaceauth -u geoffrey.petain@gmail.com
pzfr-nqzx-dokj-lrpp

FASTLANE_APPLE_ID=geoffrey.petain@gmail.com
FASTLANE_APP_IDENTIFIER=com.geoffreypetain.voczilla.voczilla
FASTLANE_TEAM_ID=124128909
FASTLANE_SESSION='---\n- !ruby/object:HTTP::Cookie\n  name: myacinfo\n  value: DAWTKNV323952cf8084a204fb20ab2508441a07d02d31adffd78ea5a4a3f066fcff4c868763e0c6feceaeee0905d2d566b3ed43ba4b6ebb74b7d223888477ace6f37116ccae07d20b2befc56a34e4ae2884019b4fedcfbbb08b4dd77ec1a3b398169535e698c8c8f52f958935e04ebf8425ee863bbc317f81dfa236b848bbf71d2c9ad666450d47e617ac444f36774b0273999fe6c471e4027bebc2cc12f63574b46f1806315765aba91252593e4579c84bbe053e1e751e0737bd7ad1290b0328bc8f30599b465a15b37d2940a26cd2012f39410d7a07b5d57db8875d72d5dfcdc748040ee9c0e6875e6d9a8d9fa605ac8e312f841b38a99b7d29af805526f4c107a59c05e8da8c030bf9cb5acfd25d01ad5e6ba7b7c3b101763ee9773af4dbf6ed629caa228139e28ba816b7a7003e07e23bc3c9b2b4ccad2bd5078edf7be6e27df88b6b7d3fa077ff57deeca3fa274e5b7efc8c1b4542fcc063c70467fbc3160466258ebd11709facc03208ae50434e36ec038caa7be98ec185683249a6bd19bf5083dbcf4b7bcb6168fde3dce3cef3d8cacf2a288aed7baf70563bd1ca8a5cbae9f58611e45836d7bf9372d0b902a47b7a9426757facfad1656bd44b3c16488233b9ed77fb3e35d6cbbe5fd24d12843a8841f0c1f97c1416b372ca048ceebceff7992b995428a96063e43bd60e81474610506c0873ce20577438a7636ff82fa01ec75f7a5800e7bcad1a024f3f9db189e5a2b2932435692211e5ef909ef8a517a938247692e67884d2bb2a0eb5ffadc920bf1c534147a7e81b3ddb5e92f7ea83449df801c9647618eff71832a94c54ff0e09452163dfbe9824adbb0299a948300f78001f41d8d37db694787989ec58b8a8af73d7b585a47V3\n  domain: apple.com\n  for_domain: true\n  path: "/"\n  secure: true\n  httponly: true\n  expires:\n  max_age:\n  created_at: 2025-07-11 13:07:43.787413000 +02:00\n  accessed_at: 2025-07-11 13:07:43.789528000 +02:00\n- !ruby/object:HTTP::Cookie\n  name: DES5d174a5fac6348063fc92ceca7fd94851\n  value: HSARMTKNSRVXWFlaZMB8xBHw9j+4+pMopc43sOc7UGKCN7md3Tdf2SINfz4qPPXBWMYe/gb0PMBSyGJ1/hHKEAm6UB6JG3kFCxd/vipI1AT44G9yf9yE0rutqrR1OsWtoOFSRo6rO/IkA1MCvYxUcvsHBl3LoOP7Fyet/Fm8kzm5DtPZlNzuAya8O95ufiwZF9E=SRVX\n  domain: idmsa.apple.com\n  for_domain: true\n  path: "/"\n  secure: true\n  httponly: true\n  expires:\n  max_age: 2592000\n  created_at: &1 2025-07-11 13:07:43.787372000 +02:00\n  accessed_at: *1\n- !ruby/object:HTTP::Cookie\n  name: dqsid\n  value: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NTIyMzIwNjMsImp0aSI6InR0d2JDNC1kTU1xSHlWbjRlWThjTVEifQ.dgYZzu3Q6f75MV24Mz-4JL6uZe27uWtzfFblvyJvzDM\n  domain: appstoreconnect.apple.com\n  for_domain: false\n  path: "/"\n  secure: true\n  httponly: true\n  expires:\n  max_age: 1800\n  created_at: &2 2025-07-11 13:07:45.935275000 +02:00\n  accessed_at: *2\n'



export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="pzfr-nqzx-dokj-lrpp"


fastlane deliver --ipa build/ios/ipa/voczilla.ipa \
  --force \
  --username geoffrey.petain@gmail.com \
  --app_identifier com.geoffreypetain.voczilla.voczilla \
  --team_id 124128909 \
  --metadata_path fastlane/metadata/ios \
  --screenshots_path fastlane/screenshots/ios \
  --skip_screenshots false \
  --skip_metadata false \
  --run_precheck_before_submit false

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
    const mode = process.argv[2] || 'internal';
    const track = mode === 'release' ? 'production' : 'internal';
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
    const { generateMetadata } = await inquirer.prompt([
        {
            type: "confirm",
            name: "generateMetadata",
            message: "veux-tu générer  les screenshots ?",
            default: false,
        },
    ]);




        versionName = versionParts.join('.');
        buildNumber = lastBuildNumber + 1;
    await fs.writeFileSync(deployInfoPath, JSON.stringify({ lastVersionName: versionName, lastBuildNumber: buildNumber }, null, 2));
    if (generateMetadata) {
        execSync(`fastlane all screenshots`, { stdio: "inherit" });
    }
    else{

        execSync(`fastlane all generate_metadata`, { stdio: "inherit" });
    }
    console.log(`\n🔧 Nettoyage & récupération des packages Flutter...`);
    execSync(`flutter clean && flutter gen-l10n && flutter pub get`, { stdio: "inherit" });
/*
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


    try {
        execSync(
            `fastlane supply \
        --aab build/app/outputs/bundle/release/app-release.aab \
        --track ${track} \
        --json_key ${serviceAccountPath} \
        --package_name ${appIdentifier} \
        --metadata_path fastlane/metadata/android \
        --skip_upload_changelogs false \
        --skip_upload_images false \
        --skip_upload_screenshots false \
        --skip_upload_metadata false`,
            { stdio: "inherit" }
        );
        console.log("\n✅ Déploiement Android terminé avec succès !");
    } catch (error) {
        console.error("\n❌ Échec du déploiement Android :", error.message);
        process.exit(1);
    }


    console.log("\n✅ Déploiement Android terminé avec succès !");

 */


    console.log(`\n🔐 Compilation iOS avec version: ${versionName} buildNumber: ${buildNumber}...`);
    execSync(
        `flutter build ipa --release --build-name=${versionName} --build-number=${buildNumber}`,
        { stdio: "inherit" }
    );


    console.log("\n📤 Déploiement vers l'App Store d'Apple...");




    try {
        const command = `
fastlane deliver \
  --ipa build/ios/ipa/voczilla.ipa \
  --force \
  --username ${appleId} \
  --app_identifier ${appIdentifier} \
  --team_id ${teamId} \
  --metadata_path fastlane/metadata/ios \
  --screenshots_path fastlane/screenshots/ios \
  --skip_screenshots false \
  --skip_metadata false \
  --run_precheck_before_submit false
`;
        console.log(command);
        execSync(`echo $FASTLANE_SESSION`, { stdio: "inherit" });
        execSync(command, {
            stdio: "inherit",
            env: {
                ...process.env,
                FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: "pzfr-nqzx-dokj-lrpp"
            }
        });

    } catch (error) {
        console.error("An error occurred:", error.message);
        process.exit(1);
    }
    console.log("\n✅ Déploiement iOS terminé avec succès !");

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


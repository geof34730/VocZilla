/* eslint-disable no-console */
const { execSync } = require("child_process");
const inquirer = require("inquirer");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

// Lecture Appfile (vars déjà dans .env)
function getAppfileInfo(appfilePath) {
    return {
        appleId: process.env.ENV_FASTLANE_APPLE_ID,
        appIdentifier: process.env.ENV_FASTLANE_APP_ID,
        teamId: process.env.ENV_FASTLANE_TEAM_ID,
    };
}

// Helper exec
function run(cmd, opts = {}) {
    console.log(`\n$ ${cmd}`);
    return execSync(cmd, { stdio: "inherit", shell: true, ...opts });
}

(async () => {
    const mode = process.argv[2] || "internal";
    const track = mode === "release" ? "production" : "internal";

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

    // Sélection plateformes
    const { majorUpdate, deployAndroid, deployIos, deployMacos } =
        await inquirer.prompt([
            {
                type: "confirm",
                name: "majorUpdate",
                message: "Est-ce une mise à jour majeure ?",
                default: false,
            },
            {
                type: "confirm",
                name: "deployAndroid",
                message: "Uploader sur Google Play (Android) ?",
                default: true,
            },
            {
                type: "confirm",
                name: "deployIos",
                message: "Uploader sur l'App Store (iOS) ?",
                default: true,
            },
            {
                type: "confirm",
                name: "deployMacos",
                message: "Uploader aussi sur le Mac App Store (macOS) ?",
                default: false,
            },
        ]);

    const versionParts = lastVersionName.split(".").map(Number);
    if (majorUpdate) {
        versionParts[0] += 1;
        versionParts[1] = 0;
        versionParts[2] = 0;
    } else {
        versionParts[2] += 1;
        if (versionParts[2] > 9) {
            versionParts[2] = 0;
            versionParts[1] += 1;
            if (versionParts[1] > 9) {
                versionParts[1] = 0;
                versionParts[0] += 1;
            }
        }
    }

    versionName = versionParts.join(".");
    buildNumber = lastBuildNumber + 1;
    fs.writeFileSync(
        deployInfoPath,
        JSON.stringify(
            { lastVersionName: versionName, lastBuildNumber: buildNumber },
            null,
            2
        )
    );

    run(`fastlane all generate_metadata`);
    console.log(`\n🔧 Nettoyage & récupération des packages Flutter...`);
    run(`flutter clean && flutter gen-l10n && flutter pub get`);

    // =========================
    // ANDROID
    // =========================
    if (deployAndroid) {
        console.log(`\n🔐 Compilation Android ${versionName}+${buildNumber}…`);
        run(
            `flutter build appbundle --release --build-name=${versionName} --build-number=${buildNumber}`
        );

        const serviceAccountPath = "voczilla-play.json";
        console.log(`\n📤 Déploiement Google Play (track: ${track})…`);
        if (!fs.existsSync(serviceAccountPath)) {
            console.error(`❌ Clé service introuvable: ${serviceAccountPath}`);
            process.exit(1);
        }

        // ✅ Corrige/centralise le package name Android
        const androidPackage =
            process.env.ANDROID_PACKAGE_NAME || "com.geoffreypetain.voczilla.voczilla";
        if (/\.voczilla\.voczilla$/.test(androidPackage)) {
            console.warn(
                `⚠️  ANDROID_PACKAGE_NAME semble incorrect: ${androidPackage} (suffixe dupliqué).`
            );
        }

        try {
            run(
                `fastlane supply ` +
                `--aab build/app/outputs/bundle/release/app-release.aab ` +
                `--track ${track} ` +
                `--json_key ${serviceAccountPath} ` +
                `--package_name ${androidPackage} ` +
                `--metadata_path fastlane/metadata/android ` +
                `--skip_upload_changelogs false ` +
                `--skip_upload_images false ` +
                `--skip_upload_screenshots true ` +
                `--skip_upload_metadata false`
            );
            console.log("\n✅ Déploiement Android OK");
        } catch (e) {
            console.error("\n❌ Échec déploiement Android :", e.message);
            process.exit(1);
        }
        run(`flutter clean && flutter pub get`);
    } else {
        console.log("\n⏭️ Android ignoré.");
    }

    // =========================
    // iOS
    // =========================
    if (deployIos) {
        console.log(`\n🔐 Compilation iOS ${versionName}+${buildNumber}…`);
        run(
            `flutter build ipa --release --build-name=${versionName} --build-number=${buildNumber}`
        );

        console.log("\n📤 Déploiement App Store (iOS)...");
        if (!process.env.ENV_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD) {
            console.error(
                "❌ ENV_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD manquante."
            );
            process.exit(1);
        }
        if (!process.env.FASTLANE_SESSION) {
            console.error(
                "❌ FASTLANE_SESSION manquante (exécute: source ./SH/fastlane-auth.sh)."
            );
            process.exit(1);
        }

        try {
            const commandIOS = `
        fastlane deliver \
          --app_version "${versionName}" \
          --username "geoffrey.petain@gmail.com" \
          --ipa build/ios/ipa/voczilla.ipa \
          --force \
          --screenshots_path fastlane/metadata/ios \
          --metadata_path fastlane/metadata/ios \
          --skip_screenshots true \
          --skip_metadata false \
          --skip_binary_upload false \
          --ignore_language_directory_validation true \
          --run_precheck_before_submit false \
          --platform ios
      `;
            execSync(commandIOS, {
                stdio: "inherit",
                env: {
                    ...process.env,
                    FASTLANE_VERBOSE: "1",
                    FASTLANE_SKIP_UPDATE_CHECK: "1",
                    FASTLANE_USER: process.env.ENV_FASTLANE_APPLE_ID || appleId,
                    FASTLANE_APP_IDENTIFIER:
                        process.env.ENV_FASTLANE_APP_ID || appIdentifier,
                    FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD:
                    process.env.ENV_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD,
                },
            });
            run(`flutter clean && flutter pub get`);
            console.log("\n✅ Déploiement iOS OK");
        } catch (e) {
            console.error("❌ Erreur déploiement iOS :", e.message);
            process.exit(1);
        }
    } else {
        console.log("\n⏭️ iOS ignoré.");
    }

    // =========================
    // macOS
    // =========================
    if (deployMacos) {
        console.log(`\n🔐 Préparation env macOS (ephemeral + Pods)…`);
        try {
            run(`rm -rf macos/Flutter/ephemeral build/macos`);
            run(`flutter clean`);
            run(`flutter pub get`);
            run(`flutter --suppress-analytics precache --macos`);
            try {
                run(`flutter gen-l10n`);
            } catch {}
            run(`cd macos && pod install --repo-update && cd -`);
        } catch (e) {
            console.error("❌ Préparation macOS échouée :", e.message);
            process.exit(1);
        }

        const archivePath = `build/macos/archive/Runner.xcarchive`;
        const exportPath = `build/macos/export`;
        const exportPlist = `macos/exportOptions.plist`;

        const team = process.env.ENV_FASTLANE_TEAM_ID || teamId || "58A9XC46QY";
        // ✅ Corrige/centralise le bundle id macOS
        const macBundleId =
            process.env.MACOS_BUNDLE_ID || "com.geoffreypetain.voczilla.voczilla";

        if (!fs.existsSync(exportPlist)) {
            console.error(`❌ ${exportPlist} manquant.`);
            process.exit(1);
        }

        // Génère l’ephemeral (crucial pour les xcfilelist)
        console.log(`\n🏗️  Génération Flutter macOS (ephemeral)…`);
        try {
            run(
                `flutter build macos --release --build-name=${versionName} --build-number=${buildNumber} -v`
            );
        } catch (e) {
            console.error("❌ flutter build macos a échoué :", e.message);
            process.exit(1);
        }

        // Vérifie les xcfilelist
        const inputsList = `macos/Flutter/ephemeral/FlutterInputs.xcfilelist`;
        const outputsList = `macos/Flutter/ephemeral/FlutterOutputs.xcfilelist`;
        if (!fs.existsSync(inputsList) || !fs.existsSync(outputsList)) {
            console.warn("⚠️  Filelists manquants, régénération…");
            try {
                run(
                    `flutter build macos --release --build-name=${versionName} --build-number=${buildNumber} -v`
                );
            } catch {}
        }
        if (!fs.existsSync(inputsList) || !fs.existsSync(outputsList)) {
            console.error("❌ Filelists toujours absents. Ouvre Xcode et build une fois.");
            process.exit(1);
        }

        // (Info) certifs dispo
        try {
            run(
                `security find-identity -v -p codesigning | grep "Apple Distribution" || true`
            );
            run(
                `security find-identity -v -p installer   | grep "Mac Installer Distribution" || true`
            );
        } catch {}

        console.log(`\n🧱 Archive Xcode (Release, signature AUTOMATIQUE)…`);
        try {
            const archiveLog = `build/macos/xcodebuild-archive.log`;
            run(
                `mkdir -p build/macos && ` +
                `xcodebuild ` +
                `-workspace macos/Runner.xcworkspace ` +
                `-scheme Runner ` +
                `-configuration Release ` +
                `-destination 'generic/platform=macOS' ` +
                `-archivePath ${archivePath} ` +
                `DEVELOPMENT_TEAM=${team} ` +
                `PRODUCT_BUNDLE_IDENTIFIER=${macBundleId} ` +
                `CODE_SIGN_STYLE=Automatic ` + // ✅ Automatique
                `-allowProvisioningUpdates ` +
                `archive 2>&1 | tee ${archiveLog}`
            );
        } catch (error) {
            console.error("❌ Erreur lors de l'archive macOS :", error.message);
            try {
                const tailErr = execSync(
                    `grep -nE "error:|No profiles for|code signing|provision|certificate|Signing|xcfilelist" build/macos/xcodebuild-archive.log | tail -n 80`,
                    { stdio: "pipe", shell: true }
                ).toString();
                if (tailErr.trim())
                    console.error("\n📄 Extrait d’erreurs probables :\n" + tailErr);
            } catch {}
            process.exit(1);
        }

        console.log(`\n📦 Export .pkg (App Store Connect)…`);
        try {
            const exportLog = `build/macos/xcodebuild-export.log`;
            run(
                `xcodebuild -exportArchive ` +
                `-archivePath ${archivePath} ` +
                `-exportOptionsPlist ${exportPlist} ` +
                `-exportPath ${exportPath} ` +
                `-allowProvisioningUpdates 2>&1 | tee ${exportLog}`
            );
        } catch (error) {
            console.error("❌ Erreur lors de l'export macOS :", error.message);
            try {
                const tailErr = execSync(
                    `grep -nE "error:|No profiles for|Installer|certificate|provision|Signing" build/macos/xcodebuild-export.log | tail -n 80`,
                    { stdio: "pipe", shell: true }
                ).toString();
                if (tailErr.trim())
                    console.error("\n📄 Extrait d’erreurs probables :\n" + tailErr);
            } catch {}
            process.exit(1);
        }

        // Récupère le .pkg
        let pkgPath = path.join(exportPath, `Runner.pkg`);
        if (!fs.existsSync(pkgPath) && fs.existsSync(exportPath)) {
            const candidates = fs
                .readdirSync(exportPath)
                .filter((f) => f.endsWith(".pkg"));
            if (candidates.length) pkgPath = path.join(exportPath, candidates[0]);
        }
        if (!fs.existsSync(pkgPath)) {
            console.error(`❌ .pkg introuvable dans ${exportPath}.`);
            process.exit(1);
        }
        console.log(`✅ .pkg: ${pkgPath}`);

        console.log("\n📤 Deliver vers Mac App Store…");
        try {
            const commandMacos = `
  fastlane deliver \
    --app_version "${versionName}" \
    --username "geoffrey.petain@gmail.com" \
    --pkg "${pkgPath}" \
    --force \
    --screenshots_path fastlane/metadata/macos \
    --metadata_path fastlane/metadata/macos \
    --skip_screenshots true \
    --skip_metadata false \
    --skip_binary_upload false \
    --ignore_language_directory_validation true \
    --run_precheck_before_submit false \
    --platform osx
`;
            execSync(commandMacos, {
                stdio: "inherit",
                env: {
                    ...process.env,
                    FASTLANE_VERBOSE: "1",
                    FASTLANE_SKIP_UPDATE_CHECK: "1",
                    FASTLANE_USER: process.env.ENV_FASTLANE_APPLE_ID || appleId,
                    // 👉 Important : utilise l’identifiant macOS ici
                    FASTLANE_APP_IDENTIFIER: process.env.MACOS_BUNDLE_ID || macBundleId,
                    FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD:
                    process.env.ENV_FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD,
                },
            });
            console.log("\n✅ Déploiement macOS OK");
        } catch (e) {
            console.error("❌ Erreur déploiement macOS :", e.message);
            process.exit(1);
        }
    } else {
        console.log("\n⏭️ macOS ignoré.");
    }

    // =========================
    // Git
    // =========================
    console.log("\n📦 Git : gestion versions…");
    try {
        console.log(`\n🔀 Commit/push main pour ${versionName}…`);
        const statusOutputMain = execSync(`git status --porcelain`)
            .toString()
            .trim();
        if (statusOutputMain) {
            run(`git add .`);
            run(`git commit -m "Release version ${versionName}"`);
        } else {
            console.log("Aucune modification à commettre.");
        }
        run(`git push origin main`);

        console.log(`\n🔀 Nouvelle branche release-build-${versionName}…`);
        run(`git checkout -b release-build-${versionName}`);

        const statusOutput = execSync(`git status --porcelain`).toString().trim();
        if (statusOutput) {
            run(`git add .`);
            run(`git commit -m "Release version ${versionName}"`);
        } else {
            console.log("Aucune modification à commettre.");
        }

        run(`git push --set-upstream origin release-build-${versionName}`);
        console.log(`\n🔄 Retour sur main…`);
        run(`git checkout main`);
    } catch (error) {
        console.error("❌ Erreur Git :", error);
    }
    console.log("\n✅ Opérations Git terminées !");
})();

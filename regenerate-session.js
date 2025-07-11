// regenerate-session.js

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const inquirer = require("inquirer");

(async () => {
    const { email } = await inquirer.prompt([
        {
            type: "input",
            name: "email",
            message: "Adresse email Apple utilisée pour Fastlane :",
            validate: (value) => value.includes("@") || "Adresse invalide.",
        },
    ]);

    console.log("\n🧹 Nettoyage de l’ancien .env...");
    const envPath = path.resolve(".env");

    let content = fs.existsSync(envPath) ? fs.readFileSync(envPath, "utf8") : "";
    content = content
        .replace(/^FASTLANE_SESSION=.*$/m, "")
        .replace(/^FASTLANE_PASSWORD=.*$/m, "")
        .replace(/^FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=.*$/m, "")
        .replace(/\n\n+/g, "\n")
        .trim();

    console.log("\n🔐 Lancement de `fastlane spaceauth`...\n");

    try {
        const output = execSync(`fastlane spaceauth -u ${email}`, { stdio: "pipe" }).toString();

        const match = output.match(/FASTLANE_SESSION environment variable:\n\n(.+?)\n/);
        if (!match) {
            console.error("❌ Token introuvable dans la sortie de fastlane.");
            process.exit(1);
        }

        const token = match[1].trim();

        content += `\nFASTLANE_SESSION=${token}\n`;
        fs.writeFileSync(envPath, content);

        console.log("\n✅ Nouveau token FASTLANE_SESSION enregistré dans .env");
    } catch (err) {
        console.error("❌ Erreur lors de l'exécution de fastlane spaceauth :", err.message);
        process.exit(1);
    }
})();

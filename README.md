# VocZilla

Application Flutter multi-plateforme permettant d’apprendre du vocabulaire anglais via des listes thématiques, des quiz dynamiques, de la dictée vocale et un suivi de progression synchronisé avec Firebase. Le projet intègre également un backend (Cloud Functions + Cloud Run), la monétisation via achats intégrés et l’acquisition utilisateurs (Branch, Deep Links et campagnes de partage).

## Fonctionnalités principales

- **Apprentissage guidé** : plus de 4 300 mots répartis par thèmes (`assets/data/vocabulaires/`), fiches personnalisées, prononciation audio et quiz adaptatifs.
- **Modes avancés** : dictée vocale (Speech‑to‑Text), entraînement à la prononciation (audioplayers) et statistiques détaillées (`statistical.screen.dart`).
- **Expérience connectée** : authentification Firebase (Google, Apple, Facebook), notifications push & locales, App Check, partage via Branch deep links et écran dédié (`share_screen.dart`).
- **Monétisation** : abonnements mensuels/annuels (`global.dart`) avec vérification côté serveur (`subscription-v1…run.app`) et gestion des achats (`in_app_purchase_*`).
- **Accessibilité hors ligne** : synchronisation des listes dans `VocabulaireUserRepository` puis mise à disposition dans les écrans `offline`/`home`.
- **Gamification** : classement (leaderboard), trophées/confettis, suivi des séries gagnantes et indicateurs de progression.

## Architecture en bref

- **Couche présentation (`lib/ui/`)** : écrans organisés par domaines (auth, vocabulary, subscription, etc.), thèmes personnalisés et widgets partagés.
- **Couche logique (`lib/logic/`)** : BLoC/Cubit + HydratedBloc pour conserver l’état hors ligne, `check_connectivity.dart` pour la résilience réseau et notifiers pour la navigation.
- **Données (`lib/data/`)** : modèles Freezed/JSON serializable, dépôts (`repository/`) et services (Firebase Messaging, notifications locales, accès HTTP via Dio).
- **Services globaux** : `firebase_initialiser.dart`, `global.dart` (constantes, URLs Cloud Run, IDs d’abonnement), `services/admob_service.dart` pour les publicités.
- **Internationalisation** : configuration `l10n/` + `flutter gen-l10n`.

## Prérequis

- Flutter >= 3.8, Dart >= 3.x
- Xcode (iOS), Android Studio + SDK 21+
- Compte Firebase (Auth, Firestore, Functions, Storage, Analytics, Messaging, In-App Messaging)
- Comptes Apple/Google Play pour les achats intégrés et la distribution
- Compte Branch.io + identifiants AdMob

## Installation

```bash
git clone <repo>
cd voczilla
flutter pub get
```

### Configuration Firebase

1. Créer les projets Firebase (iOS, Android, Web, Desktop si nécessaire).
2. Générer `firebase_options.dart` avec `flutterfire configure` et remplacer le fichier existant dans `lib/`.
3. Ajouter `google-services.json` (Android) et `GoogleService-Info.plist` (iOS) dans les répertoires natifs.
4. Vérifier/mettre à jour les clés App Check si activé (voir `main.dart`).

### Branch, AdMob & Backend

- Branch : déclarer les liens dynamiques et renseigner les clés dans les fichiers natifs (`ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`).
- AdMob : ajouter les identifiants dans `services/admob_service.dart` et les manifests.
- Backend Cloud Run/Functions : adapter les URLs dans `lib/global.dart` (`serveurUrl`, routes leaderboard, etc.).

## Génération de code & i18n

```bash
# Générer les classes localisées
flutter gen-l10n

# Regénérer les modèles Freezed/JSON
flutter pub run build_runner watch --delete-conflicting-outputs
```

Les modèles se trouvent dans `lib/data/models/` (leaderboard, user, vocabulary). Toute modification sur les fichiers `.dart` annotés requiert une régénération.

### Localisations (`lib/l10n/`)

- Plus de 60 fichiers ARB (`lib/l10n/app_*.arb`) définissent les chaînes traduites ; `app_en.arb` sert de référence.
- Les fichiers `app_localizations_*.dart` sont générés automatiquement par `flutter gen-l10n` et ne doivent pas être modifiés à la main.
- Pour ajouter une langue : créer un nouvel `app_xx.arb`, y placer les clés nécessaires, puis relancer `flutter gen-l10n`.
- Les scripts Fastlane et le test driver lisent ces locales pour produire les captures multilingues.

## Lancer l’application

```bash
# Debug
flutter run

# iOS
flutter run -d ios

# Web (optionnel)
flutter run -d chrome --web-renderer canvaskit
```

Les paramètres facultatifs de `main()` permettent d’automatiser la génération de visuels marketing (`forFeatureGraphic`, `localForce`, etc.).

## Tests & qualité

- Tests unitaires/widget : `flutter test`
- Analyse statique : respect des règles `analysis_options.yaml`
- Lints personnalisés : `flutter analyze`

### Tests d’intégration & screenshots (`test_driver/`)

- `test_driver/app.dart` lance l’app en mode driver, applique les paramètres passés via variables d’environnement (locale, plateforme, flags marketing) et active l’extension `FlutterDriver`.
- `test_driver/integration_test.dart` orchestre le parcours utilisateur, prend des captures via `takeScreenshot` et les stocke dans `test_driver/screenshots/` (utilisées par Fastlane).
- Exemple d’exécution locale (Android, français) :
  ```bash
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=test_driver/app.dart \
    --dart-define=LOCALE=fr \
    --dart-define=PLATFORM=android
  ```
- Les lanes Fastlane (`android screenshots`) injectent automatiquement `LOCALE`, `PLATFORM`, `DESTFOLDER` et les flags `FOR_FEATURE_GRAPHIC*` pour produire les médias marketing.

## Distribution

- Android : `flutter build appbundle` + automatisation Fastlane (`android/fastlane/`).
- iOS : `flutter build ipa` + Fastlane (`ios/fastlane/`).
- Web/Desktop : dossiers `web/`, `macos/`, `windows/`, `linux/`.

## Fastlane

### Installation

```bash
cd ios && bundle install   # ou gem install fastlane
cd ../android && bundle install
```

Pensez à renseigner les identifiants Play Console/App Store Connect dans les variables d’environnement ou dans les `Appfile`.

### Lanes Android (`android/fastlane/Fastfile`)

- `fastlane android screenshots` : génère les captures multi-langues via `fastlane/generate_metadata.dart`, compile l’app par locale (`LOCALE`), lance les tests d’intégration et range les PNG dans `fastlane/metadata/android/...`.
- `fastlane android release` : enchaîne `screenshots` puis publie les métadonnées/screenhots sur le Play Store via `supply` (les APK/AAB sont gérés séparément).
- `fastlane android test` : exécute `gradle testReleaseUnitTest`.

### Lane iOS (`ios/fastlane/Fastfile`)

- `fastlane ios beta` : incrémente le build, compile via `build_app` et pousse la build vers TestFlight avec `upload_to_testflight`.

Avant d’exécuter une lane, assurez-vous d’avoir les certificats, profils de provisioning, identifiants API et variables `FASTLANE_SESSION` (si nécessaire) à jour.

## Scripts npm (`package.json`)

- `npm run deploy:test` / `deploy:release` : exécute `deploy.js` pour orchestrer les déploiements (Cloud Functions/Run) selon l’environnement.
- `npm run rebuild` : pipeline complet (clean, `build_runner`, `flutter gen-l10n`, `pub get`, `flutter run`) utile pour repartir sur une base saine.
- `npm run translate` : régénère les modèles + localisations sans lancer l’app.
- `npm run model` : regénère uniquement les modèles Freezed/JSON.
- Scripts `fastlane*` (ex. `fastlaneUploadScreenshotsIos`, `fastlaneUploadMetaDataAndroid`, etc.) : wrappers Node qui appellent les scripts shell sous `SH/` pour automatiser uploads/consultations des métadonnées et captures côté App Store / Play Store / macOS.
- `npm run fastlaneauth` / `fastlaneVerifyUploaded` : aides pour authentifier Fastlane et vérifier les métadonnées envoyées.

Tous ces scripts supposent que Flutter, Node.js et Fastlane sont installés et que les variables d’environnement nécessaires (Firebase, stores, Branch) sont définies.

## Ressources utiles

- [Documentation Flutter](https://docs.flutter.dev)
- [Guide Branch.io](https://help.branch.io/developers-hub/docs/flutter-sdk-overview)
- [FlutterFire](https://firebase.flutter.dev/)
- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc)

## Contribution

1. Créer une branche (`git checkout -b feature/ma-feature`).
2. Mettre à jour/ajouter des tests.
3. Vérifier `flutter analyze && flutter test`.
4. Soumettre une PR descriptive (contexte, captures et étapes de tests).

Bon apprentissage avec VocZilla !

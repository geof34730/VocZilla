fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## all

### all generate_metadata

```sh
[bundle exec] fastlane all generate_metadata
```

📸 Générer les métadonnées Android & iOS

### all screenshots_ios

```sh
[bundle exec] fastlane all screenshots_ios
```

📷 Screenshots iOS (simulateur) — build unique + config runtime (Option 3)

### all screenshots_android

```sh
[bundle exec] fastlane all screenshots_android
```

📷 Screenshots Android — build unique + config runtime (Option 3) + réglage résolution (+ reboot par bucket)

### all screenshots

```sh
[bundle exec] fastlane all screenshots
```

📷 Screenshots (iOS + Android) — orchestrateur

### all cleanup_soft

```sh
[bundle exec] fastlane all cleanup_soft
```

🧽 Nettoyage manuel (léger)

### all cleanup_hard

```sh
[bundle exec] fastlane all cleanup_hard
```

🔥 Nettoyage agressif

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

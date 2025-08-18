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

### all screenshots

```sh
[bundle exec] fastlane all screenshots
```

📷 Screenshots Android + iOS (simulateur) — builds uniques, exécutions sans rebuild, cleanup disque

### all cleanup_soft

```sh
[bundle exec] fastlane all cleanup_soft
```

🧽 Nettoyage manuel (conserve Runner.app simulateur)

### all cleanup_hard

```sh
[bundle exec] fastlane all cleanup_hard
```

🔥 Nettoyage agressif (supprime aussi le build iOS simulateur)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

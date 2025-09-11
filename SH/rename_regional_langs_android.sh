#!/bin/bash

# Chemin vers le dossier contenant les fichiers .arb
# Assurez-vous que ce chemin est correct.
L10N_DIR="/Users/geoffreypetain/IdeaProjects/VocZilla-all/voczilla/lib/l10n/"

# Le champ à supprimer
KEY_TO_REMOVE="card_home_termine"

# Vérifier si jq est installé
if ! command -v jq &> /dev/null; then
    echo "Erreur : L'outil 'jq' n'est pas installé." >&2
    echo "Veuillez l'installer pour exécuter ce script (ex: 'brew install jq')." >&2
    exit 1
fi

# Vérifier si le répertoire existe
if [ ! -d "$L10N_DIR" ]; then
    echo "Erreur : Le répertoire '$L10N_DIR' n'a pas été trouvé." >&2
    exit 1
fi

echo "Lancement du nettoyage des fichiers .arb..."

# Boucle sur tous les fichiers .arb du répertoire
for file in "$L10N_DIR"/*.arb; do
    # Vérifie si le fichier contient la clé avant de le modifier
    if grep -q "\"$KEY_TO_REMOVE\"" "$file"; then
        echo "Suppression de '$KEY_TO_REMOVE' dans $file"
        # Utilise jq pour supprimer la clé et écrit le résultat dans un fichier temporaire
        # puis remplace le fichier original. C'est plus sûr que l'édition "en place".
        jq "del(.$KEY_TO_REMOVE)" "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    else
        echo "Le champ '$KEY_TO_REMOVE' n'a pas été trouvé dans $file, fichier ignoré."
    fi
done

echo "Opération terminée."

# gestion-locale.ps1

Ce script PowerShell permet de simuler la gestion locale d’utilisateurs, de groupes et de licences dans un environnement simple, à l’aide de fichiers JSON. Il propose un menu interactif pour effectuer les opérations courantes.

- Fonctionnalités principales :

- Ajouter un utilisateur :
    - Saisie du nom, prénom, email et type de licence (E1/E3/E5)
    - Enregistrement dans `users.json` (créé si inexistant)
    - L’utilisateur est associé à une liste de groupes (vide par défaut)
    - Simulation de l’attribution de licence (affichage d’un message)

- Créer un groupe :
    - Saisie du nom du groupe
    - Enregistrement dans `groups.json` (créé si inexistant)
    - Liste des membres vide à la création

- Attribuer un utilisateur à un groupe :
    - Ajoute le groupe à la liste de groupes de l’utilisateur
    - Ajoute l’utilisateur à la liste des membres du groupe
    - Mise à jour croisée des fichiers `users.json` et `groups.json`

- Générer un rapport synthétique :
    - Affiche en console un tableau récapitulatif des utilisateurs, licences et groupes associés

Utilisation

1. Ouvrir un terminal PowerShell (sur Mac, utiliser `pwsh`)
2. Se placer dans le dossier contenant le script :
     cd ~/Desktop/Projet
3. Lancer le script :
     ./gestion-locale.ps1
4. Suivre les instructions du menu interactif.

Fichiers générés
  - `users.json` : liste des utilisateurs, leurs informations et groupes associés
  - `groups.json` : liste des groupes et leurs membres

-------------------------------------------------------------------------------------------------

# maintenance-securite.ps1

Ce script PowerShell permet de gérer des règles de sécurité réseau et d’audit local via un menu interactif.  
Il simule la gestion de règles de pare-feu en mémoire (aucun fichier n’est généré) et affiche les commandes comme si elles étaient réellement exécutées.

- Fonctionnalités principales :

- Afficher les profils actifs :
    - Affiche les profils de pare-feu actifs (`NetFirewallProfile`)
    - Affiche un exemple de profils Domain, Private, Public

- Créer une règle de pare-feu :
    - Saisie d’un port TCP à bloquer (ex : 4444)
    - Crée une règle de blocage sortant sur ce port (stockée en mémoire)
    - Affiche la commande PowerShell correspondante

- Vérifier la règle de pare-feu :
    - Affiche toutes les règles créées pendant la session
    - Affiche la commande PowerShell correspondante

- Supprimer une règle de pare-feu :
    - Permet de choisir et supprimer une règle créée pendant la session
    - Affiche la commande PowerShell correspondante

Utilisation

1. Ouvrir un terminal PowerShell (sur Mac, utiliser `pwsh`)
2. Se placer dans le dossier contenant le script :
     cd ~/Desktop/Projet
3. Lancer le script :
     ./maintenance-securite.ps1
4. Suivre les instructions du menu interactif.
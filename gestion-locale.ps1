# gestion-locale.ps1
# Script de gestion locale des utilisateurs et groupes
# Utilisation : lancer le script et suivre les instructions du menu

# Fonction pour charger un fichier JSON (retourne un tableau vide si le fichier n'existe pas)
function Charger-Json($fichier) {
    if (Test-Path $fichier) {
        Get-Content $fichier | ConvertFrom-Json
    } else {
        @()
    }
}

# Fonction pour sauvegarder un objet PowerShell dans un fichier JSON
function Sauver-Json($fichier, $objet) {
    $objet | ConvertTo-Json -Depth 5 | Set-Content $fichier
}

# Ajoute un nouvel utilisateur avec nom, prénom, email, licence et groupes (vide par défaut)
function Ajouter-Utilisateur {
    $nom = Read-Host "Nom de l'utilisateur"
    $prenom = Read-Host "Prénom de l'utilisateur"
    $email = Read-Host "Email de l'utilisateur"
    do {
        $licence = Read-Host "Licence (E1/E3/E5)"
    } while ($licence -notin @('E1','E3','E5'))

    $users = Charger-Json 'users.json'
    # Vérifie si l'utilisateur existe déjà
    if ($users | Where-Object { $_.email -eq $email }) {
        Write-Host "Utilisateur déjà existant !" -ForegroundColor Yellow
        return
    }
    $nouvelUtilisateur = [PSCustomObject]@{
        nom = $nom
        prenom = $prenom
        email = $email
        licence = $licence
        groupes = @()
    }
    $users += $nouvelUtilisateur
    Sauver-Json 'users.json' $users
    Write-Host "Licence $licence simulée pour $prenom $nom ($email)" -ForegroundColor Cyan
}

# Crée un nouveau groupe avec une liste de membres vide
function Creer-Groupe {
    $nomGroupe = Read-Host "Nom du groupe à créer"
    $groups = Charger-Json 'groups.json'
    # Vérifie si le groupe existe déjà
    if ($groups | Where-Object { $_.nom -eq $nomGroupe }) {
        Write-Host "Groupe déjà existant !" -ForegroundColor Yellow
        return
    }
    $nouveauGroupe = [PSCustomObject]@{
        nom = $nomGroupe
        membres = @()
    }
    $groups += $nouveauGroupe
    Sauver-Json 'groups.json' $groups
    Write-Host "Groupe $nomGroupe créé." -ForegroundColor Green
}

# Attribue un utilisateur à un groupe (mise à jour croisée des fichiers)
function Attribuer-Utilisateur-Groupe {
    $users = Charger-Json 'users.json'
    $groups = Charger-Json 'groups.json'
    if (-not $users) { Write-Host "Aucun utilisateur existant."; return }
    if (-not $groups) { Write-Host "Aucun groupe existant."; return }
    $email = Read-Host "Email de l'utilisateur à ajouter à un groupe"
    $user = $users | Where-Object { $_.email -eq $email }
    if (-not $user) { Write-Host "Utilisateur non trouvé."; return }
    $nomGroupe = Read-Host "Nom du groupe"
    $groupe = $groups | Where-Object { $_.nom -eq $nomGroupe }
    if (-not $groupe) { Write-Host "Groupe non trouvé."; return }
    # Vérifie si l'utilisateur est déjà dans le groupe
    if ($user.groupes -contains $nomGroupe) {
        Write-Host "Utilisateur déjà dans ce groupe." -ForegroundColor Yellow
        return
    }
    # Mise à jour de la liste des groupes de l'utilisateur
    $user.groupes += $nomGroupe
    # Mise à jour de la liste des membres du groupe
    $groupe.membres += $email
    # Remplace les objets modifiés dans les listes
    $users = $users | ForEach-Object { if ($_.email -eq $email) { $user } else { $_ } }
    $groups = $groups | ForEach-Object { if ($_.nom -eq $nomGroupe) { $groupe } else { $_ } }
    Sauver-Json 'users.json' $users
    Sauver-Json 'groups.json' $groups
    Write-Host "Utilisateur $($user.prenom) $($user.nom) ajouté au groupe $nomGroupe." -ForegroundColor Green
}

# Affiche un rapport synthétique des utilisateurs, licences et groupes en console
function Rapport-Synthetique {
    $users = Charger-Json 'users.json'
    if (-not $users) { Write-Host "Aucun utilisateur."; return }
    $table = $users | Select-Object nom, prenom, email, licence, @{Name='Groupes';Expression={($_.groupes -join ', ')}}
    $table | Format-Table -AutoSize
}

# Exporte le rapport synthétique dans un fichier CSV
function Exporter-RapportCSV {
    $users = Charger-Json 'users.json'
    if (-not $users) { Write-Host "Aucun utilisateur à exporter."; return }
    $table = $users | Select-Object nom, prenom, email, licence, @{Name='Groupes';Expression={($_.groupes -join ', ')}}
    $table | Export-Csv -Path 'rapport.csv' -NoTypeInformation -Encoding UTF8
    Write-Host "Rapport exporté dans rapport.csv" -ForegroundColor Green
}

# Menu principal interactif
function Menu {
    do {
        Write-Host "\n--- Gestion Locale ---"
        Write-Host "1. Ajouter un utilisateur"
        Write-Host "2. Créer un groupe"
        Write-Host "3. Attribuer un utilisateur à un groupe"
        Write-Host "4. Générer un rapport synthétique"
        Write-Host "5. Exporter le rapport au format CSV"
        Write-Host "0. Quitter"
        $choix = Read-Host "Choix"
        switch ($choix) {
            '1' { Ajouter-Utilisateur }
            '2' { Creer-Groupe }
            '3' { Attribuer-Utilisateur-Groupe }
            '4' { Rapport-Synthetique }
            '5' { Exporter-RapportCSV }
            '0' { Write-Host "Au revoir !"; break }
            default { Write-Host "Choix invalide." -ForegroundColor Red }
        }
    } while ($choix -ne '0')
}

# Lancement du menu principal
Menu
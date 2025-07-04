# maintenance-securite.ps1
# Mini système de gestion des règles de sécurité réseau et d'audit local (affichage réaliste)

# Variable globale pour stocker les règles de pare-feu créées pendant l'exécution du script
$Global:reglesPareFeu = @()

# Affiche les profils de pare-feu actifs (Domain, Private, Public)
function Afficher-ProfilsActifs {
    Write-Host "Affichage des profils actifs (NetFirewallProfile) :"
    Write-Host "Command: Get-NetFirewallProfile | Where-Object { \\$_ .Enabled -eq 'True' }"
    Write-Host "\nExemple de sortie :"
    $profils = @(
        @{ Name = 'Domain'; Enabled = $true },
        @{ Name = 'Private'; Enabled = $true },
        @{ Name = 'Public'; Enabled = $false }
    )
    $profils | Where-Object { $_.Enabled } | Format-Table Name, Enabled
}

# Crée une règle de pare-feu bloquant les connexions sortantes sur un port TCP donné
function Creer-ReglePareFeu {
    $port = Read-Host "Port TCP à bloquer (ex: 4444)"
    $nomRegle = "Blocage-TCP-$port"
    Write-Host "Création d'une règle de pare-feu pour bloquer les connexions sortantes sur le port $port :"
    Write-Host "Command: New-NetFirewallRule -DisplayName '$nomRegle' -Direction Outbound -Action Block -Protocol TCP -LocalPort $port"
    # Ajoute la règle à la variable globale (en mémoire)
    $Global:reglesPareFeu += [PSCustomObject]@{
        Nom = $nomRegle
        Port = $port
        Direction = 'Outbound'
        Action = 'Block'
        Protocol = 'TCP'
    }
    Write-Host "Règle enregistrée."
}

# Affiche toutes les règles de pare-feu créées pendant la session
function Verifier-Regle {
    if (-not $Global:reglesPareFeu -or $Global:reglesPareFeu.Count -eq 0) {
        Write-Host "Aucune règle trouvée." -ForegroundColor Yellow
        return
    }
    Write-Host "Vérification des règles de pare-feu (Get-NetFirewallRule) :"
    Write-Host "Command: Get-NetFirewallRule | Where-Object { \\$_ .DisplayName -like 'Blocage-TCP-*' }"
    $Global:reglesPareFeu | Format-Table Nom, Port, Direction, Action, Protocol
}

# Supprime une règle de pare-feu de la variable globale (en mémoire)
function Supprimer-Regle {
    if (-not $Global:reglesPareFeu -or $Global:reglesPareFeu.Count -eq 0) {
        Write-Host "Aucune règle à supprimer." -ForegroundColor Yellow
        return
    }
    $Global:reglesPareFeu | Format-Table Nom, Port
    $nomRegle = Read-Host "Nom de la règle à supprimer (ex: Blocage-TCP-4444)"
    if ($Global:reglesPareFeu | Where-Object { $_.Nom -eq $nomRegle }) {
        $Global:reglesPareFeu = $Global:reglesPareFeu | Where-Object { $_.Nom -ne $nomRegle }
        Write-Host "Suppression de la règle $nomRegle :"
        Write-Host "Command: Remove-NetFirewallRule -DisplayName '$nomRegle'"
        Write-Host "Règle supprimée."
    } else {
        Write-Host "Règle non trouvée." -ForegroundColor Red
    }
}

# Menu principal interactif pour la gestion des règles de sécurité
function Menu {
    do {
        Write-Host "\n--- Maintenance & Sécurité ---"
        Write-Host "1. Afficher les profils actifs (NetFirewallProfile)"
        Write-Host "2. Créer une règle de pare-feu (blocage TCP sortant)"
        Write-Host "3. Vérifier la règle de pare-feu"
        Write-Host "4. Supprimer une règle de pare-feu"
        Write-Host "0. Quitter"
        $choix = Read-Host "Choix"
        switch ($choix) {
            '1' { Afficher-ProfilsActifs }
            '2' { Creer-ReglePareFeu }
            '3' { Verifier-Regle }
            '4' { Supprimer-Regle }
            '0' { Write-Host "Fin du programme."; break }
            default { Write-Host "Choix invalide." -ForegroundColor Red }
        }
    } while ($choix -ne '0')
}

# Lancement du menu principal
Menu

## Nom du workflow affiché dans GitHub
name: Mise à jour des temps d'attente aux urgences au Québec

## Déclencheurs du workflow
on:

## Exécution automatique selon un horaire
  schedule:
  
 ## Exécute le workflow tous les jours à 12 h 30 UTC
    - cron: '30 12 * * *' 
    
## Permet un lancement manuel depuis GitHub
  workflow_dispatch:
  
## Autorisations accordées au workflow
permissions:

## Autorise la modification des fichiers du dépôt
  contents: write
  
## Liste des tâches du workflow
jobs:

## Nom de la tâche principale
  update:
  
## Utilise un serveur Ubuntu GitHub
    runs-on: ubuntu-latest
    
## Étapes à exécuter dans la tâche
    steps:
    
## Télécharge le contenu du dépôt
      - uses: actions/checkout@v4
      
## Installe R sur le serveur GitHub
      - uses: r-lib/actions/setup-r@v2
      
## Installe les packages R nécessaires
      - uses: r-lib/actions/setup-r-dependencies@v2

## Paramètres de l'étape précédente
        with:
        
  ## Liste des packages à installer
          packages: |
          
  ## Collection d'outils de manipulation de données
            any::tidyverse
            
  ## Outils de scraping Web
            any::rvest
            
  ## Outils de gestion des dates
            any::lubridate

  ## Nom de l'étape
      - name: Exécuter le script
      
      # Lance le script R
        run: Rscript scripts/update_urgences.R
        
  ## Nom de l'étape
      - name: Commit et push
        
  ## Exécute plusieurs commandes Git
        run: |
        
  ## Configure le nom de l'utilisateur Git
          git config user.name "github-actions[bot]"
          
   ## Configure l'adresse courriel Git
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

  ## Ajoute le fichier CSV aux modifications Git
          git add data/urgences_rss.csv

  ## Vérifie si des modifications sont présentes
          git diff --staged --quiet || \
          
  # Crée un commit si le fichier a changé
          git commit -m "Mise à jour quotidienne des temps d'attente aux urgences au Québec"

  # Envoie les modifications vers GitHub
          git push

Je travaille dans l'IDE RStudio avec le langage R. Je souhaite créer un workflow GitHub Actions automatisé pour collecter, nettoyer et centraliser des données de santé publique provenant de plusieurs liens web (un lien par région).

Voici le contexte et mes besoins précis :

1. Sources des données :
   - Il y a plusieurs liens web (un par région administrative du Québec, par exemple).
   - Chaque lien fournit des données quotidiennes avec un historique glissant des 30 derniers jours (les données se mettent à jour chaque jour).

2. Objectif de structuration des données (Format Tidy Data) :
   Je souhaite un script R qui parcourt tous les liens régionaux, extrait les informations, et les regroupe dans un **unique grand tableau (data frame)** propre avec exactement cette structure en colonnes :
   - Une colonne pour la **date** (les lignes représentant les différentes dates).
   - Une colonne pour le **nom de la région** (ex: "Outaouais").
   - Une colonne pour le **numéro de région socio-sanitaire** (ex: "RSS07").
   - Une colonne pour le **temps d'attente** (ex: "6 heures" ou la valeur numérique correspondante).

3. Objectif du GitHub Action :
   - S'exécuter automatiquement à chaque jour (via un cron job).
   - Lancer le script R pour récupérer les dernières données des 30 jours pour toutes les régions.
   - Mettre à jour un fichier CSV centralisé dans le dépôt (en ajoutant les nouvelles journées / évitant les doublons).
   - Faire un commit et un push automatique de ce fichier CSV mis à jour sur GitHub.

Peux-tu me fournir :
1. Le code R (en utilisant par exemple `tidyverse`, `httr2` ou `rvest` selon la nature des liens) pour automatiser la récupération, la fusion et le formatage de ces données multi-régions ?
2. Le fichier de configuration YAML pour le GitHub Action (`.github/workflows/...`) qui exécute ce script quotidiennement ?


Voici les différents liens:

Abitibi-Témiscamingue : https://www.indexsante.ca/urgences/abitibi-temiscamingue.php
Bas-Saint-Laurent : https://www.indexsante.ca/urgences/bas-saint-laurent.php
Capitale-Nationale : https://www.indexsante.ca/urgences/capitale-nationale.php
Chaudière-Appalaches : https://www.indexsante.ca/urgences/chaudiere-appalaches.php
Côte-Nord : https://www.indexsante.ca/urgences/cote-nord.php
Estrie : https://www.indexsante.ca/urgences/estrie.php
Gaspésie-Îles-de-la-Madeleine : https://www.indexsante.ca/urgences/gaspesie-iles-de-la-madeleine.php
Lanaudière : https://www.indexsante.ca/urgences/lanaudiere.php
Laurentides : https://www.indexsante.ca/urgences/laurentides.php
Laval : https://www.indexsante.ca/urgences/laval.php
Mauricie et Centre-du-Québec : https://www.indexsante.ca/urgences/mauricie-et-centre-du-quebec.php
Montérégie : https://www.indexsante.ca/urgences/monteregie.php
Montréal : https://www.indexsante.ca/urgences/montreal.php
Nord-du-Québec : https://www.indexsante.ca/urgences/nord-du-quebec.php
Outaouais : https://www.indexsante.ca/urgences/outaouais.php
Saguenay-Lac-Saint-Jean : https://www.indexsante.ca/urgences/saguenay-lac-saint-jean.php
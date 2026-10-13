library(tidyverse)
library(rvest)
library(lubridate)
library(stringr)


# Définit un délai maximal de 120 secondes pour les connexions Web
# afin d'éviter qu'un téléchargement échoue si le site répond lentement.
options(timeout = 120)


# Création du dossier data


dir.create("data", showWarnings = FALSE)

csv_file <- "data/urgences_rss.csv"


# Liste des régions


regions <- tribble( # Crée un tableau ligne par ligne (version "lisible" de tibble).
  ~rss, ~region, ~url,
  "RSS08", "Abitibi-Témiscamingue", "https://www.indexsante.ca/urgences/abitibi-temiscamingue.php",
  "RSS01", "Bas-Saint-Laurent", "https://www.indexsante.ca/urgences/bas-saint-laurent.php",
  "RSS03", "Capitale-Nationale", "https://www.indexsante.ca/urgences/capitale-nationale.php",
  "RSS12", "Chaudière-Appalaches", "https://www.indexsante.ca/urgences/chaudiere-appalaches.php",
  "RSS09", "Côte-Nord", "https://www.indexsante.ca/urgences/cote-nord.php",
  "RSS05", "Estrie", "https://www.indexsante.ca/urgences/estrie.php",
  "RSS11", "Gaspésie-Îles-de-la-Madeleine", "https://www.indexsante.ca/urgences/gaspesie-iles-de-la-madeleine.php",
  "RSS14", "Lanaudière", "https://www.indexsante.ca/urgences/lanaudiere.php",
  "RSS15", "Laurentides", "https://www.indexsante.ca/urgences/laurentides.php",
  "RSS13", "Laval", "https://www.indexsante.ca/urgences/laval.php",
  "RSS04", "Mauricie et Centre-du-Québec", "https://www.indexsante.ca/urgences/mauricie-et-centre-du-quebec.php",
  "RSS16", "Montérégie", "https://www.indexsante.ca/urgences/monteregie.php",
  "RSS06", "Montréal", "https://www.indexsante.ca/urgences/montreal.php",
  "RSS10", "Nord-du-Québec", "https://www.indexsante.ca/urgences/nord-du-quebec.php",
  "RSS07", "Outaouais", "https://www.indexsante.ca/urgences/outaouais.php",
  "RSS02", "Saguenay-Lac-Saint-Jean", "https://www.indexsante.ca/urgences/saguenay-lac-saint-jean.php"
)


# Conversion de l'heure en numérique
# Exemple : 4h35 -> 4.5833


convertir_heures <- function(x){
  
  heures <- str_extract(x, "^[0-9]+")
  minutes <- str_extract(x, "(?<=h)[0-9]+") # Extrait les chiffres après la lettre "h" (les minutes).
  
  as.numeric(heures) +
    as.numeric(minutes) / 60
  
}


# Fonction d'extraction


extraire_region <- function(url, region, rss){
  
  message("Lecture : ", region) # C'est facultatif, mais ça nous permet de suivre ce qui se passe dans la console
  
  tryCatch({ # Exécute du code et intercepte les erreurs pour éviter l'arrêt du programme
    
    page <- read_html(url)
    
    # Le site mélange les deux graphiques dans la même classe HTML (pourcentage d'occupation des civières 
    # et durée moyenne dans les salles d'attente). Ce qui nous intéresse c'est la durée moyenne dans les salles d'attente.
    # Ainsi, on conserve uniquement les 30 valeurs de temps d'attente.
    
    valeurs <- page %>%
      html_elements(".colonne-pourcentage") %>%  # Sélectionne les éléments HTML contenant les valeurs 
      html_text2()  # et extrait leur texte
    
    if(length(valeurs) < 60){ # On vérifie que les 60 valeurs ont été trouvées avant de poursuivre
      
      warning(
        paste(
          region,
          "- moins de 60 valeurs détectées."
        )
      )
      
      return(NULL)
      
    }
    
    
    # Les 30 premières = occupation des civières (%)
    # Les 30 dernières = temps d'attente dans les urgences
   
    
    temps_attente <- valeurs[31:60]
    
    dates <- page %>%  
      html_elements("div") %>% # div : Élément HTML générique utilisé pour structurer le contenu d'une page Web
      html_text2() %>%
      str_subset("^[0-9]{2}-[0-9]{2}$") # Extrait les dates au format jj-mm à partir du contenu HTML de la page
    
    dates <- dates[1:30] # Les dates sont les mêmes pour le taux d'occupation des civières
    
    annee_courante <- year(Sys.Date()) # Récupère l'année actuelle à partir de la date du jour
    
    tibble(  # Construit une date complète (jour-mois-année) à partir des dates extraites et de l'année courante 
      date = dmy(
        paste0(  # Concatène du texte sans séparateur
          dates,
          "-",
          annee_courante
        )
      ),
      region = region,
      rss = rss,
      temps_attente = temps_attente,
      temps_attente_heures =
        convertir_heures(temps_attente)
    )
    
  },
  error = function(e){ # Affiche un message d'erreur sans interrompre l'exécution du script
    
    message(
      "Erreur pour ",
      region,
      " : ",
      e$message
    )
    
    NULL
    
  })
  
}


# Télécharger toutes les régions


donnees_nouvelles <- pmap_dfr( # Fonction pour retourner un data frame
  regions,
  extraire_region
)


# Vérification


if(nrow(donnees_nouvelles) == 0){
  
  stop(
    "Aucune donnée récupérée."
  )
  
}


# Charger l'historique


if(file.exists(csv_file)){ # Vérifie si le fichier CSV historique existe et le charge (les données antérieures)
  
  historique <- read_csv(
    csv_file,
    show_col_types = FALSE
  )
  
} else { # Crée un tableau vide pour initialiser l'historique s'il n'existe pas encore (on fait ceci par robustesse)
  
  historique <- tibble(
    date = as.Date(character()),
    region = character(),
    rss = character(),
    temps_attente = character(),
    temps_attente_heures = numeric()
  )
  
}


# Fusion historique + nouvelles données


final <- bind_rows(
  historique,
  donnees_nouvelles
)


# Suppression des doublons
# clé = date + rss

# Si la même date est récupérée plusieurs fois pour une région, une seule ligne est conservée

final <- final %>%
  distinct(
    date,
    rss,
    .keep_all = TRUE  # Supprime les doublons date + RSS tout en conservant les autres colonnes.
  )


# Trie les données par région (RSS) puis par date chronologique.


final <- final %>%
  arrange(
    rss,
    date
  )


# Sauvegarde

write_csv(
  final,
  csv_file
)

# Messages utiles

message("Nombre de lignes : ", nrow(final))

message("Nombre de régions : ",
        n_distinct(final$rss))

message("CSV mis à jour : ", csv_file)


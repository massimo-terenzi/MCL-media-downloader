#' Download Multimedia Files
#'
#' This function downloads multimedia files from a list of URLs specified in a CSV file.
#' @param csv_file The path to the CSV file containing multimedia URLs.
#' @param output_dir The directory where the multimedia files will be saved.
#' @return A dataframe mapping the IDs from the CSV to the downloaded files.
#' @export
library(httr)
library(jsonlite)

# Impostazione dell'User-Agent e dei Cookie
user_agent_string <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
cookies <- readLines("path/to/your_cookies.txt")  # Percorso ai cookie

# Funzione per seguire i reindirizzamenti e scaricare il contenuto
download_content <- function(initial_url, output_file) {
  # Fai una richiesta all'URL iniziale
  response <- GET(initial_url, add_headers(`User-Agent` = user_agent_string), set_cookies(file = cookies), config(followlocation = FALSE))
  
  # Verifica se c'è un reindirizzamento
  if (http_status(response)$category == "redirection") {
    # Ottieni il nuovo URL dal campo "Location" nelle intestazioni
    next_url <- headers(response)$location
    # Aspetta un attimo per simulare il comportamento del browser
    Sys.sleep(2)
    # Chiamata ricorsiva per seguire il reindirizzamento
    download_content(next_url, output_file)
  } else if (http_status(response)$category == "success") {
    # Se la risposta è un successo, salva il contenuto
    writeBin(content(response, "raw"), output_file)
    cat("Download completato:", output_file, "\n")
  } else {
    cat("Errore durante il download da:", initial_url, "\n")
  }
}

# Funzione principale per gestire il processo di download
download_multimedia <- function(csv_file, output_dir = "downloaded_multimedia", cookies_file = NULL) {
  # Carica il file CSV
  data <- read.csv(csv_file)
  
  # Crea la directory di output se non esiste
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Carica i cookie se forniti
  if (!is.null(cookies_file)) {
    cookies <- readLines(cookies_file)
    cookies <- paste(cookies, collapse = "; ")
  }
  
  # Itera su ogni riga del CSV
  for (i in 1:nrow(data)) {
    multimedia_json <- data$multimedia[i]
    
    if (!is.null(multimedia_json) && !is.na(multimedia_json) && nzchar(multimedia_json)) {
      # Parse JSON
      multimedia_list <- fromJSON(multimedia_json, flatten = TRUE)
      
      # Verifica che il risultato sia una lista di elementi
      if (is.data.frame(multimedia_list)) {
        for (j in 1:nrow(multimedia_list)) {
          link <- multimedia_list[j, "url"]
          file_id <- multimedia_list[j, "id"]
          file_type <- multimedia_list[j, "type"]
          
          # Estrai l'estensione del file dall'URL
          file_extension <- tools::file_ext(link)
          
          # Determina il tipo di file, con fallback a un tipo generico
          if (file_extension == "") {
            file_extension <- ifelse(file_type == "photo", "jpg", "mp4")
          }
          
          # Genera il nome del file di output
          output_file <- file.path(output_dir, paste0(file_id, "_", file_type, ".", file_extension))
          
          # Esegui il download del contenuto
          download_content(link, output_file)
        }
      }
    }
  }
}

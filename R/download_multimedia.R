library(RSelenium)
library(httr)

download_multimedia <- function(csv_file, output_dir = "downloaded_multimedia", cookies_file) {
  # Crea la directory di output se non esiste
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Legge i dati dal file CSV
  data <- read.csv(csv_file, stringsAsFactors = FALSE)

  # Configura Selenium
  rD <- rsDriver(browser = "chrome", port = 4545L, verbose = FALSE)
  remDr <- rD$client

  # Aggiungi i cookie
  cookies <- readLines(cookies_file)
  cookies <- strsplit(cookies, "=")
  for (cookie in cookies) {
    remDr$addCookie(name = cookie[[1]], value = cookie[[2]])
  }

  # Percorre ogni riga del CSV
  for (i in 1:nrow(data)) {
    multimedia_json <- data$multimedia[i]
    if (!is.na(multimedia_json) && nzchar(multimedia_json)) {
      multimedia_items <- jsonlite::fromJSON(multimedia_json, flatten = TRUE)
      for (item in multimedia_items) {
        link <- item$url
        file_id <- item$id
        file_type <- item$type
        if (!is.null(link) && nzchar(link)) {
          # Imposta il nome del file da salvare
          file_name <- paste0(output_dir, "/", file_id, ".", file_type)

          # Vai al link con Selenium
          remDr$navigate(link)
          Sys.sleep(5)  # Attendi che il download inizi

          # Verifica il download
          # Questo passaggio varia a seconda del sito e delle impostazioni del browser
          # Potrebbe essere necessario monitorare una directory di download o
          # verificare una risposta specifica.

          message(paste("Downloaded:", file_name))
        }
      }
    } else {
      warning(paste("Invalid item structure in row:", i))
    }
  }

  # Chiude il browser
  remDr$close()
  rD$server$stop()
}

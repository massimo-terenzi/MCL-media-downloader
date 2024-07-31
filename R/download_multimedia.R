#' Download Multimedia Files
#'
#' This function downloads multimedia files from a list of URLs specified in a CSV file.
#' @param csv_file The path to the CSV file containing multimedia URLs.
#' @param output_dir The directory where the multimedia files will be saved.
#' @return A dataframe mapping the IDs from the CSV to the downloaded files.
#' @export
library(jsonlite)

download_multimedia <- function(csv_file, output_dir = "downloaded_multimedia") {
  # Load the CSV file
  data <- read.csv(csv_file)
  
  # Create the output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Initialize a list to track downloaded files
  log_list <- list()
  
  # Iterate over each row
  for (i in 1:nrow(data)) {
    # Parse the JSON content in the Multimedia column
    multimedia_json <- data$Multimedia[i]
    multimedia_list <- fromJSON(multimedia_json, flatten = TRUE)
    
    # Iterate over each multimedia item in the parsed list
    for (item in multimedia_list) {
      link <- item$url
      file_id <- item$id
      file_type <- item$type
      file_name <- paste0(output_dir, "/", file_id, "_", file_type, ".jpg")
      
      # Check if the link is valid and download the file
      if (!is.na(link) && nzchar(link)) {
        tryCatch({
          download.file(link, file_name)
          log_list[[length(log_list) + 1]] <- data.frame(id = file_id, file = file_name)
        }, error = function(e) {
          warning(paste("Error downloading:", link, "-", e$message))
        })
      } else {
        warning(paste("Invalid or missing link for ID:", file_id))
      }
    }
  }
  
  # Convert the list to a dataframe
  log_df <- do.call(rbind, log_list)
  
  # Save the log to a CSV file
  write.csv(log_df, file.path(output_dir, "download_log.csv"), row.names = FALSE)
  
  return(log_df)
}

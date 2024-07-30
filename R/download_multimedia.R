#' Download Multimedia Files
#'
#' This function downloads multimedia files from a list of URLs specified in a CSV file.
#' @param csv_file The path to the CSV file containing multimedia URLs.
#' @param output_dir The directory where the multimedia files will be saved.
#' @return A dataframe mapping the IDs from the CSV to the downloaded files.
#' @export
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
    # Extract the multimedia link and ID
    link <- data$Multimedia[i]
    file_id <- data$id[i] # or another unique identifier
    file_name <- paste0(output_dir, "/", file_id, "_", basename(link))
    
    # Download the file
    tryCatch({
      download.file(link, file_name)
      log_list[[i]] <- data.frame(id = file_id, file = file_name)
    }, error = function(e) {
      warning(paste("Error downloading:", link))
    })
  }
  
  # Convert the list to a dataframe
  log_df <- do.call(rbind, log_list)
  
  # Save the log to a CSV file
  write.csv(log_df, file.path(output_dir, "download_log.csv"), row.names = FALSE)
  
  return(log_df)
}
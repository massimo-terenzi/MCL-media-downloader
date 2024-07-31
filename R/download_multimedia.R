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
  
  # Check if the column 'multimedia' exists in the data
  if (!"multimedia" %in% names(data)) {
    stop("The column 'multimedia' does not exist in the provided CSV file.")
  }
  
  # Create the output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
  
  # Initialize a list to track downloaded files
  log_list <- list()
  
  # Iterate over each row
  for (i in 1:nrow(data)) {
    # Get the content from the 'multimedia' column
    multimedia_json <- data$multimedia[i]
    
    # Check if the JSON string is not NULL, NA or empty
    if (!is.null(multimedia_json) && !is.na(multimedia_json) && nzchar(multimedia_json)) {
      multimedia_list <- fromJSON(multimedia_json, flatten = TRUE)
      
      # Iterate over each multimedia item in the parsed list
      for (item in multimedia_list) {
        link <- item$url
        file_id <- item$id
        file_type <- item$type
        
        # Determine the file extension from the URL, if possible
        file_extension <- tools::file_ext(link)
        
        # Fallback to a generic extension if none can be determined
        if (file_extension == "") {
          if (file_type == "photo") {
            file_extension <- "jpg"
          } else if (file_type == "video") {
            file_extension <- "mp4"
          } else {
            file_extension <- "dat" # Default extension if type is unknown
          }
        }
        
        # Check if the link is valid
        if (!is.null(link) && !is.na(link) && nzchar(link)) {
          file_name <- paste0(output_dir, "/", file_id, "_", file_type, ".", file_extension)
          
          # Download the file
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
    } else {
      warning(paste("Invalid or missing JSON content for row:", i))
    }
  }
  
  # Convert the list to a dataframe
  log_df <- do.call(rbind, log_list)
  
  # Save the log to a CSV file
  write.csv(log_df, file.path(output_dir, "download_log.csv"), row.names = FALSE)
  
  return(log_df)
}

#' Download Multimedia Files
#'
#' This function downloads multimedia files from a list of URLs specified in a CSV file. The CSV is obtained from the downloadable public data in the Meta Content Library (MCL) and contains URLs for various media items.
#' @param csv_file The path to the CSV file containing multimedia URLs.
#' @param output_dir The directory where the multimedia files will be saved.
#' @param cookies_file The path to the cookies file used for authentication.
#' @return A dataframe mapping the IDs from the CSV to the downloaded files.
#' @export
library(httr)
library(jsonlite)

download_multimedia <- function(csv_file, output_dir = "downloaded_multimedia", cookies_file = NULL) {
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
  
  # Load cookies if provided
  cookies <- NULL
  if (!is.null(cookies_file)) {
    cookies <- readLines(cookies_file)
    cookies <- paste(cookies, collapse = "; ")
  }
  
  # Define the User-Agent string
  user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
  
  # Initialize a list to track downloaded files
  log_list <- list()
  
  # Iterate over each row
  for (i in 1:nrow(data)) {
    # Get the content from the 'multimedia' column
    multimedia_json <- data$multimedia[i]
    
    # Check if the JSON string is not NULL, NA or empty
    if (!is.null(multimedia_json) && !is.na(multimedia_json) && nzchar(multimedia_json)) {
      # Parse the JSON content
      multimedia_list <- fromJSON(multimedia_json, flatten = TRUE)
      
      # Ensure the result is a list of items
      if (!is.data.frame(multimedia_list)) {
        warning(paste("Invalid JSON format in row:", i))
        next
      }
      
      # Iterate over each row in the data.frame
      for (j in 1:nrow(multimedia_list)) {
        link <- multimedia_list[j, "url"]
        file_id <- multimedia_list[j, "id"]
        file_type <- multimedia_list[j, "type"]
        
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
            if (!is.null(cookies)) {
              # Include the cookies and User-Agent in the request header if provided
              response <- GET(link, add_headers(Cookie = cookies, `User-Agent` = user_agent))
              if (status_code(response) == 200) {
                writeBin(content(response, "raw"), file_name)
                log_list[[length(log_list) + 1]] <- data.frame(id = file_id, file = file_name)
              } else {
                warning(paste("Failed to download:", link, "-", status_code(response)))
              }
            } else {
              # Attempt download without cookies
              response <- GET(link, add_headers(`User-Agent` = user_agent))
              if (status_code(response) == 200) {
                writeBin(content(response, "raw"), file_name)
                log_list[[length(log_list) + 1]] <- data.frame(id = file_id, file = file_name)
              } else {
                warning(paste("Failed to download:", link, "-", status_code(response)))
              }
            }
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

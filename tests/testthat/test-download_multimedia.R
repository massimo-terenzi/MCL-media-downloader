library(testthat)
library(MCLMediaDownloader)

test_that("download_multimedia works as expected", {
  # Path to a sample CSV file (replace with a valid path for actual tests)
  sample_csv <- "path/to/sample.csv"
  # Directory for downloaded files
  output_dir <- "test_downloads"
  # Path to the cookies file (replace with a valid path for actual tests)
  cookies_file <- "path/to/cookies.txt"
  
  # Run the function
  result <- download_multimedia(sample_csv, output_dir, cookies_file)
  
  # Check if the result is a data.frame
  expect_s3_class(result, "data.frame")
  
  # Check if the result has more than zero rows
  expect_true(nrow(result) > 0)
  
  # Check if the output directory exists
  expect_true(dir.exists(output_dir))
  
  # Check if the download log file exists
  expect_true(file.exists(file.path(output_dir, "download_log.csv")))
  
  # Additional checks for specific downloaded files (optional)
  # for (row in 1:nrow(result)) {
  #   expect_true(file.exists(result$file[row]))
  # }
})

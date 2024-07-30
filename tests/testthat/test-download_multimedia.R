library(testthat)
library(MultimediaDownloader)

test_that("download_multimedia works as expected", {
  # Test with a sample CSV file
  sample_csv <- "path/to/sample.csv"
  output_dir <- "test_downloads"
  
  result <- download_multimedia(sample_csv, output_dir)
  
  expect_true(nrow(result) > 0)
  expect_true(file.exists(file.path(output_dir, "download_log.csv")))
})
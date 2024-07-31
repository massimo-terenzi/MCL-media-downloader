# MCL-media-downloader

MCL-media-downloader is an R package designed to download multimedia content from the Meta Content Library (MCL) and associate it with the original metadata.

## Installation

To install the package, you can use the `devtools` package to install it directly from GitHub:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install MCLDownloader from GitHub
devtools::install_github("massimo-terenzi/MCLdownloader")
```

You also will need the libraries `jsonlite` and `httr`:

```r
# Install jsonlite and httr if you haven't already
install.packages("devtools")
install.packages("httr")

# Load jsonlite
library(jsonlite)
library(httr)
```

## Usage

After installing the package, you can use the `download_multimedia` function to download multimedia files from a CSV file containing URLs.

### Authentication via Cookies

To access protected content, such as media from Facebook, users need to provide authentication cookies. Here’s how to do it:

1. **login to Facebook**: log in to your Facebook account using your web browser.
1. **export cookies**: Use a browser extension like “Cookie Monster” or similar to export your cookies. Save the cookies to a file in .txt format.
1. **provide the cookies file**: Use the path to the cookies file as an argument in the download_multimedia function.

### Example

```r
library(MCLdownloader)
library(jsonlite)

# Define the path to your CSV file and output directory
csv_file <- "path/to/yourfile.csv"
output_dir <- "downloaded_content"
cookies_file <- "path/to/cookies.txt"

# Download the multimedia content
log_df <- download_multimedia(csv_file, output_dir)

# Check the log dataframe
print(log_df)
```

### Arguments

* csv_file: the path to the CSV file that contains the multimedia URLs. This file should have at least two columns: one for the IDs (id) and one for the URLs (Multimedia).
* output_dir: the directory where the downloaded files will be saved. The default is "downloaded_multimedia".

## Example

```r
# Example usage
download_multimedia("example.csv", "media_downloads")
```

This will download all the multimedia content listed in example.csv and save the files in the media_downloads directory.

## Contributing

If you'd like to contribute to the package, please fork the repository and submit a pull request. Feel free to report issues or suggest features.

## License

This package is licensed under the MIT License. See the LICENSE file for more details.

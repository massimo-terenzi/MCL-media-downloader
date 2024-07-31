\name{download_multimedia}
\alias{download_multimedia}
\title{Download Multimedia Files from a CSV}
\description{
This function downloads multimedia content listed in a CSV file using URLs
provided in a specified column. It supports authentication via cookies.
}
\usage{
download_multimedia(csv_file, output_dir = "downloaded_multimedia", cookies_file = NULL)
}
\arguments{
\item{csv_file}{A string specifying the path to the CSV file containing the multimedia URLs.}
\item{output_dir}{A string specifying the directory where the downloaded files will be saved. Default is "downloaded_multimedia".}
\item{cookies_file}{A string specifying the path to the text file containing the authentication cookies. Default is NULL.}
}
\value{
A data.frame logging the downloaded files, including their IDs and file paths.
}
\examples{
\dontrun{
download_multimedia("path/to/multimedia_links.csv", "media_downloads", "path/to/cookies.txt")
}
}
\keyword{utilities}

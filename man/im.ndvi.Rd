\name{im.ndvi {imageRy}}
\alias{im.ndvi}
\title{
Calculate the NDVI index from a given SpatRaster 
}
\description{
This function calculates the Normalized Difference Vegetation Index (NDVI) from a SpatRaster object.
}
\usage{
im.ndvi(x, nir, red)
}
\arguments{
  \item{x}{
A SpatRaster
}
  \item{nir}{
A number that must correspond to the position of the NIR band in x.
}
  \item{red}{
A number that must correspond to the position of the Red band in x.
}
}
\details{
NDVI = \frac{NIR - Red}{NIR + Red} 
where NIR is the near infrared band and Red is the red band. 
}
\value{
SpatRaster object
}
\references{
Check im.import(), im.ggplot() 
}
\author{
Duccio Rocchini
}
\seealso{
https://github.com/ducciorocchini/imageRy/
}
\examples{
x <- im.import("sentinel.dolomites")
im.ndvi(x, 4, 3)

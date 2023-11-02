\name{im.dvi {imageRy}}
\alias{im.dvi}
\title{
Calculate the DVI of a given SpatRaster 
}
\description{
This function calculates the Difference Vegetation Index (DVI) from a SpatRaster object.
}
\usage{
im.dvi(x, nir, red)
}
\arguments{
  \item{x}{
A SpatRaster object
}
  \item{nir}{
A number that must correspond to the position of the NIR band in x.
}
  \item{red}{
A number that must correspond to the position of the Red band in x.
}
}
\details{
DVI = (NIR - Red)
where NIR are spectral reflectance values for near infra-red, and Red for the red band.
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
im.dvi(x, 4,3)

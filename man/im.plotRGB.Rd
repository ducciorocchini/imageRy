\name{im.plotRGB{imageRy}}
\alias{im.plotRGB}
\title{
RGB plot
}
\description{
This function plots a RGB image from a SpatRaster object
}
\usage{
im.plotRGB(x, r = 1, g = 2, b = 3)
}
\arguments{
  \item{x}{SpatRaster object}
  \item{r}{Numeric. Position of the band to be used for the Red channell.}
  \item{g}{Numeric. Position of the band to be used for the Green channell.}
  \item{b}{Numeric. Position of the band to be used for the Blue channell.}
}
\references{Check plotRGB() from raster package. Check im.plotRGB.auto() from imageRy package.
}
\author{
Duccio Rocchini, Elisa Thouverai
}
\seealso{
https://github.com/ducciorocchini/imageRy/
}
\examples{
GL15 <- im.import("greenland.2015.tif")
im.plotRGB(GL15,1,2,3)

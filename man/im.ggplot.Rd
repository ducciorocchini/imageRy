\name{im.ggplot{imageRy}}
\alias{im.ggplot}
\title{
Plot of an input SpatRaster using ggplot function
}
\description{
This function takes a SpatRaster input, and creates a ggplot of one layer with viridis palette.
}
\usage{
im.ggplot(x, layerfill = 1)
}
\arguments{
  \item{x}{a SpatRaster object}
  \item{layerfill}{the position of the layer to plot (default is 1)
}
}
\references{
Check ggplot() from ggplot2 package.
}
\author{
Ludovico Chieffallo, Duccio Rocchini
}
\note{
(The layerfill is a parameter that represents the layer of the raster data to be used for filling in the plot)
}

\seealso{
https://github.com/ducciorocchini/imageRy/
}
\examples{
GL15 <- im.import("greenland.2015.tif")
im.ggplot(GL15)

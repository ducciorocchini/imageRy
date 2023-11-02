\name{im.plotRGB.auto{imageRy}}
\alias{im.plotRGB.auto}
\title{
Generate a plot of bands 1,2,3 to the RGB values
}
\description{
This function maps the first three bands of the input on the three color channels, respectively R, G and B. 
The stretch will be linear by default. A plot will be visualized.
}
\usage{
im.plotRGB(x)
}
\arguments{
  \item{x}{the input SpatRaster}
}
\details{
Make sure to check the content (in terms of frequencies) of the bands of your SpatRaster, as you won't be able to change band input. To change band inputs, 
check im.plotRGB()
}
\references{ Check plotRGB() from raster package. Check im.plotRGB() from imageRy package.
}
\author{
Duccio Rocchini
}
\seealso{
https://github.com/ducciorocchini/imageRy/
}
\examples{
GL15 <- im.import("greenland.2015.tif")
im.plotRGB(GL15) 

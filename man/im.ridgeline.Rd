\name{im.ndvi {imageRy}}
\alias{im.ridgeline}
\title{
Calculate ridgeline plots from satellite imagery stacked data
}
\description{
This function calculates ridgeline plots from satellite imagery stacked data
  }
\usage{
im.ridgeline(im, scale, option) {
}
\arguments{
  \item{im}{
A SpatRaster
}
  \item{scale}{
The vertical scale of the ridgeline plot
}
  \item{option}{
The viridis legend type
}
}
\details{
Ridgeline plots are dramatically useful to investigate temporal change of satellite baased variables.
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
r <- im.import("greenland")
im.ridgeline(r, 2, "A") + theme_bw()

\name{im.import {imageRy}}
\alias{im.import}
\title{
Import an image as SpatRaster from imageRy package data.
}
\description{
This function imports a chosen image stored in the imageRy package.
}
\usage{
im.import(im)
}
\arguments{
  \item{im}{
string of an image file name (existing in the imageRy directory).
}
}
\details{
It is possible to pre-visualize existing files in imageRy package using im.list().
}
\value{
SpatRaster object
}
\references{
}
\author{
Elisa Thouverai, Duccio Rocchini
}
\seealso{
https://github.com/ducciorocchini/imageRy/
}
\examples{
im.import("greenland.2015.tif")

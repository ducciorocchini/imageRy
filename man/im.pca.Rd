\name{im.pca{imageRy}}
\alias{im.pca}
\title{
Principal component analysis of a SpatRaster.
}
\description{
This function performs the Principal Component Analisys (PCA) of a SpatRaster
}
\usage{
im.pca(input_image, n_samples = 100, n_components = 3)
}
\arguments{
  \item{input_image}{SpatRaster object
}
  \item{n_samples}{Numeric. Sample size.  
}
  \item{n_samples}{Numeric. Components number.
}
}
\value{
SpatRaster object
}
\references{
}
\author{
Ludovico Chieffallo, Elisa Thouverai, Duccio rocchini
}
\seealso{
https://github.com/ducciorocchini/imageRy/
}
\examples{
GL15 <- im.import("greenland.2015.tif")
im.pca(GL15) # will use defaults value for the other two arguments.

Certo. Salvalo come `man/im.loess.Rd`:

```rd
\name{im.loess}
\alias{im.loess}
\title{Scatterplot with a LOESS Smooth for Two Raster Layers}

\description{
Draws a scatterplot of paired pixel values from two single-layer
\code{SpatRaster} objects. A random sample of valid pixels is used to fit
a LOESS curve and calculate the Pearson correlation. The p-value is
calculated with the modified t-test for spatial correlation implemented
in \code{SpatialPack::modified.ttest}.
}

\usage{
im.loess(x, y, n = 1000, span = 0.75, seed = NULL,
         one_to_one_line = FALSE, reg_line = FALSE,
         xlab = NULL, ylab = NULL)
}

\arguments{
  \item{x}{A single-layer \code{SpatRaster} used for the x-axis.}

  \item{y}{A single-layer \code{SpatRaster} used for the y-axis. It must
  have the same grid and alignment as \code{x}.}

  \item{n}{Number of valid pixel pairs to sample. Defaults to \code{1000}.}

  \item{span}{The span parameter passed to the LOESS smoother. Smaller
  values produce a more flexible curve. Defaults to \code{0.75}.}

  \item{seed}{Optional random seed for reproducible sampling. Defaults to
  \code{NULL}.}

  \item{one_to_one_line}{If \code{TRUE}, adds a dashed 1:1 line. Defaults
  to \code{FALSE}.}

  \item{reg_line}{If \code{TRUE}, adds an OLS regression line and its
  confidence interval. Defaults to \code{FALSE}.}

  \item{xlab}{Optional label for the x-axis. If \code{NULL}, the name of
  \code{x} is used.}

  \item{ylab}{Optional label for the y-axis. If \code{NULL}, the name of
  \code{y} is used.}
}

\details{
The plot shows the sampled pixel pairs, a LOESS curve with its confidence
interval, and the Pearson correlation coefficient. The displayed
Dutilleul p-value accounts for spatial autocorrelation in the sampled
values.

The 1:1 line and the OLS regression line are added only when their
corresponding arguments are set to \code{TRUE}. The function requires the
\pkg{terra}, \pkg{ggplot2}, and \pkg{SpatialPack} packages.
}

\value{
A \code{ggplot} object.
}

\examples{
r <- terra::rast(
  nrows = 30, ncols = 30, nlyrs = 2,
  xmin = 0, xmax = 30, ymin = 0, ymax = 30
)
terra::values(r) <- cbind(rnorm(900), rnorm(900))
names(r) <- c("band1", "band2")

im.loess(
  r[[1]], r[[2]],
  n = 500,
  seed = 1,
  one_to_one_line = TRUE,
  reg_line = TRUE,
  xlab = "Band 1",
  ylab = "Band 2"
)
}

\seealso{
\code{\link[terra]{spatSample}},
\code{\link[SpatialPack]{modified.ttest}}
}

\keyword{hplot}
\keyword{spatial}
```

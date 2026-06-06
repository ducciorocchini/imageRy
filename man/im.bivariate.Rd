\name{im.bivariate}
\alias{im.bivariate}
\title{Bivariate map from two SpatRaster objects}
\description{
Creates a bivariate map from two \code{terra::SpatRaster} objects using
classes and colour palettes from the \pkg{biscale} package.
}

\usage{
im.bivariate(
  r1,
  r2,
  xlab,
  ylab,
  style = "quantile",
  dim = 3,
  custom_colors = "BlueOr",
  add_legend = TRUE,
  legend_x = 0.7,
  legend_y = 0.65,
  legend_width = 0.3,
  legend_height = 0.3,
  legend_size = 10,
  legend_label_size = 10
)
}

\arguments{
\item{r1}{A \code{terra::SpatRaster} object representing the first variable.}

\item{r2}{A \code{terra::SpatRaster} object representing the second variable.}

\item{xlab}{Character string. Label for the first variable and the x-axis of the legend.}

\item{ylab}{Character string. Label for the second variable and the y-axis of the legend.}

\item{style}{Character string indicating the classification style used to calculate
breaks. Passed to \code{biscale::bi_class}. Default is \code{"quantile"}.}

\item{dim}{Integer. Dimension of the bivariate palette. Common values are
\code{2}, \code{3}, or \code{4}. Default is \code{3}.}

\item{custom_colors}{Either a character string identifying a \pkg{biscale}
palette, such as \code{"BlueOr"}, or a vector of colours with length
\code{dim^2}.}

\item{add_legend}{Logical. If \code{TRUE}, a bivariate legend is added to the
plot. Default is \code{TRUE}.}

\item{legend_x}{Numeric. Horizontal position of the legend within the plot.
Default is \code{0.7}.}

\item{legend_y}{Numeric. Vertical position of the legend within the plot.
Default is \code{0.65}.}

\item{legend_width}{Numeric. Width of the legend relative to the plot.
Default is \code{0.3}.}

\item{legend_height}{Numeric. Height of the legend relative to the plot.
Default is \code{0.3}.}

\item{legend_size}{Numeric. Size of the bivariate legend. Default is \code{10}.}

\item{legend_label_size}{Numeric. Font size of the legend axis labels.
Default is \code{10}.}
}

\details{
The function checks that \code{r1} and \code{r2} are both
\code{terra::SpatRaster} objects and that they share the same coordinate
reference system, extent, resolution, number of rows and columns.

Raster values are converted to a data frame and classified using
\code{biscale::bi_class}. The resulting classes are plotted with
\pkg{ggplot2}. If \code{add_legend = TRUE}, a bivariate legend is added using
\pkg{cowplot}.
}

\value{
A \code{ggplot} object if \code{add_legend = FALSE}; otherwise, a
\code{cowplot} object containing the map and the bivariate legend.
}

\author{
Duccio Rocchini
}

\seealso{
\code{\link[biscale]{bi_class}},
\code{\link[biscale]{bi_scale_fill}},
\code{\link[biscale]{bi_legend}},
\code{\link[terra]{rast}},
\code{\link[ggplot2]{ggplot}}
}

\examples{
\dontrun{
library(terra)

r1 <- rast(system.file("ex/elev.tif", package = "terra"))
r2 <- r1 * 2

im.bivariate(
  r1 = r1,
  r2 = r2,
  xlab = "Elevation",
  ylab = "Second variable"
)

im.bivariate(
  r1 = r1,
  r2 = r2,
  xlab = "Elevation",
  ylab = "Second variable",
  dim = 3,
  custom_colors = "BlueOr",
  add_legend = FALSE
)
}
}

\keyword{spatial}
\keyword{hplot}

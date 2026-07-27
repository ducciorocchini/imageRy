\name{im.boxplot.layers2}
\alias{im.boxplot.layers2}
\title{Visualize raster value distributions across image layers}
\usage{
im.boxplot.layers2(
  input_image,
  density = TRUE,
  median_labels = FALSE,
  legend = FALSE,
  limits = NULL,
  custom_colors = NULL,
  friedman_test = FALSE
)
}
\arguments{
\item{input_image}{
A multi-layer \code{SpatRaster}. Each layer is displayed as a separate group
in the boxplot.
}

\item{density}{
Logical. If \code{TRUE}, adds a half-eye density distribution for each layer.
Defaults to \code{TRUE}.
}

\item{median_labels}{
Logical. If \code{TRUE}, adds text labels showing the median value for each
layer. Defaults to \code{FALSE}.
}

\item{legend}{
Logical. If \code{TRUE}, displays the legend. Defaults to \code{FALSE}.
}

\item{limits}{
Optional numeric vector of length 2 giving the lower and upper quantile
probabilities used to restrict the visible y-axis range. Values must be between
0 and 1, with the first value smaller than the second. The restriction is
applied using \code{ggplot2::coord_cartesian()}, so observations outside the
displayed range are retained when calculating the boxplots, densities, and
medians. Defaults to \code{NULL}.
}

\item{custom_colors}{
Optional character vector of valid color names or hexadecimal color codes used
to construct a custom palette for the raster layers. Defaults to \code{NULL}.
}

\item{friedman_test}{
Logical. If \code{TRUE}, performs a Friedman rank-sum test comparing values
among raster layers. Raster cells are treated as blocks and layers as repeated
measurements. Only cells containing non-missing values in every layer are
included. The test result is printed to the console and stored as the
\code{"friedman_test"} attribute of the returned plot. Defaults to
\code{FALSE}.
}
}
\description{
Creates boxplots of pixel values from each layer of a multi-layer raster image,
with optional half-eye density distributions, median labels, custom colours,
quantile-based display limits, and a Friedman rank-sum test.
}
\details{
The function extracts pixel values from all layers of \code{input_image} and
constructs a \code{ggplot2} boxplot in which each raster layer is represented
as a separate group.

If \code{density = TRUE}, a half-eye density distribution is added using
\code{ggdist::stat_halfeye()}. If \code{median_labels = TRUE}, the median of
each layer is displayed as a text label.

The \code{limits} argument controls the visible y-axis range using quantiles of
the pooled raster values. Because the limits are applied through
\code{ggplot2::coord_cartesian()}, values outside the displayed range are not
removed before the boxplots, densities, or medians are calculated.

If \code{custom_colors} is supplied, the provided colours are interpolated
with \code{grDevices::colorRampPalette()} to generate one colour for each
raster layer.

If \code{friedman_test = TRUE}, the function applies
\code{stats::friedman.test()} to the matrix of complete raster-cell
observations. Each row represents the same raster cell across all layers,
therefore raster cells are treated as blocks and layers as repeated
measurements.

The null hypothesis of the Friedman test is that the distributions of the
layers have the same location. A significant result indicates that at least
one layer differs from the others.

The test assumes that values from corresponding cells are meaningfully paired
across layers. It does not account for spatial autocorrelation among
neighbouring raster cells. With very large rasters, small differences may
therefore produce very small p-values.

The function returns a \code{ggplot2} object, so the output can be further
customized by adding other \code{ggplot2} components.
}
\value{
A \code{ggplot2} object.

If \code{friedman_test = TRUE} and the test is successfully calculated, the
returned object also contains a \code{htest} object in the
\code{"friedman_test"} attribute. It can be retrieved using:

\preformatted{
attr(plot_object, "friedman_test")
}
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

names(dolom) <- c("B2", "B3", "B4", "B5")

# Basic boxplot
im.boxplot.layers2(dolom)

# Add density distributions and median labels
im.boxplot.layers2(
  dolom,
  density = TRUE,
  median_labels = TRUE
)

# Restrict the visible y-axis range and use custom colours
im.boxplot.layers2(
  dolom,
  density = TRUE,
  median_labels = TRUE,
  limits = c(0.01, 0.99),
  custom_colors = viridis::viridis(4, end = 0.5)
)

# Perform and print the Friedman test
im.boxplot.layers2(
  dolom,
  density = TRUE,
  median_labels = TRUE,
  friedman_test = TRUE
)

# Save the plot and extract the complete test result
p <- im.boxplot.layers2(
  dolom,
  friedman_test = TRUE
)

attr(p, "friedman_test")
}
}

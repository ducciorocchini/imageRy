\name{im.boxplot.layers}
\alias{im.boxplot.layers}
\title{Visualize raster value distributions across image layers}
\usage{
im.boxplot.layers(
input_image,
density = TRUE,
median_labels = FALSE,
legend = FALSE,
limits = NULL,
custom_colors = NULL
)
}
\arguments{
\item{input_image}{A multi-layer \code{SpatRaster}. Each layer is displayed as
a separate group in the boxplot.}

\item{density}{Logical. If \code{TRUE}, adds a half-eye density distribution for
each layer. Defaults to \code{TRUE}.}

\item{median_labels}{Logical. If \code{TRUE}, adds text labels showing the median
value for each layer. Defaults to \code{FALSE}.}

\item{legend}{Logical. If \code{TRUE}, displays the legend. Defaults to \code{FALSE}.}

\item{limits}{Optional numeric vector of length 2 giving the lower and upper
quantile probabilities used to restrict the visible y-axis range. Values
must be between 0 and 1. Defaults to \code{NULL}.}

\item{custom_colors}{Optional character vector of valid color names or hex
codes used to build a custom palette for the layers. Defaults to \code{NULL}.}
}
\description{
Creates boxplots of pixel values from each layer of a multi-layer raster image.
Each layer is displayed as a separate group, allowing the distribution of values
across image layers or bands to be compared.
}
\details{
The function extracts pixel values from all layers of \code{input_image} and
builds a \code{ggplot2}
boxplot showing the distribution of values within each layer.

If \code{density = TRUE}, a half-eye density layer is added using
\code{ggdist::stat_halfeye}. If \code{median_labels = TRUE}, median values are
displayed as text labels. The \code{limits} argument optionally restricts the
visible y-axis range to the selected quantiles. If \code{custom_colors} is
provided, a custom palette is used for layer colours.

The function returns a \code{ggplot2} object, so the output can be further
customized with additional \code{ggplot2} layers.
}
\value{
A \code{ggplot2} object.
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

names(dolom) <- c("B2", "B3", "B4", "B5")

# Basic boxplot

im.boxplot.layers(dolom)

# Add density and median labels

im.boxplot.layers(dolom,
  density = TRUE,
  median_labels = TRUE
)

# Restrict the visible y-axis range and use custom colors

im.boxplot.layers(dolom,
  density = TRUE,
  median_labels = TRUE,
  limits = c(0.01, 0.99),
  custom_colors = viridis::viridis(4, end = 0.5)
)
}
}

\name{im.boxplot}
\alias{im.boxplot}
\title{Visualize raster value distributions across image classes}
\usage{
im.boxplot(
  input_image,
  classified_image,
  layer = 1,
  density = TRUE,
  median_labels = FALSE,
  legend = FALSE,
  limits = NULL,
  custom_colors = NULL
)
}
\arguments{
  \item{input_image}{A \code{SpatRaster} containing one or more layers.}

  \item{classified_image}{A single-layer \code{SpatRaster} representing the output
  of an image classification. The raster is used to group pixel values from
  \code{input_image} into classes.}

  \item{layer}{A numeric index or character string specifying which layer of
  \code{input_image} should be displayed. Defaults to \code{1}.}

  \item{density}{Logical. If \code{TRUE}, adds a half-eye density distribution for
  each class. Defaults to \code{TRUE}.}

  \item{median_labels}{Logical. If \code{TRUE}, adds text labels showing the median
  value for each class. Defaults to \code{FALSE}.}

  \item{legend}{Logical. If \code{TRUE}, displays the legend. Defaults to \code{FALSE}.}

  \item{limits}{Optional numeric vector of length 2 giving the lower and upper
  quantile probabilities used to restrict the visible y-axis range. Values
  must be between 0 and 1. Defaults to \code{NULL}.}

  \item{custom_colors}{Optional character vector of valid color names or hex
  codes used to build a custom palette for the classes. Defaults to \code{NULL}.}
}
\description{
Creates boxplots of pixel values from a selected layer of a single- or multi-layer
raster image, grouped according to the classes of a classified image.
}
\details{
The function extracts pixel values from the selected layer of \code{input_image}
and groups them according to the classes stored in \code{classified_image}. It then
builds a \code{ggplot2} boxplot showing the distribution of values within each
class.

If \code{density = TRUE}, a half-eye density layer is added using
\code{ggdist::stat_halfeye}. If \code{median_labels = TRUE}, median values are displayed as text labels.
The \code{limits} argument optionally restricts the visible y-axis range to the selected quantiles.
If \code{custom_colors} is provided, a custom palette is used for class colours.

The function returns a \code{ggplot2} object, so the output can be further
customized with additional \code{ggplot2} layers.
}
\value{
A \code{ggplot2} object.
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

classes <- im.classify(dolom,
                       num_clusters = 4,
                       seed = 42)

# Basic boxplot
im.boxplot(dolom, classes, layer = 2)

# Add density and median labels
im.boxplot(dolom, classes,
           layer = 2,
           density = TRUE,
           median_labels = TRUE)

# Restrict the visible y-axis range and use custom colors
im.boxplot(dolom, classes,
           layer = 2,
           density = TRUE,
           median_labels = TRUE,
           limits = c(0.01, 0.99),
           custom_colors = viridis::viridis(4, end = 0.5))
}
}

\name{im.barplot}
\alias{im.barplot}
\title{Visualize the distribution of image classes with barplots}
\usage{
im.barplot(
  classified_image,
  perc = FALSE,
  counts = FALSE,
  rescale = FALSE,
  custom_colors = NULL
)
}
\arguments{
  \item{classified_image}{A single-layer \code{SpatRaster} representing the output
  of an image classification.}

  \item{perc}{Logical. If \code{TRUE}, bars show the percentage of pixels in each
  class. If \code{FALSE}, bars show the number of pixels in each class.
  Defaults to \code{FALSE}.}

  \item{counts}{Logical. If \code{TRUE}, numeric labels are added above the bars.
  Labels represent counts when \code{perc = FALSE} and percentages when
  \code{perc = TRUE}. Defaults to \code{FALSE}.}

  \item{rescale}{Logical. If \code{TRUE}, the y-axis is rescaled to facilitate
  comparison among plots. When \code{perc = FALSE}, the y-axis ranges from
  0 to the total number of pixels. When \code{perc = TRUE}, the y-axis ranges
  from 0 to 100. Defaults to \code{FALSE}.}

  \item{custom_colors}{Optional character vector of valid color names or hex
  codes used to build a custom palette for the classes. Defaults to \code{NULL}.}
}
\description{
Creates barplots showing the distribution of classes in a classified image.
Bars can represent either the number of pixels or the percentage of pixels
belonging to each class.
}
\details{
The function extracts class values from \code{classified_image} and summarizes
their distribution in a barplot. By default, bars represent the number of pixels
in each class.

If \code{perc = TRUE}, the function displays class percentages instead of raw counts.
If \code{counts = TRUE}, numeric labels are added above the bars. If
\code{rescale = TRUE}, the y-axis is standardized to improve comparison among
different plots. If \code{custom_colors} is provided, a custom palette is used
for class colours.

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

# Basic barplot
im.barplot(classes)

# Add numeric labels
im.barplot(classes, counts = TRUE)

# Show counts with a rescaled y-axis
im.barplot(classes, counts = TRUE, rescale = TRUE)

# Show percentages
im.barplot(classes, perc = TRUE)

# Show percentages with numeric labels and a fixed 0-100 y-axis
im.barplot(classes, perc = TRUE, counts = TRUE, rescale = TRUE)

# Add custom colors
im.barplot(classes,
           perc = TRUE,
           counts = TRUE,
           rescale = TRUE,
           custom_colors = viridis::viridis(4, end = 0.5))
}
}

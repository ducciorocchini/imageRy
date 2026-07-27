\name{im.boxplot.layers}
\alias{im.boxplot.layers}
\title{Visualize raster value distributions across image layers}
\usage{
im.boxplot.layers(
  input_image,
  density = TRUE,
  median_labels = FALSE,
  median_position = -0.3,
  legend = FALSE,
  limits = NULL,
  custom_colors = NULL,
  flip = FALSE,
  violin = FALSE,
  friedman_test = FALSE
)
}
\arguments{
\item{input_image}{
A multi-layer \code{SpatRaster}. Each raster layer is represented as a
separate group in the plot.
}

\item{density}{
Logical. If \code{TRUE}, adds a half-eye density distribution beside each
boxplot. Defaults to \code{TRUE}. This argument is ignored when
\code{violin = TRUE}.
}

\item{median_labels}{
Logical. If \code{TRUE}, adds text labels showing the median value for each
raster layer. Defaults to \code{FALSE}.
}

\item{median_position}{
A single numeric value controlling the position of median labels along the
layer axis. Negative values move the labels to the left of the corresponding
group, whereas positive values move them to the right. Defaults to
\code{-0.3}.
}

\item{legend}{
Logical. If \code{TRUE}, displays the colour and fill legends. Defaults to
\code{FALSE}.
}

\item{limits}{
Optional numeric vector of length 2 giving the lower and upper quantile
probabilities used to restrict the displayed value range. Values must be
between 0 and 1, with the first value smaller than the second.

The limits are calculated from the pooled non-missing values of all raster
layers and applied using \code{ggplot2::scale_y_continuous()}. Observations
outside the selected range are therefore removed before the graphical
statistics are calculated. Defaults to \code{NULL}.
}

\item{custom_colors}{
Optional character vector of valid colour names or hexadecimal colour codes
used to construct a custom palette for the raster layers. The supplied colours
are interpolated to generate one colour for each layer. Defaults to
\code{NULL}.
}

\item{flip}{
Logical. If \code{TRUE}, exchanges the layer and value axes using
\code{ggplot2::coord_flip()}. Defaults to \code{FALSE}.
}

\item{violin}{
Logical. If \code{TRUE}, uses violin plots instead of boxplots. Defaults to
\code{FALSE}. When \code{violin = TRUE}, the \code{density} argument is
ignored because violin plots already represent the distribution of values.
}

\item{friedman_test}{
Logical. If \code{TRUE}, performs a Friedman rank-sum test comparing values
among raster layers. Raster cells are treated as blocks and layers as repeated
measurements. Only cells containing non-missing values in every layer are
included.

The test result is printed to the console and stored as the
\code{"friedman_test"} attribute of the returned plot. Defaults to
\code{FALSE}.
}
}
\description{
Creates boxplots or violin plots of pixel values from each layer of a
multi-layer raster image. Boxplots can optionally be combined with half-eye
density distributions.

The function also supports median labels, custom colours, quantile-based
display limits, coordinate flipping, legends, and a Friedman rank-sum test.
}
\details{
The function extracts pixel values from all layers of \code{input_image},
converts them from wide to long format, and constructs a \code{ggplot2} object
in which each raster layer is represented as a separate group.

If \code{violin = FALSE}, raster values are represented using boxplots. If
\code{violin = TRUE}, boxplots are replaced by violin plots.

If \code{density = TRUE} and \code{violin = FALSE}, a half-eye density
distribution is added using \code{ggdist::stat_halfeye()}. If
\code{median_labels = TRUE}, the median of each raster layer is displayed as
a text label. Its position along the layer axis can be adjusted using
\code{median_position}.

The \code{limits} argument controls the displayed value range using quantiles
of the pooled non-missing raster values. The limits are applied using
\code{ggplot2::scale_y_continuous()}. Consequently, values outside the
selected range are removed before boxplots, violin plots, half-eye densities,
and median labels are calculated.

If \code{custom_colors} is supplied, the provided colours are interpolated
with \code{grDevices::colorRampPalette()} to generate one colour for each
raster layer.

If \code{flip = TRUE}, the final plot is rotated using
\code{ggplot2::coord_flip()}.

If \code{friedman_test = TRUE}, the function applies
\code{stats::friedman.test()} to the matrix of complete raster-cell
observations. Each row represents the same raster cell across all layers.
Raster cells are therefore treated as blocks and raster layers as repeated
measurements.

The null hypothesis of the Friedman test is that all raster layers have the
same location distribution. A significant result indicates that at least one
layer differs from the others, but it does not identify which layers differ.

The test assumes that values from corresponding raster cells are meaningfully
paired across layers. It does not account for spatial autocorrelation among
neighbouring raster cells. Spatial autocorrelation may inflate the test
statistic and produce overly small p-values, particularly when large numbers
of raster cells are included.

Although the function accepts two or more raster layers, the Friedman test is
primarily intended for three or more repeated measurements. For exactly two
layers, a paired Wilcoxon signed-rank test is generally more appropriate.

The function returns a \code{ggplot2} object, allowing the output to be further
customized by adding other \code{ggplot2} components.
}
\value{
A \code{ggplot2} object representing raster value distributions across image
layers.

If \code{friedman_test = TRUE} and the test is successfully calculated, the
returned plot also contains an \code{htest} object in its
\code{"friedman_test"} attribute. It can be retrieved using:

\preformatted{
attr(plot_object, "friedman_test")
}
}
\seealso{
\code{\link{im.boxplot.classes}},
\code{\link{im.classify}},
\code{\link{im.barplot}},
\code{\link[stats]{friedman.test}},
\code{\link[ggplot2]{geom_boxplot}},
\code{\link[ggplot2]{geom_violin}},
\code{\link[ggdist]{stat_halfeye}}
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

names(dolom) <- c("B2", "B3", "B4", "B5")

# Basic boxplots with half-eye density distributions
im.boxplot.layers(dolom)

# Add median labels
im.boxplot.layers(
  dolom,
  density = TRUE,
  median_labels = TRUE
)

# Adjust the position of median labels
im.boxplot.layers(
  dolom,
  median_labels = TRUE,
  median_position = -0.4
)

# Restrict the displayed range using pooled raster quantiles
im.boxplot.layers(
  dolom,
  limits = c(0.01, 0.99)
)

# Use custom colours
im.boxplot.layers(
  dolom,
  density = TRUE,
  custom_colors = viridis::viridis(4, end = 0.5)
)

# Display the legend
im.boxplot.layers(
  dolom,
  legend = TRUE
)

# Flip the plot coordinates
im.boxplot.layers(
  dolom,
  median_labels = TRUE,
  flip = TRUE
)

# Use violin plots instead of boxplots
im.boxplot.layers(
  dolom,
  violin = TRUE,
  median_labels = TRUE,
  median_position = 0.4,
  limits = c(0.01, 0.99),
  custom_colors = viridis::viridis(4, end = 0.5),
  flip = TRUE
)

# Perform and print the Friedman test
im.boxplot.layers(
  dolom,
  density = TRUE,
  median_labels = TRUE,
  friedman_test = TRUE
)

# Save the plot and extract the complete test result
p <- im.boxplot.layers(
  dolom,
  friedman_test = TRUE
)

attr(p, "friedman_test")
}
}

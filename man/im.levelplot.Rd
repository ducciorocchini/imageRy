\name{im.levelplot}
\alias{im.levelplot}
\title{Visualize raster layers using level plots}
\usage{
im.levelplot(
  input_image,
  layer = NULL,
  margin = "mean",
  custom_colors = "viridis",
  direction = 1,
  contour = FALSE,
  ncol = NULL,
  main = NULL,
  legend_title = NULL
)
}
\arguments{
  \item{input_image}{A \code{SpatRaster} object representing the input raster image.}

  \item{layer}{Optional numeric index or character string specifying the raster
  layer to display. If \code{NULL}, all raster layers are displayed.
  Defaults to \code{NULL}.}

  \item{margin}{Optional character string specifying the function used to
  calculate marginal summaries along raster rows and columns.
  Accepted values are \code{"mean"}, \code{"median"}, and \code{NULL}.
  The default is \code{"mean"}. Setting \code{margin = NULL} disables
  marginal summaries.}

  \item{custom_colors}{Color palette used to display raster values.
  It can be either the name of a supported \code{viridis} palette or
  a character vector of valid color names or hexadecimal codes.
  Supported palette names are \code{"viridis"}, \code{"magma"},
  \code{"plasma"}, \code{"inferno"}, \code{"cividis"}, \code{"mako"},
  \code{"rocket"}, and \code{"turbo"}.
  Defaults to \code{"viridis"}.}

  \item{direction}{Direction of the \code{viridis} palette.
  Use \code{1} for the default direction and \code{-1} to reverse
  the palette. This argument applies only when \code{custom_colors}
  specifies a predefined \code{viridis} palette.
  Defaults to \code{1}.}

  \item{contour}{Logical. If \code{TRUE}, contour lines are
  superimposed on the raster visualization.
  Defaults to \code{FALSE}.}

  \item{ncol}{Optional positive integer specifying the number of
  columns used to arrange multiple raster layers.
  If \code{NULL}, the layout is determined automatically.
  Defaults to \code{NULL}.}

  \item{main}{Optional character string specifying the plot title.
  For multi-layer displays with marginal summaries, the title
  is placed above the combined multi-panel plot.
  Defaults to \code{NULL}.}

  \item{legend_title}{Optional character string specifying the
  title of the color legend. Defaults to \code{NULL}.}
}
\description{
Creates level plots for single-layer or multi-layer
\code{SpatRaster} objects. The function supports customizable
color palettes, contour overlays, row- and column-wise marginal
summaries, and flexible multi-panel layouts.
}
\details{
The function is based on \code{rasterVis::levelplot()} and provides
a simplified interface for visualizing geographical raster data
within the \code{imageRy} package.

A single raster layer can be selected using the \code{layer}
argument. If \code{layer = NULL}, all raster layers are displayed.

Marginal summaries, also referred to as marginal profiles,
describe variation in raster values along rows and columns.
They are calculated using either the mean or the median.

By default, \code{margin = "mean"} displays row- and column-wise
mean profiles. Setting \code{margin = "median"} uses the median,
whereas \code{margin = NULL} disables marginal summaries.

For single-layer rasters, the level plot and its marginal profiles
are displayed together in a single graphical representation.

For multi-layer rasters with marginal summaries enabled, each
raster layer is displayed in a separate panel together with
its corresponding row- and column-wise marginal profiles.
The panels are arranged in a grid using
\code{gridExtra::arrangeGrob()}.

A common color scale is calculated across all layers when
marginal summaries are enabled in multi-layer displays.
This facilitates direct comparisons of raster values
among layers.

When \code{margin = NULL}, multi-layer rasters are displayed
using the standard multi-panel behavior of
\code{rasterVis::levelplot()}.

If \code{custom_colors} is the name of a supported
\code{viridis} palette, a palette of 100 colors is generated.
The direction can be reversed using \code{direction = -1}.
Alternatively, users can provide a character vector of
custom colors.

If \code{contour = TRUE}, contour lines are added to the
raster visualization. The \code{ncol} argument controls
the arrangement of multiple raster layers.

Marginal summaries based on the mean or median are primarily
intended for continuous numerical raster data. For categorical
rasters, numerical class identifiers may represent labels
rather than quantitative measurements, making these
summaries potentially inappropriate.

Geographic rasters are explicitly labelled using longitude
and latitude. For projected rasters and rasters without a
defined coordinate reference system, axis labels follow
the default behavior of \code{rasterVis::levelplot()}.

The function provides an initial exploratory visualization
of raster data before applying distribution-based methods
such as \code{im.ridgeline()} and
\code{im.boxplot.layers()}.
}
\value{
A \code{trellis} object produced by
\code{rasterVis::levelplot()} when displaying a single
raster layer or when \code{margin = NULL}.

For multi-layer rasters with marginal summaries enabled,
a \code{gtable} object produced by
\code{gridExtra::arrangeGrob()} is returned invisibly
after displaying the combined multi-panel plot.
}
\seealso{
\code{\link{im.ridgeline}},
\code{\link{im.boxplot.layers}},
\code{\link{im.ggplot}}
}
\examples{
\dontrun{
library(terra)

# Load a raster image
r <- rast(system.file("ex/elev.tif", package = "terra"))

# Display a single layer with mean marginal profiles
im.levelplot(r)

# Display median marginal profiles
im.levelplot(r, margin = "median")

# Display without marginal summaries
im.levelplot(r, margin = NULL)

# Reverse a viridis palette and add contour lines
im.levelplot(
  r,
  custom_colors = "mako",
  direction = -1,
  contour = TRUE
)

# Use a custom color vector
im.levelplot(
  r,
  custom_colors = c("navy", "white", "orange")
)

# Create a multi-layer raster
r_multi <- c(r, r * 2, r * 3)
names(r_multi) <- c("Layer1", "Layer2", "Layer3")

# Display multiple layers with mean marginal profiles
im.levelplot(
  r_multi,
  margin = "mean",
  ncol = 2
)

# Display multiple layers with median marginal profiles
im.levelplot(
  r_multi,
  margin = "median",
  custom_colors = "plasma",
  ncol = 2,
  main = "Multi-layer raster comparison"
)

# Display multiple layers without marginal summaries
im.levelplot(
  r_multi,
  margin = NULL,
  ncol = 2
)
}
}

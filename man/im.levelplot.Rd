\name{im.levelplot}
\alias{im.levelplot}
\title{Raster level plots}
\usage{
im.levelplot(
  input_image,
  layer = NULL,
  margin = NULL,
  custom_colors = "viridis",
  direction = 1,
  contour = FALSE,
  ncol = NULL,
  main = NULL,
  legend_title = NULL
)
}
\arguments{
  \item{input_image}{A \code{SpatRaster} object.}

  \item{layer}{Optional. A single layer to display, provided either as a numeric
  layer index or as a character string matching one of the layer names of
  \code{input_image}. If \code{NULL}, all layers are displayed. Defaults to
  \code{NULL}.}

  \item{margin}{Optional character string specifying the function used to draw
  marginal summary plots. Accepted values are \code{"mean"} and
  \code{"median"}. Marginal plots are only displayed for single-layer plots.
  If a multi-layer image is provided, \code{margin} is ignored. Defaults to
  \code{NULL}.}

  \item{custom_colors}{Color palette used to display raster values. It can be
  either the name of a supported \code{viridis} palette or a character vector
  of valid color names or hex codes. Supported palette names are
  \code{"viridis"}, \code{"magma"}, \code{"plasma"}, \code{"inferno"},
  \code{"cividis"}, \code{"mako"}, \code{"rocket"}, and \code{"turbo"}.
  Defaults to \code{"viridis"}.}

  \item{direction}{Direction of the \code{viridis} palette. Use \code{1} for
  the default direction and \code{-1} to reverse the palette. This argument
  only applies when \code{custom_colors} is a \code{viridis} palette name.
  Defaults to \code{1}.}

  \item{contour}{Logical. If \code{TRUE}, contour lines are added to the level
  plot. Defaults to \code{FALSE}.}

  \item{ncol}{Optional numeric value defining the number of columns used to
  arrange panels when displaying a multi-layer raster. Defaults to
  \code{NULL}.}

  \item{main}{Optional character string used as the main title of the plot.
  Defaults to \code{NULL}.}

  \item{legend_title}{Optional character string used as the title of the color
  legend. Defaults to \code{NULL}.}
}
\description{
Creates level plots for single-layer or multi-layer \code{SpatRaster} objects.
Raster values are displayed using a continuous color scale, making the function
useful for exploring the spatial distribution of pixel values across one or
more raster layers.
}
\details{
The function is a simplified wrapper around \code{rasterVis::levelplot()} for
common raster visualization tasks in \code{imageRy}. When \code{input_image}
contains multiple layers, each layer is displayed in a separate panel. A
specific layer can be selected using the \code{layer} argument.

Color palettes can be selected using \code{custom_colors}. If a supported
\code{viridis} palette is used, its direction can be reversed with
\code{direction = -1}. Custom color vectors can also be supplied.

For single-layer plots, marginal summaries can be added using the
\code{margin} argument. Accepted values are \code{"mean"} and
\code{"median"}. If \code{margin} is supplied for a multi-layer image, it is
ignored and a warning is returned. Contour lines can be added with
\code{contour = TRUE}, and the layout of multi-layer plots can be controlled
with \code{ncol}.
}
\value{
A level plot object produced by \code{rasterVis::levelplot()}.
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

# Basic usage
im.levelplot(dolom, custom_colors = "viridis")

# Plot a single layer with marginal median summaries
im.levelplot(dolom, layer = 4, 
             custom_colors = "mako", 
             direction = -1, 
             margin = "median")

# Add contour lines
im.levelplot(dolom,
             layer = 4,
             custom_colors = "mako",
             direction = -1,
             margin = "median",
             contour = TRUE)
}
}

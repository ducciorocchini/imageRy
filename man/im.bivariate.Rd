\name{im.bivariate}
\alias{im.bivariate}
\title{Create bivariate maps from two raster layers}
\usage{
im.bivariate(
  r1,
  r2,
  xlab,
  ylab,
  style = "quantile",
  dim = 2,
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
  \item{r1}{A single-layer \code{SpatRaster} object representing the first
  variable to be mapped.}

  \item{r2}{A single-layer \code{SpatRaster} object representing the second
  variable to be mapped. It must have the same geometry as \code{r1}.}

  \item{xlab}{Character string used as the label of the x-axis in the bivariate
  legend.}

  \item{ylab}{Character string used as the label of the y-axis in the bivariate
  legend.}

  \item{style}{Character string identifying the method used to calculate class
  breaks. The value is passed to \code{biscale::bi_class()}. Defaults to
  \code{"quantile"}.}

  \item{dim}{Numeric value defining the dimension of the bivariate palette.
  For example, \code{dim = 3} produces a 3 x 3 classification, corresponding
  to 9 bivariate classes. Defaults to \code{2}.}

  \item{custom_colors}{Color palette used for the bivariate map. It can be
  either the name of a built-in \code{biscale} palette or a character vector
  of valid color names or hex codes. When a custom vector is supplied, it must
  contain exactly \code{dim^2} colors. Defaults to \code{"BlueOr"}.}

  \item{add_legend}{Logical. If \code{TRUE}, the bivariate legend is added to
  the map. If \code{FALSE}, only the bivariate map is returned. Defaults to
  \code{TRUE}.}

  \item{legend_x}{Numeric value defining the horizontal position of the
  bivariate legend within the plot. Defaults to \code{0.7}.}

  \item{legend_y}{Numeric value defining the vertical position of the
  bivariate legend within the plot. Defaults to \code{0.65}.}

  \item{legend_width}{Numeric value defining the width occupied by the
  bivariate legend within the plot. Defaults to \code{0.3}.}

  \item{legend_height}{Numeric value defining the height occupied by the
  bivariate legend within the plot. Defaults to \code{0.3}.}

  \item{legend_size}{Numeric value controlling the size of the bivariate legend.
  Defaults to \code{10}.}

  \item{legend_label_size}{Numeric value controlling the font size of the
  bivariate legend labels. Defaults to \code{10}.}
}
\description{
Creates a bivariate map from two raster layers. The function combines two
continuous raster variables into a single map by assigning each pixel to a
bivariate class based on its values in both input layers.
}
\details{
The function uses \code{biscale::bi_class()} to classify the two input rasters
into bivariate classes and \code{biscale::bi_scale_fill()} to apply a bivariate
color palette. The two input rasters must be \code{SpatRaster} objects with
the same coordinate reference system, extent and resolution.

The \code{dim} argument controls the number of classes used for each variable.
For example, \code{dim = 2} produces four bivariate classes, while
\code{dim = 3} produces nine bivariate classes.

The bivariate legend is created with \code{biscale::bi_legend()} and added to
the map using \code{cowplot}. Its position and size can be controlled with the
\code{legend_x}, \code{legend_y}, \code{legend_width}, and
\code{legend_height} arguments. If \code{add_legend = FALSE}, the function
returns only the bivariate map.
}
\value{
A \code{ggplot2} object, or a \code{cowplot} object when the bivariate legend
is added.
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

names(dolom) <- c("B2", "B3", "B4", "B8")

# Bivariate map of red and near-infrared bands
im.bivariate(r1 = dolom[["B4"]],
             r2 = dolom[["B8"]],
             xlab = "Red band",
             ylab = "NIR band",
             custom_colors = "DkBlue2",
             dim = 3)
}
}

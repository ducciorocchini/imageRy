\name{im.pairs}
\alias{im.pairs}
\title{Explore pairwise relationships among raster layers}
\usage{
im.pairs(
  input_image,
  color = "black",
  bivariate_color = "BlueOr",
  dim = 2,
  sample_pixels = NULL,
  seed = 42,
  map_factor = 1,
  legend_x = 0.72,
  legend_y = 0.72,
  legend_width = 0.32,
  legend_height = 0.32,
  legend_size = 10,
  legend_label_size = 6
)
}
\arguments{
  \item{input_image}{A multi-layer \code{SpatRaster} object.}

  \item{color}{Color used for the density plots on the diagonal and for the
  scatterplots in the lower triangle. It can be any valid color name or hex
  code. Defaults to \code{"black"}.}

  \item{bivariate_color}{Color palette used for the bivariate maps in the upper
  triangle. It can be either the name of a built-in \code{biscale} palette or
  a character vector of valid color names or hex codes. Defaults to
  \code{"BlueOr"}.}

  \item{dim}{Numeric value defining the dimension of the bivariate palette.
  For example, \code{dim = 3} produces a 3 x 3 classification, corresponding
  to 9 bivariate classes. Defaults to \code{2}.}

  \item{sample_pixels}{Optional numeric value specifying the number of pixels
  randomly sampled for the density plots, scatterplots, and statistical
  summaries. If \code{NULL}, all non-\code{NA} pixels are used. Defaults to
  \code{NULL}.}

  \item{seed}{Numeric value used as seed for reproducible random sampling when
  \code{sample_pixels} is not \code{NULL}. Defaults to \code{42}.}

  \item{map_factor}{Numeric value defining the aggregation factor used to reduce
  the spatial resolution of the bivariate maps. Values greater than \code{1}
  aggregate the raster layers before plotting. Defaults to \code{1}.}

  \item{legend_x}{Numeric value defining the horizontal position of the
  bivariate legends within the upper-triangle plots. Defaults to \code{0.72}.}

  \item{legend_y}{Numeric value defining the vertical position of the
  bivariate legends within the upper-triangle plots. Defaults to \code{0.72}.}

  \item{legend_width}{Numeric value defining the width occupied by the
  bivariate legends within the upper-triangle plots. Defaults to \code{0.32}.}

  \item{legend_height}{Numeric value defining the height occupied by the
  bivariate legends within the upper-triangle plots. Defaults to \code{0.32}.}

  \item{legend_size}{Numeric value controlling the size of the bivariate
  legends. Defaults to \code{10}.}

  \item{legend_label_size}{Numeric value controlling the font size of the
  bivariate legend labels. Defaults to \code{6}.}
}
\description{
Creates a pairwise plot matrix to explore relationships among the layers of a
multi-layer \code{SpatRaster}. The function combines density plots,
scatterplots, statistical summaries, and bivariate maps in a single figure.
}
\details{
The function compares all layers of \code{input_image} in a matrix layout.
Density plots are shown on the diagonal and represent the distribution of
values for each raster layer. Scatterplots are shown in the lower triangle and
represent pairwise relationships between raster layers. Each scatterplot also
reports the coefficient of determination, \code{R^2}, and the associated
\emph{p}-value from a linear model.

Bivariate maps are shown in the upper triangle and are produced using
\code{im.bivariate()}. 

For large raster images, \code{sample_pixels} can be used to reduce the number
of pixels used for density plots, scatterplots, and statistical summaries. When
sampling is used, \code{R^2} and \emph{p}-values are calculated on the sampled
pixels. The \code{map_factor} argument can be used to aggregate raster layers
before producing the bivariate maps, reducing computation time and figure size.
}
\value{
A \code{patchwork} object combining multiple \code{ggplot2} plots.
}
\examples{
\dontrun{
dolom <- im.import("sentinel.dolomites")

names(dolom) <- c("B2", "B3", "B4", "B8")

# Basic pairwise plot using sampled pixels
im.pairs(dolom, sample_pixels = 5000)

# Pairwise plot with custom scatterplot and bivariate map colors
im.pairs(dolom,
         color = "slateblue4",
         bivariate_color = "DkBlue2",
         sample_pixels = 5000)
}
}

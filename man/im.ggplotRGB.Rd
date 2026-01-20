\name{im.ggplotRGB}
\alias{im.ggplotRGB}
\title{Visualize an RGB Raster Image with \pkg{ggplot2}}
\description{
Create a publication-ready RGB composite plot from a \code{terra} \code{SpatRaster}
using \code{ggplot2}, with optional band selection and downsampling for large rasters.
}
\usage{
im.ggplotRGB(input_image, r = 1, g = 2, b = 3, stretch = "lin", title = "", downsample = 1)
}
\arguments{
  \item{input_image}{
    A \code{\link[terra:SpatRaster-class]{SpatRaster}} object representing an RGB image
    (three bands) or any multi-band raster where the chosen \code{r}, \code{g}, \code{b}
    indices select appropriate bands.
  }
  \item{r}{
    Integer. Index of the raster band to be used for the red channel. Default: \code{1}.
  }
  \item{g}{
    Integer. Index of the raster band to be used for the green channel. Default: \code{2}.
  }
  \item{b}{
    Integer. Index of the raster band to be used for the blue channel. Default: \code{3}.
  }
  \item{stretch}{
    Character. Contrast stretching method. Currently a placeholder; the function
    documents and accepts \code{"lin"} (linear) but other methods are not implemented.
    Default: \code{"lin"}.
  }
  \item{title}{
    Character. Optional plot title. Default: an empty string.
  }
  \item{downsample}{
    Integer. Aggregation factor used to spatially downsample the input raster prior
    to plotting. Values > 1 reduce resolution and improve plotting performance.
    Default: \code{1} (no downsampling).
  }
}
\value{
A \code{ggplot} object (from \pkg{ggplot2}) containing a raster-layer RGB composite.
The returned object can be further modified with \pkg{ggplot2} layers and printed with
\code{print()} or saved with \code{ggsave()}.
}
\details{
The function optionally downsamples the input raster with \code{terra::aggregate}
when \code{downsample > 1}, then converts the (downsampled) raster to a data frame
with coordinates using \code{as.data.frame(..., xy = TRUE)}. Missing values are removed
via \code{na.omit}. The specified bands are combined into RGB colors using
\code{\link[grDevices]{rgb}}; the maximum value across the three selected bands is
used as \code{maxColorValue} to scale colors consistently.

The produced plot uses \code{\link[ggplot2]{geom_raster}} and
\code{\link[ggplot2]{scale_fill_identity}} to place the computed RGB values directly
into the plot. The \code{stretch} argument is currently a documented placeholder
and does not perform histogram or percentile stretching; this may be extended in
future versions.
}
\examples{
\dontrun{
library(terra)
library(ggplot2)

# Example RGB raster (replace with your own)
r <- rast(system.file("ex/logo.tif", package = "terra"))

# Basic RGB ggplot
p <- im.ggplotRGB(r, title = "RGB composite")
print(p)

# Downsampled plot for large rasters
p2 <- im.ggplotRGB(r, downsample = 2, title = "Downsampled RGB")
print(p2)
}
}
\seealso{
\code{\link[terra:SpatRaster-class]{SpatRaster}},
\code{\link[ggplot2]{geom_raster}}, \code{\link[grDevices]{rgb}}
}
\author{
Iris Nana Obeng
}

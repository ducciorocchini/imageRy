#' Plot an RGB Raster Image Using ggplot2
#'
#' This function generates an RGB composite from a multispectral raster image
#' using ggplot2. It allows users to select the red, green, and blue bands,
#' apply linear contrast stretching, and optionally reduce image resolution
#' to improve plotting performance.
#'
#' @param input_image A `SpatRaster` object containing at least three raster bands.
#' @param r An integer specifying the band to use for the red channel (default: 1).
#' @param g An integer specifying the band to use for the green channel (default: 2).
#' @param b An integer specifying the band to use for the blue channel (default: 3).
#' @param stretch A character string specifying the contrast stretching method.
#'   If `"lin"`, a quantile-based linear stretch is applied; otherwise,
#'   values are normalized by the maximum value across the three bands
#'   (default: "lin").
#' @param quantiles A numeric vector of length two specifying the lower and
#'   upper quantiles used for linear contrast stretching
#'   (default: c(0.02, 0.98)).
#' @param title An optional title for the RGB plot (default: "").
#' @param downsample A numeric value specifying the aggregation factor used
#'   to reduce raster resolution (default: 1, no aggregation).
#'
#' @return A `ggplot` object representing the RGB composite image.
#'
#' @details
#' The function extracts pixel values from three selected raster bands
#' and combines them into an RGB image using ggplot2.
#'
#' The RGB channels are defined as:
#' \itemize{
#'   \item Red channel: band specified by `r`.
#'   \item Green channel: band specified by `g`.
#'   \item Blue channel: band specified by `b`.
#' }
#'
#' Additional options:
#' \itemize{
#'   \item If `stretch = "lin"`, pixel values are linearly rescaled
#'   between the specified quantiles and constrained to the range [0, 1].
#'   \item If `stretch` is different from `"lin"`, pixel values are
#'   divided by the maximum value across all three selected bands.
#'   \item If `downsample > 1`, the raster is aggregated using
#'   `terra::aggregate()` before plotting, reducing the number of pixels.
#'   \item If `title` is provided, it is displayed above the RGB composite.
#' }
#'
#' The function is particularly useful for visualizing true-color and
#' false-color composites from multispectral remote sensing imagery,
#' exploring spectral information, and producing publication-ready
#' raster visualizations using ggplot2.
#'
#' @seealso [im.classify()], [im.scatter()], [terra::plotRGB()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggplot2)
#'
#' # Load example multispectral raster
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Plot an RGB composite
#' im.ggplotRGB(r)
#'
#' # Apply custom contrast stretching
#' im.ggplotRGB(
#'   r,
#'   stretch = "lin",
#'   quantiles = c(0.05, 0.95)
#' )
#'
#' # Change band combinations
#' im.ggplotRGB(
#'   r,
#'   r = 3,
#'   g = 2,
#'   b = 1,
#'   title = "False-color RGB Composite"
#' )
#'
#' # Reduce resolution for faster plotting
#' im.ggplotRGB(
#'   r,
#'   downsample = 2,
#'   title = "Downsampled RGB Composite"
#' )
#' }
#'
#' @export
im.ggplotRGB <- function(input_image, r = 1, g = 2, b = 3,
                         stretch = "lin",
                         quantiles = c(0.02, 0.98),
                         title = "",
                         downsample = 1) {
  
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  if (downsample == 1) {
    rgb_small <- input_image
  } else {
    rgb_small <- terra::aggregate(input_image, fact = downsample)
  }
  
  rgb_df <- terra::as.data.frame(rgb_small, xy = TRUE, na.rm = TRUE)
  band_names <- names(rgb_df)[-(1:2)]
  
  red   <- rgb_df[[band_names[r]]]
  green <- rgb_df[[band_names[g]]]
  blue  <- rgb_df[[band_names[b]]]
  
  scale01 <- function(x, probs = c(0.02, 0.98)) {
    q <- stats::quantile(x, probs = probs, na.rm = TRUE)
    x <- (x - q[1]) / (q[2] - q[1])
    pmin(pmax(x, 0), 1)
  }
  
  if (stretch == "lin") {
    red   <- scale01(red, quantiles)
    green <- scale01(green, quantiles)
    blue  <- scale01(blue, quantiles)
  } else {
    maxval <- max(c(red, green, blue), na.rm = TRUE)
    red   <- red / maxval
    green <- green / maxval
    blue  <- blue / maxval
  }
  
  rgb_df$rgb_col <- grDevices::rgb(red, green, blue)
  
  ggplot2::ggplot(rgb_df) +
    ggplot2::geom_raster(
      ggplot2::aes(x = x, y = y, fill = rgb_col)
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_equal() +
    ggplot2::labs(title = title) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
      axis.text = ggplot2::element_text(size = 8),
      panel.grid = ggplot2::element_blank()
    )
}

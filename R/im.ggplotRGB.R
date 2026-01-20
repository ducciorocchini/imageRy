#' Visualize an RGB Raster Image Using ggplot2
#'
#' This function creates a \code{ggplot2}-based RGB visualization of a raster image,
#' allowing flexible band selection, optional downsampling for large images,
#' and publication-quality rendering.
#'
#' @param input_image A \code{SpatRaster} object representing an RGB image.
#' @param r Integer. Index of the raster band to be used as the red channel. Default: \code{1}.
#' @param g Integer. Index of the raster band to be used as the green channel. Default: \code{2}.
#' @param b Integer. Index of the raster band to be used as the blue channel. Default: \code{3}.
#' @param stretch Character. Placeholder for contrast stretching method (currently only linear scaling is applied).
#'   Default: \code{"lin"}.
#' @param title Character. Optional plot title. Default: empty string.
#' @param downsample Integer. Factor by which the raster is spatially aggregated before plotting.
#'   Values greater than 1 reduce resolution and improve performance for large rasters. Default: \code{1}.
#'
#' @return A \code{ggplot2} object displaying the RGB composite of the input raster.
#'
#' @details
#' The function optionally downsamples the input raster using spatial aggregation
#' to reduce plotting time and memory usage. The selected bands are mapped to
#' red, green, and blue color channels and combined using \code{\link[grDevices]{rgb}}.
#' Pixel values are scaled using the maximum value across the selected bands to
#' ensure consistent color rendering.
#'
#' The resulting plot uses \code{\link[ggplot2]{geom_raster}} and
#' \code{\link[ggplot2]{scale_fill_identity}}, making it suitable for integration
#' into \code{ggplot2} workflows and multi-panel figures.
#'
#' @seealso \code{\link[terra:SpatRaster-class]{SpatRaster}},
#'   \code{\link[ggplot2]{ggplot}},
#'   \code{\link[grDevices]{rgb}}
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggplot2)
#'
#' # Load example RGB raster
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Plot RGB image
#' p <- im.ggplotRGB(r, title = "RGB Image")
#' print(p)
#'
#' # Downsampled visualization for large rasters
#' p2 <- im.ggplotRGB(r, downsample = 2, title = "Downsampled RGB")
#' print(p2)
#' }
#'
#' @export
im.ggplotRGB <- function(input_image, r = 1, g = 2, b = 3, 
                        stretch = "lin", title = "", downsample = 1) {
  
  # Only downsample if needed
  if (downsample == 1) {
    rgb_small <- input_image
  } else {
    rgb_small <- aggregate(input_image, fact = downsample)
  }
  
  # Convert only the downsampled version to data frame
  rgb_df <- as.data.frame(rgb_small, xy = TRUE)
  rgb_df <- na.omit(rgb_df)
  
  band_names <- names(rgb_df)[3:5]
  
  # Create ggplot
  p <- ggplot() +
    geom_raster(data = rgb_df, 
                aes(x = x, y = y, 
                    fill = rgb(
                      get(band_names[r]), 
                      get(band_names[g]), 
                      get(band_names[b]),
                      maxColorValue = max(c(get(band_names[r]), 
                                          get(band_names[g]), 
                                          get(band_names[b])), na.rm = TRUE)
                    ))) +
    scale_fill_identity() +
    coord_equal() +
    labs(title = title) +
    # theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
          axis.text = element_text(size = 8),
          panel.grid = element_blank())
  
  return(p)
}




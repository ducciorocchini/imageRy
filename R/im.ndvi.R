#' Compute the Normalized Difference Vegetation Index (NDVI)
#'
#' This function calculates the Normalized Difference Vegetation Index (NDVI) from a multispectral raster image.
#' NDVI is a widely used vegetation index that assesses plant health by comparing Near-Infrared (NIR) and Red bands.
#'
#' @param x A `SpatRaster` object representing the input multispectral image.
#' @param nir An integer specifying the band index of the Near-Infrared (NIR) channel.
#' @param red An integer specifying the band index of the Red channel.
#'
#' @return A `SpatRaster` object containing the computed NDVI values, ranging from -1 to 1.
#'
#' @details
#' NDVI is calculated as:
#' \deqn{NDVI = (NIR - Red) / (NIR + Red)}
#' where:
#' - **High NDVI values (~1)** indicate healthy, dense vegetation.
#' - **Low NDVI values (~0 or negative)** indicate barren land, water bodies, or unhealthy vegetation.
#'
#' **Important:**
#' - Ensure that `nir` and `red` correspond to the correct band indices in your raster image.
#' - Pixels with (NIR + Red) = 0 will result in `NaN` values.
#'
#' @references
#' For more details on NDVI, see:
#' \url{https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index}
#'
#' @seealso [im.dvi()], [im.classify()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load a multispectral raster dataset
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Compute NDVI using bands 4 (NIR) and 3 (Red)
#' ndvi_raster <- im.ndvi(r, nir = 4, red = 3)
#'
#' # Plot the NDVI result
#' plot(ndvi_raster)
#' }
#'
#' @export
im.ndvi <- function(x, nir, red){
  
  if(!inherits(x, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(nir, "numeric") && !inherits(red, "numeric")) {
    stop("NIR and red layers should be indicated with a number")
  }
  
  ndvi = (x[[nir]] - x[[red]]) / (x[[nir]] + x[[red]])
 
  return(ndvi)

}

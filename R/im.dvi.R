#' Compute the Difference Vegetation Index (DVI)
#'
#' This function calculates the Difference Vegetation Index (DVI) from a multispectral raster image.
#' The DVI is computed as the difference between the Near-Infrared (NIR) and Red bands.
#'
#' @param x A `SpatRaster` object representing the input multispectral image.
#' @param nir An integer specifying the band index of the Near-Infrared (NIR) channel.
#' @param red An integer specifying the band index of the Red channel.
#'
#' @return A `SpatRaster` object containing the computed DVI values.
#'
#' @details
#' The Difference Vegetation Index (DVI) is a simple vegetation index used to assess plant health.
#' It is calculated as:
#' \deqn{DVI = NIR - Red}
#' Higher values indicate denser and healthier vegetation.
#'
#' @references
#' For more details on the DVI index, see:
#' \url{https://en.wikipedia.org/wiki/Vegetation_Index}
#'
#' @seealso [im.classify()], [im.ridgeline()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load a multispectral raster image
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Compute DVI using bands 4 (NIR) and 3 (Red)
#' dvi_raster <- im.dvi(r, nir = 4, red = 3)
#'
#' # Plot the result
#' plot(dvi_raster)
#' }
#'
#' @export
im.dvi <- function(x,nir,red){
  
  if(!inherits(x, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(nir, "numeric") && !inherits(red, "numeric")) {
    stop("NIR and red layers should be indicated with a number")
  }
  
  dvi = x[[nir]] - x[[red]]
  
  return(dvi)
}

#' Generate Ridgeline Plots from Satellite Raster Data
#'
#' This function generates ridgeline plots from stacked satellite imagery data.
#'
#' @param im A `SpatRaster` object representing the raster data to be visualized.
#' @param scale A numeric value that defines the vertical scale of the ridgeline plot.
#' @param palette A character string specifying the `viridis` color palette option to use.
#' Available options: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, `"cividis"`, `"mako"`, `"rocket"`, `"turbo"`.
#' @param direction A numeric value controlling the direction of the color scale.
#' Typically `1` for the default direction and `-1` to reverse the palette.
#'
#' @return A `ggplot` object displaying the ridgeline plot.
#'
#' @details
#' Ridgeline plots are useful for analyzing temporal variations in raster-based satellite imagery.
#' This function extracts raster values and visualizes their distribution across layers.
#' The `direction` parameter allows reversing the color gradient of the selected palette.
#'
#' @references
#' See also `im.import()`, `im.ggplot()`.
#'
#' @seealso [GitHub Repository](https://github.com/ducciorocchini/imageRy/)
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggridges)
#' library(ggplot2)
#'
#' # Import raster data
#' r <- im.import("greenland")
#'
#' # Generate ridgeline plot
#' im.ridgeline(r, 2, "viridis", direction = 1) + theme_bw()
#' }
#'
#' @export
im.ridgeline <- function (im, scale, palette = c("viridis", "magma", "plasma", 
                                                 "inferno", "cividis", "mako", "rocket", "turbo"), direction = 1) 
{
  palette <- palette[1]
  if (!is(im, "SpatRaster")) 
    stop("im must be a SpatRaster")
  if (!is.numeric(scale)) 
    stop("scale must be numeric")
  if (!is.character(palette)) 
    stop("palette must be a character")
  if (!palette %in% c("viridis", "magma", "plasma", "inferno", 
                      "cividis", "mako", "rocket", "turbo")) 
    stop("palette must be one of the color options in the viridis package (viridis, magma, plasma, inferno, cividis, mako, rocket, turbo)")
  switch(palette, viridis = "D", magma = "A", inferno = "B", 
         plasma = "C", cividis = "E", rocket = "F", mako = "G", 
         turbo = "H")
  df <- as.data.frame(im, wide = FALSE)
  pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, 
                                         fill = ggplot2::after_stat(x))) + ggridges::geom_density_ridges_gradient(scale = scale, 
                                                                                                         rel_min_height = 0.01) + ggplot2::scale_fill_viridis_c(option = palette, direction = direction)
  return(pl)
}

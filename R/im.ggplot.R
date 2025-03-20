#' Visualize a Raster Image Using ggplot2
#'
#' This function converts a `SpatRaster` object into a `ggplot2` visualization, allowing for
#' flexible raster plotting with color interpolation.
#'
#' @param input_raster A `SpatRaster` object representing the input raster image.
#' @param layerfill An integer indicating the layer index to be used for coloring the raster (default: 1).
#'
#' @return A `ggplot` object displaying the raster image.
#'
#' @details
#' This function extracts raster values, converts them into a data frame, and uses `ggplot2`
#' to visualize the raster with a viridis color scale.
#'
#' - If `layerfill` is not provided, the function defaults to using the first layer.
#' - The function automatically handles coordinate extraction (`x` and `y` values).
#' - Colors are applied using `scale_fill_viridis()`, ensuring good perceptual readability.
#'
#' @seealso [im.classify()], [im.dvi()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggplot2)
#'
#' # Load a raster dataset
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#'
#' # Generate a ggplot visualization
#' im.ggplot(r, layerfill = 1)
#' }
#'
#' @export
im.ggplot <- function(input_raster, layerfill = 1) {
  # Convert raster to dataframe and create plot directly
  if(!inherits(input_raster, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(layerfill, "numeric")) {
    stop("Input layer should be indicated with a number")
  }
  
  df <- as.data.frame(input_raster, xy = TRUE)
  layerfill <- colnames(df)[layerfill + 2]
  
  print(
    ggplot(df, 
           aes(x = x, y = y, fill = !!sym(layerfill))) +
      geom_raster(interpolate = TRUE) +
      scale_fill_viridis(option = 'viridis')
  )
}

# p <- im.ggplot(input_raster = mato, layerfill = "matogrosso_ast_2006209_lrg_2")




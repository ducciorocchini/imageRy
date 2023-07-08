library(ggplot2)
library(terra)

im.ggplotRGB <- function(input_image, r = 1, g = 2, b = 3, maxpixels = 1e+06) {
  # Check if input is a SpatRaster
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  # Check if the image has at least 3 layers
  if (terra::nlyr(input_image) < 3) {
    stop("input_image should have at least 3 layers.")
  }
  
  # Reduce the image resolution if it exceeds maxpixels
  if (terra::ncell(input_image) > maxpixels) {
    agg_factor <- round(sqrt(terra::ncell(input_image) / maxpixels))
    input_image <- terra::aggregate(input_image, fact = agg_factor)
  }
  
  # Get values and normalize them to [0, 1]
  vals <- terra::values(input_image)
  vals <- apply(vals, 2, function(col) {
    (col - min(col, na.rm = TRUE)) / (max(col, na.rm = TRUE) - min(col, na.rm = TRUE))
  })
  
  # Get the coordinates
  coords <- terra::xyFromCell(input_image, 1:terra::ncell(input_image))
  
  # Create a data frame
  df <- data.frame(
    x = coords[, 1],
    y = coords[, 2],
    color = rgb(vals[, r], vals[, g], vals[, b], maxColorValue = 1)
  )
  
  # Plot with ggplot2
  ggplot(df, aes(x = x, y = y, fill = color)) +
    geom_tile() +
    scale_fill_identity() +
    coord_equal() +
    theme_minimal()  +
    theme(legend.position = "bottom")
}




library(terra)
library(viridis)
library(fields)

im.classify <- function(input_image, num_clusters = 3, seed = NULL, do_plot = TRUE, use_viridis = TRUE, colors = c('yellow','black','red'), num_colors = 100) {
  
  # Check if input is a SpatRaster
  if(!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  # Get the raster values
  image_values <- values(input_image)
  
  # Remove NA values if any
  image_values <- image_values[!is.na(image_values)]
  
  # Check if num_clusters is valid
  if (!is.numeric(num_clusters) || (num_clusters%%1 != 0) || num_clusters <= 0) {
    stop("num_clusters should be a positive integer.")
  }
  
  # Set seed if provided
  if (!is.null(seed)) {
    if (!is.numeric(seed) || (seed%%1 != 0) || seed <= 0) {
      stop("seed should be a positive integer.")
    }
    set.seed(seed)
  }
  
  # Classify
  kmeans_result <- kmeans(image_values, centers = num_clusters)
  
  # Set values to a raster on the basis of so
  classified_image <- input_image
  values(classified_image) <- kmeans_result$cluster
  
  # Plot if required
  if (do_plot) {
    if (use_viridis) {
      color_palette <- viridis(num_colors)
    } else {
      color_palette <- colorRampPalette(colors)(num_colors)
    }
    image.plot(classified_image, col = color_palette, zlim = c(1,num_clusters), legend.lab = "Class", legend.line = 3, axes = FALSE)
  }
  
  return(classified_image)
}

output_raster <- im.classify(input_image = mato,
                             num_clusters = 5, 
                             seed = 123, 
                             do_plot = TRUE,
                             use_viridis = FALSE)

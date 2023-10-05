im.classify <- function(input_image, num_clusters = 3, seed = NULL, do_plot = TRUE, use_viridis = TRUE, colors = c('yellow','black','red'), num_colors = 100) {
  
  # Check if input is a SpatRaster
  if(!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  # Get the raster values and remove NA values
  image_values <- na.omit(values(input_image))
  
  # Set seed if provided
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Classify using kmeans
  kmeans_result <- kmeans(image_values, centers = num_clusters)
  
  # Set values to a raster based on kmeans result
  classified_image <- input_image
  values(classified_image) <- kmeans_result$cluster
  
  # Plot if required
#   if (do_plot) {
#     if (use_viridis) {
#       color_palette <- viridis(num_colors)
#     } else {
#       color_palette <- colorRampPalette(colors)(num_colors)
#     }
#     plot(classified_image, col = color_palette, axes = FALSE)
#   }
  
  return(classified_image)
}



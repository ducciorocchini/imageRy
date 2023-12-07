
im.classify <- function(input_image, num_clusters = 3, seed = NULL, do_plot = TRUE, custom_colors = NULL, num_colors = 100) {
  # Set a default color palette. These colors are used for visualization after classification.
  base_colors <- c('khaki', 'slateblue', 'olivedrab', 'salmon', 'lightpink', 'darkgrey')
  
  # Determine which color palette to use.
  colors <- if (is.null(custom_colors)) {
    # If the number of clusters exceeds the number of base colors, interpolate additional colors.
    if (num_clusters > length(base_colors)) {
      colorRampPalette(base_colors)(num_clusters)
    } else {
      base_colors[1:num_clusters]
    }
  } else {
    # For custom colors, extend or repeat them to match the number of clusters.
    if (num_clusters > length(custom_colors)) {
      colorRampPalette(custom_colors)(num_clusters)
    } else {
      custom_colors[1:num_clusters]
    }
  }
  
  # Check if the input is indeed a SpatRaster object, which is required for the function to work properly.
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  # Convert raster data into a matrix format, where each row is a pixel and each column is a band.
  image_values <- na.omit(terra::as.matrix(input_image))
  
  # Set a random seed for reproducibility of k-means clustering results, if specified.
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Perform k-means clustering on the pixel values. Each pixel is treated as a multi-dimensional point based on its bands.
  kmeans_result <- kmeans(image_values, centers = num_clusters)
  
  # Initialize a new raster for the classification results, using the first layer of the original raster.
  classified_image <- input_image[[1]]
  # Assign cluster IDs from k-means results to each pixel in the new raster.
  values(classified_image) <- kmeans_result$cluster
  
  # If plotting is enabled, visualize the classified raster using the chosen color palette.
  if (do_plot) {
    color_palette <- colorRampPalette(colors)(num_colors)
    plot(classified_image, col = color_palette, axes = FALSE)
  }
  
  # Return the raster object with classification results.
  return(classified_image)
}

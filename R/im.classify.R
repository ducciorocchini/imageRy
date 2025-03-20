#' Classify a Raster Image Using K-Means Clustering
#'
#' This function performs unsupervised classification on a raster image using k-means clustering.
#' It assigns each pixel to a cluster and optionally visualizes the classified image.
#'
#' @param input_image A `SpatRaster` object representing the input raster image.
#' @param num_clusters An integer specifying the number of clusters (default: 3).
#' @param seed An optional integer seed for reproducibility of k-means clustering results (default: NULL).
#' @param do_plot A logical value indicating whether to display the classified raster (default: TRUE).
#' @param custom_colors A vector of custom colors to be used for classification visualization (default: NULL).
#' If NULL, a predefined set of colors is used.
#' @param num_colors The number of colors to interpolate in the visualization palette (default: 100).
#'
#' @return A `SpatRaster` object with cluster assignments, where each pixel belongs to a classified cluster.
#'
#' @details
#' The function applies k-means clustering on the pixel values of the raster image. Each pixel is treated
#' as a multi-dimensional point, where each band represents a feature. The classified raster assigns
#' each pixel to a cluster, which can be visualized using a color palette.
#'
#' - If `custom_colors` is provided, it is used as the classification color palette.
#' - If `seed` is provided, it ensures reproducibility of k-means clustering.
#' - If `do_plot = TRUE`, the classified raster is displayed with the chosen color scheme.
#'
#' @references
#' K-means clustering is a widely used unsupervised classification algorithm. For more information, see:
#' \url{https://en.wikipedia.org/wiki/K-means_clustering}
#'
#' @seealso [im.import()], [im.ridgeline()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' 
#' # Load a raster dataset
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#' 
#' # Perform k-means classification with 4 clusters
#' classified_raster <- im.classify(r, num_clusters = 4, seed = 123, do_plot = TRUE)
#' }
#'
#' @export
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

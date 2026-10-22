
#' Classify a Time Series of Raster Images Using Common K-Means Clustering
#'
#' This function performs unsupervised classification of a time series of raster images
#' using a common k-means clustering model. By combining pixel values from all input
#' images, it ensures consistent class definitions across different time steps.
#'
#' @param input_images A list of `SpatRaster` objects representing images acquired
#'   at different times. All images must have the same geometry and number of layers.
#' @param num_clusters An integer specifying the number of classes (default: 3).
#' @param seed An optional integer used to ensure reproducibility of the
#'   k-means classification (default: NULL).
#' @param do_plot A logical value indicating whether to automatically plot
#'   the classified images (default: TRUE).
#' @param custom_colors A character vector of colors used to define a custom
#'   visualization palette (default: NULL).
#' @param num_colors An integer specifying the number of colors to interpolate
#'   in the visualization palette (default: 100).
#'
#' @return A list containing:
#' \itemize{
#'   \item `result`: A list of single-layer `SpatRaster` objects containing
#'   the classified images, with consistent class labels across time.
#'   \item `centers`: A matrix containing the k-means cluster centers,
#'   representing the spectral values associated with each class.
#' }
#'
#' @details
#' The function extracts pixel values from all input raster images and combines
#' them into a single dataset before performing k-means clustering.
#' This approach produces a common classification model for the entire time series,
#' allowing direct comparison of class distributions and spatial patterns over time.
#'
#' The classification procedure consists of the following steps:
#' \itemize{
#'   \item Checking that all input images have the same geometry and number of layers.
#'   \item Extracting pixel values and excluding incomplete observations.
#'   \item Combining valid pixel observations from all images into a single dataset.
#'   \item Performing k-means clustering on the combined dataset.
#'   \item Assigning cluster labels to each image using the common classification.
#'   \item Reconstructing classified raster images while preserving their geometry.
#' }
#'
#' Pixels containing missing values in any layer of an individual image are
#' excluded from the classification of that image and assigned `NA` in the output.
#'
#' Additional options:
#' \itemize{
#'   \item If `seed` is provided, the random initialization of k-means is reproducible.
#'   \item If `do_plot = TRUE`, all classified images are displayed in a
#'   multi-panel layout using [im.multiframe()].
#'   \item If `custom_colors` is provided, a custom color palette is generated.
#'   \item Otherwise, the viridis color palette is used by default.
#' }
#'
#' Since all images are classified using the same cluster centers, class labels
#' remain consistent throughout the time series. This makes the function
#' particularly useful for detecting land-cover changes, monitoring vegetation
#' dynamics, and investigating spatial and temporal ecological patterns.
#'
#' The classification is based on spectral similarity rather than predefined
#' thematic categories. Therefore, the ecological interpretation of each class
#' should be based on the spectral characteristics of its cluster center.
#'
#' @seealso [im.classify()], [im.multiframe()], [im.barplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Create two example raster images
#' r1 <- rast(nrows = 50, ncols = 50, nlyrs = 3)
#' values(r1) <- matrix(runif(ncell(r1) * 3), ncol = 3)
#'
#' r2 <- rast(r1)
#' values(r2) <- matrix(runif(ncell(r2) * 3), ncol = 3)
#'
#' # Organize images into a time series
#' images <- list(time1 = r1, time2 = r2)
#'
#' # Perform common k-means classification
#' classified <- im.classify.timeseries(
#'   images,
#'   num_clusters = 3,
#'   seed = 42
#' )
#'
#' # Access classified images
#' classified$result
#'
#' # Access cluster centers
#' classified$centers
#'
#' # Plot class distribution for the first image
#' im.barplot(classified$result[[1]], perc = TRUE)
#' }
#'
#' @export
im.classify.timeseries <- function(input_images, # list of raster objects with same geometry
                                   num_clusters = 3, # number of classes
                                   seed = NULL, # seed for reproducibility 
                                   do_plot = TRUE, # TRUE for showing automatic plot
                                   custom_colors = NULL, # specify a color palette
                                   num_colors = 100) { # number of colors to interpolate in the visualization palette
  
  # Check input images
  if (!is.list(input_images)) {
    stop("input_images should be a list of SpatRaster objects.")
  }
  
  if (length(input_images) < 2) {
    stop("input_images should contain at least two SpatRaster objects.")
  }
  
  if (!all(vapply(
    input_images,
    inherits,
    logical(1),
    what = "SpatRaster"
  ))) {
    stop("All elements of input_images should be SpatRaster objects.")
  }
  
  # Check number of layers
  n_layers <- vapply(
    input_images,
    terra::nlyr,
    numeric(1)
  )
  
  if (length(unique(n_layers)) != 1) {
    stop("All input images should have the same number of layers.")
  }
  
  # Check geometry
  same_geometry <- vapply(
    input_images[-1],
    function(x) {
      terra::compareGeom(
        input_images[[1]],
        x,
        stopOnError = FALSE
      )
    },
    logical(1)
  )
  
  if (!all(same_geometry)) {
    stop("All input images should have the same geometry.")
  }
  
  # Check number of clusters
  if (!is.numeric(num_clusters) ||
      length(num_clusters) != 1 ||
      is.na(num_clusters) ||
      num_clusters < 2 ||
      num_clusters %% 1 != 0) {
    
    stop("num_clusters must be an integer greater than or equal to 2.")
  }
  
  num_clusters <- as.integer(num_clusters)
  
  # Check seed
  if (!is.null(seed)) {
    
    if (!is.numeric(seed) ||
        length(seed) != 1 ||
        is.na(seed) ||
        seed %% 1 != 0) {
      
      stop("seed must be NULL or a single integer.")
    }
    
    seed <- as.integer(seed)
  }
  
  # Check do_plot
  if (!is.logical(do_plot) ||
      length(do_plot) != 1 ||
      is.na(do_plot)) {
    
    stop("do_plot must be either TRUE or FALSE.")
  }
  
  # Check custom colors
  if (!is.null(custom_colors)) {
    
    if (!is.character(custom_colors)) {
      stop("custom_colors must be NULL or a character vector of colors.")
    }
    
    if (length(custom_colors) < 2) {
      stop("custom_colors should contain at least two colors.")
    }
  }
  
  # Check number of colors
  if (!is.numeric(num_colors) ||
      length(num_colors) != 1 ||
      is.na(num_colors) ||
      num_colors < 1 ||
      num_colors %% 1 != 0) {
    
    stop("num_colors must be a positive integer.")
  }
  
  num_colors <- as.integer(num_colors)
  
  
  # Set colors
  if (is.null(custom_colors)) {
    class_colors <- viridisLite::viridis(num_colors)
  } else {
    class_colors <- grDevices::colorRampPalette(custom_colors)(num_colors)
  }
  
  # Extract raster values
  image_values <- lapply(
    input_images,
    terra::values,
    mat = TRUE
  )
  
  # Identify complete pixels
  complete_pixels <- lapply(
    image_values,
    stats::complete.cases
  )
  
  # Remove incomplete pixels
  image_values_complete <- Map(
    function(values, complete) {
      values[complete, , drop = FALSE]
    },
    image_values,
    complete_pixels
  )
  
  # Count complete pixels
  n_complete <- vapply(
    image_values_complete,
    nrow,
    integer(1)
  )
  
  # Check complete pixels
  if (any(n_complete == 0)) {
    stop("Each input raster must contain at least one complete pixel observation.")
  }
  
  # Combine pixel values from all images
  all_values_complete <- do.call(
    rbind,
    image_values_complete
  )
  
  if (nrow(all_values_complete) < num_clusters) {
    stop(
      paste(
        "The number of complete raster cells must be",
        "greater than or equal to num_clusters."
      )
    )
  }
  
  # Set seed
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Perform common k-means classification
  kmeans_result <- stats::kmeans(
    x = all_values_complete,
    centers = num_clusters
  )
  
  # Split cluster assignments among images
  cluster_groups <- rep(
    seq_along(n_complete),
    times = n_complete
  )
  
  clusters <- split(
    kmeans_result$cluster,
    cluster_groups
  )
  
  # Build classified images
  classified_images <- Map(
    function(image, complete, cluster) {
      
      classified_image <- image[[1]]
      
      classified_values <- rep(
        NA_integer_,
        terra::ncell(classified_image)
      )
      
      classified_values[complete] <- cluster
      
      terra::values(classified_image) <- classified_values
      
      names(classified_image) <- "class"
      
      classified_image
    },
    input_images,
    complete_pixels,
    clusters
  )
  
  # Preserve input names
  names(classified_images) <- names(input_images)
  
  # Plot classified images
  if (isTRUE(do_plot)) {
    
    # Save current graphical parameters
    old_par <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(old_par), add = TRUE)
    
    # Set multi-panel layout
    imageRy::im.multiframe(
      1,
      length(classified_images)
    )
    
    # Plot images
    for (classified_image in classified_images) {
      
      terra::plot(
        classified_image,
        col = class_colors,
        zlim = c(1, num_clusters),
        axes = FALSE
      )
    }
  }
  
  # Build output
  output <- list(
    result = classified_images,
    centers = kmeans_result$centers
  )
  
  return(output)
}

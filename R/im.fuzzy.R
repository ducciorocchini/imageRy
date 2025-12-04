im.fuzzy <- function(input_image, num_clusters = 3, seed = NULL,
                     do_plot = TRUE, custom_colors = NULL, num_colors = 100) {
  # Check input
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  nlyr <- terra::nlyr(input_image)
  if (nlyr > 3) {
    stop("This function is for RGB or grayscale images only. Reduce bands before classification.")
  }
  
  # Define base colors (used only for plotting)
  base_colors <- c("khaki", "slateblue", "olivedrab", "salmon",
                   "lightpink", "darkgrey")
  
  colors <- if (is.null(custom_colors)) {
    if (num_clusters > length(base_colors)) {
      grDevices::colorRampPalette(base_colors)(num_clusters)
    } else {
      base_colors[1:num_clusters]
    }
  } else {
    if (num_clusters > length(custom_colors)) {
      grDevices::colorRampPalette(custom_colors)(num_clusters)
    } else {
      custom_colors[1:num_clusters]
    }
  }
  
  # Extract pixel values and scale bands to 0–255 (as in your original function)
  image_values <- terra::as.matrix(input_image)
  
  for (i in seq_len(ncol(image_values))) {
    min_val <- min(image_values[, i], na.rm = TRUE)
    max_val <- max(image_values[, i], na.rm = TRUE)
    image_values[, i] <- 255 * (image_values[, i] - min_val) / (max_val - min_val)
  }
  
  # Remove rows with NAs (assumes NA pattern is same across bands)
  image_values <- stats::na.omit(image_values)
  
  # K-means clustering
  if (!is.null(seed)) {
    set.seed(seed)
  }
  kmeans_result <- stats::kmeans(image_values, centers = num_clusters)
  
  # -------------------------------------------
  # Compute fuzzy distances to each cluster
  # -------------------------------------------
  
  centers <- kmeans_result$centers  # matrix: num_clusters x ncol(image_values)
  n_pixels <- nrow(image_values)
  n_bands  <- ncol(image_values)
  
  # Matrix of distances: n_pixels x num_clusters
  dist_matrix <- matrix(NA_real_, nrow = n_pixels, ncol = num_clusters)
  
  for (k in seq_len(num_clusters)) {
    # Subtract centroid k from all pixels
    diff_k <- sweep(image_values, 2, centers[k, ], FUN = "-")
    # Euclidean distance for each pixel to centroid k
    dist_matrix[, k] <- sqrt(rowSums(diff_k^2))
  }
  
  # -------------------------------------------
  # Put distances back into a SpatRaster
  # -------------------------------------------
  
  template <- input_image[[1]]
  template_vals <- terra::values(template)
  
  # Logical index of non-NA pixels (assumes same NA pattern across bands)
  valid_idx <- !is.na(template_vals)
  
  if (sum(valid_idx) != n_pixels) {
    warning("Number of non-NA pixels in template does not match rows in image_values.\n",
            "Check that all bands share the same NA pattern.")
  }
  
  layer_list <- vector("list", num_clusters)
  
  for (k in seq_len(num_clusters)) {
    r <- template
    terra::values(r) <- NA_real_
    terra::values(r)[valid_idx] <- dist_matrix[, k]
    layer_list[[k]] <- r
  }
  
  fuzzy_rast <- terra::rast(layer_list)
  names(fuzzy_rast) <- paste0("class_", seq_len(num_clusters))
  
  # -------------------------------------------
  # Plot, if requested
  # -------------------------------------------
  
  if (do_plot) {
    color_palette <- grDevices::colorRampPalette(colors)(num_colors)
    terra::plot(fuzzy_rast, col = color_palette, axes = FALSE,
                main = names(fuzzy_rast))
  }
  
  return(fuzzy_rast)
}

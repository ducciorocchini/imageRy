im.fuzzy <- function(input_image, 
                     num_clusters = 3, 
                     seed = NULL,
                     m = 2,                 # fuzzifier (m > 1), m=2 is common
                     do_plot = TRUE, 
                     custom_colors = NULL, 
                     num_colors = 100) {
  # ----------------------------
  # Checks
  # ----------------------------
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  nlyr <- terra::nlyr(input_image)
  if (nlyr > 3) {
    stop("This function is for RGB or grayscale images only. Reduce bands before classification.")
  }
  
  if (m <= 1) {
    stop("Fuzzifier 'm' must be > 1 (e.g., m = 2).")
  }
  
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
  
  # ----------------------------
  # Extract and scale pixel values
  # ----------------------------
  image_values <- terra::as.matrix(input_image)  # n_pixels x n_bands
  
  # Scale each band to 0–255 (same as your original function)
  for (i in seq_len(ncol(image_values))) {
    min_val <- min(image_values[, i], na.rm = TRUE)
    max_val <- max(image_values[, i], na.rm = TRUE)
    image_values[, i] <- 255 * (image_values[, i] - min_val) / (max_val - min_val)
  }
  
  # Keep track of which pixels are non-NA in the original raster
  template <- input_image[[1]]
  template_vals <- terra::values(template)
  valid_idx <- !is.na(template_vals)
  
  # Remove NA rows from values for clustering (assumes shared NA pattern)
  image_values_non_na <- image_values[valid_idx, , drop = FALSE]
  
  # ----------------------------
  # K-means clustering
  # ----------------------------
  if (!is.null(seed)) {
    set.seed(seed)
  }
  kmeans_result <- stats::kmeans(image_values_non_na, centers = num_clusters)
  centers <- kmeans_result$centers  # num_clusters x n_bands
  
  # ----------------------------
  # Distances to each cluster
  # ----------------------------
  n_pixels_non_na <- nrow(image_values_non_na)
  dist_matrix <- matrix(NA_real_, nrow = n_pixels_non_na, ncol = num_clusters)
  
  for (k in seq_len(num_clusters)) {
    diff_k <- sweep(image_values_non_na, 2, centers[k, ], FUN = "-")
    dist_matrix[, k] <- sqrt(rowSums(diff_k^2))
  }
  
  # ----------------------------
  # Fuzzy memberships from distances
  # ----------------------------
  exponent <- 2 / (m - 1)
  membership_matrix <- matrix(NA_real_, nrow = n_pixels_non_na, ncol = num_clusters)
  
  for (i in seq_len(n_pixels_non_na)) {
    d_i <- dist_matrix[i, ]
    
    # Handle exact centroid matches (distance 0)
    if (any(d_i == 0)) {
      u_i <- rep(0, num_clusters)
      zero_idx <- which(d_i == 0)
      # If multiple centroids at exactly same distance, split membership
      u_i[zero_idx] <- 1 / length(zero_idx)
    } else {
      # Standard fuzzy c-means membership:
      # u_ik = 1 / sum_j (d_ik / d_ij)^(2/(m-1))
      ratio <- outer(d_i, d_i, "/")^exponent  # num_clusters x num_clusters
      denom <- rowSums(ratio)
      u_i <- 1 / denom
    }
    
    membership_matrix[i, ] <- u_i
  }
  
  # ----------------------------
  # Build distance rasters
  # ----------------------------
  distance_layers <- vector("list", num_clusters)
  for (k in seq_len(num_clusters)) {
    r <- template
    vals <- rep(NA_real_, length(template_vals))
    vals[valid_idx] <- dist_matrix[, k]
    terra::values(r) <- vals
    distance_layers[[k]] <- r
  }
  distance_rast <- terra::rast(distance_layers)
  names(distance_rast) <- paste0("class_", seq_len(num_clusters), "_distance")
  
  # ----------------------------
  # Build membership rasters
  # ----------------------------
  membership_layers <- vector("list", num_clusters)
  for (k in seq_len(num_clusters)) {
    r <- template
    vals <- rep(NA_real_, length(template_vals))
    vals[valid_idx] <- membership_matrix[, k]
    terra::values(r) <- vals
    membership_layers[[k]] <- r
  }
  membership_rast <- terra::rast(membership_layers)
  names(membership_rast) <- paste0("class_", seq_len(num_clusters), "_membership")
  
  # ----------------------------
  # Plot (by default: memberships)
  # ----------------------------
  if (do_plot) {
    terra::plot(membership_rast, axes = FALSE, main = names(membership_rast))
  }
  
  # ----------------------------
  # Return BOTH distances and memberships
  # ----------------------------
  return(list(
    distances   = distance_rast,    # spectral distance to each class
    memberships = membership_rast,  # fuzzy membership (0–1, sum to 1 per pixel)
    centers     = centers           # cluster centroids (optional, useful for inspection)
  ))
}

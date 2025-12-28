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
  if (nlyr < 1) {
    stop("input_image must have at least 1 band.")
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
  # Extract pixel values
  # ----------------------------
  image_values <- terra::as.matrix(input_image)  # n_pixels x n_bands

  # VALID pixels: keep only rows where ALL bands are non-NA
  # (safer than assuming band-1 NA pattern)
  valid_idx <- stats::complete.cases(image_values)

  image_values_non_na <- image_values[valid_idx, , drop = FALSE]

  if (nrow(image_values_non_na) == 0) {
    stop("No valid pixels found (all rows contain NA in at least one band).")
  }

  # ----------------------------
  # Scale each band to 0–255
  # ----------------------------
  # Guard against constant bands (max == min)
  for (i in seq_len(ncol(image_values_non_na))) {
    min_val <- min(image_values_non_na[, i], na.rm = TRUE)
    max_val <- max(image_values_non_na[, i], na.rm = TRUE)

    if (!is.finite(min_val) || !is.finite(max_val)) {
      stop("Non-finite values detected in band ", i, ".")
    }

    if (max_val == min_val) {
      # constant band: set to 0 (or you could drop the band)
      image_values_non_na[, i] <- 0
    } else {
      image_values_non_na[, i] <- 255 * (image_values_non_na[, i] - min_val) / (max_val - min_val)
    }
  }

  # ----------------------------
  # K-means clustering
  # ----------------------------
  if (!is.null(seed)) set.seed(seed)

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
      u_i[zero_idx] <- 1 / length(zero_idx)
    } else {
      ratio <- outer(d_i, d_i, "/")^exponent
      denom <- rowSums(ratio)
      u_i <- 1 / denom
    }

    membership_matrix[i, ] <- u_i
  }

  # ----------------------------
  # Build rasters (template geometry)
  # ----------------------------
  template <- input_image[[1]]
  template_vals <- terra::values(template)

  # We must map back into full-length vector of cells
  # valid_idx is in "matrix row" order which corresponds to terra::values order.
  # Create full vectors (Ncells) and fill only valid cells.
  distance_layers <- vector("list", num_clusters)
  membership_layers <- vector("list", num_clusters)

  for (k in seq_len(num_clusters)) {
    # Distances
    r_d <- template
    vals_d <- rep(NA_real_, length(template_vals))
    vals_d[valid_idx] <- dist_matrix[, k]
    terra::values(r_d) <- vals_d
    distance_layers[[k]] <- r_d

    # Memberships
    r_m <- template
    vals_m <- rep(NA_real_, length(template_vals))
    vals_m[valid_idx] <- membership_matrix[, k]
    terra::values(r_m) <- vals_m
    membership_layers[[k]] <- r_m
  }

  distance_rast <- terra::rast(distance_layers)
  names(distance_rast) <- paste0("class_", seq_len(num_clusters), "_distance")

  membership_rast <- terra::rast(membership_layers)
  names(membership_rast) <- paste0("class_", seq_len(num_clusters), "_membership")

  # ----------------------------
  # Plot (memberships)
  # ----------------------------
  if (do_plot) {
    terra::plot(membership_rast, axes = FALSE, main = names(membership_rast))
  }

  # ----------------------------
  # Return
  # ----------------------------
  list(
    distances   = distance_rast,
    memberships = membership_rast,
    centers     = centers
  )
}

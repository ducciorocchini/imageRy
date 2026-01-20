#' Fuzzy clustering of a raster image (k-means + fuzzy memberships)
#'
#' Performs fuzzy classification of a \code{SpatRaster} image by first estimating
#' cluster centers with k-means and then computing fuzzy membership maps from
#' pixel-to-center distances using a fuzzifier parameter \code{m}.
#'
#' @param input_image A \code{SpatRaster} object containing one or more bands to be used as features.
#'   Pixels with \code{NA} in any band are excluded from the analysis.
#' @param num_clusters Integer. Number of clusters (classes) to compute. Default: \code{3}.
#' @param seed Integer or \code{NULL}. Optional random seed for reproducible k-means results. Default: \code{NULL}.
#' @param m Numeric. Fuzzifier parameter (\eqn{m > 1}) controlling the degree of fuzziness in membership assignment;
#'   a common choice is \eqn{m = 2}. Default: \code{2}.
#' @param do_plot Logical. If \code{TRUE}, membership rasters are plotted using \code{\link[terra]{plot}}. Default: \code{TRUE}.
#' @param custom_colors Character vector. Optional custom colors used to build a plotting palette. If \code{NULL},
#'   a default palette is used. If fewer colors than \code{num_clusters} are provided, colors are interpolated.
#' @param num_colors Integer. Number of colors to generate for plotting palettes (when plotting). Default: \code{100}.
#'
#' @return A named \code{list} with components:
#' \describe{
#'   \item{distances}{A \code{SpatRaster} with \code{num_clusters} layers giving the Euclidean distance of each valid pixel to each cluster center.}
#'   \item{memberships}{A \code{SpatRaster} with \code{num_clusters} layers giving fuzzy membership values in \eqn{[0,1]} for each cluster (memberships per valid pixel sum to 1 across classes).}
#'   \item{centers}{A numeric matrix of k-means cluster centers with \code{num_clusters} rows and one column per input band (bands scaled to 0--255 prior to clustering).}
#' }
#'
#' @details
#' Pixel values are extracted from \code{input_image} and only complete cases across all bands are retained.
#' Each band is independently rescaled to the range \eqn{0-255} (constant bands are set to 0) prior to clustering.
#' Cluster centers are estimated with \code{\link[stats]{kmeans}} on non-\code{NA} pixels.
#'
#' For each valid pixel, Euclidean distances to all centers are computed and fuzzy memberships are derived from distances as:
#' \deqn{u_k(x) = \left[\sum_{j=1}^{K} \left(\frac{d_k(x)}{d_j(x)}\right)^{\frac{2}{m-1}}\right]^{-1},}
#' where \eqn{d_k(x)} is the distance from pixel \eqn{x} to center \eqn{k}, \eqn{K} is the number of clusters,
#' and \eqn{m} is the fuzzifier. If a pixel matches one or more centers exactly (distance 0),
#' membership is equally shared among the zero-distance centers.
#'
#' If \code{do_plot = TRUE}, membership rasters are displayed using the selected palette.
#'
#' @references
#' Fuzzy C-means / membership formulas are standard (see Bezdek, 1981). K-means is used here to obtain initial centers.
#' @seealso \code{\link[stats]{kmeans}}, \code{\link[terra:SpatRaster-class]{SpatRaster}}, \code{\link[grDevices]{colorRampPalette}}
#'
#' @examples
#' \dontrun{
#' library(terra)
#' # Load example image (replace with your own)
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Run fuzzy clustering with 4 clusters
#' res <- im.fuzzy(r, num_clusters = 4, m = 2, seed = 1, do_plot = TRUE)
#'
#' # Inspect outputs
#' res$memberships
#' res$distances
#' res$centers
#' }
#'
#' @export
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

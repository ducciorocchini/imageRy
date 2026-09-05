#' Classify a Raster Image Using K-Means Clustering
#'
#' This function performs unsupervised classification of a raster image using
#' k-means clustering. Each raster cell is assigned to a cluster according to
#' its values across the raster layers.
#'
#' @param input_image A `SpatRaster` object representing the input raster image.
#' @param num_clusters A positive integer greater than or equal to 2 specifying
#' the number of clusters (default: 3).
#' @param seed An optional integer used as the random seed for reproducible
#' k-means classification (default: NULL).
#' @param do_plot A logical value indicating whether the classified raster
#' should be displayed using the default `terra::plot()` method
#' (default: TRUE).
#'
#' @return A single-layer `SpatRaster` containing the cluster assignment of
#' each raster cell.
#'
#' @details
#' The function extracts raster values and treats each complete raster cell as
#' a multidimensional observation, with raster layers representing variables.
#' K-means clustering is then applied to the complete observations.
#'
#' Cells containing missing values in one or more raster layers are excluded
#' from the clustering and assigned `NA` in the resulting classified raster.
#'
#' If `do_plot = TRUE`, the output is displayed using `terra::plot()`.
#' Consequently, the plot produced directly by `im.classify()` is identical
#' to the plot obtained by subsequently applying `plot()` to the returned
#' raster.
#'
#' @seealso [im.boxplot.classes()], [im.barplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load a raster image
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Perform k-means classification
#' classes <- im.classify(
#'   r,
#'   num_clusters = 4,
#'   seed = 42
#' )
#'
#' # This produces the same visualization
#' plot(classes)
#' }
#'
#' @export
im.classify <- function(
    input_image,
    num_clusters = 3,
    seed = NULL,
    do_plot = TRUE
) {

  # Check input image
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
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

  # Check plotting argument
  if (!is.logical(do_plot) ||
      length(do_plot) != 1 ||
      is.na(do_plot)) {
    stop("do_plot must be either TRUE or FALSE.")
  }

  # Extract raster values
  image_values <- terra::values(
    input_image,
    mat = TRUE
  )

  # Retain cells containing values in every raster layer
  complete_pixels <- stats::complete.cases(
    image_values
  )

  if (!any(complete_pixels)) {
    stop(
      "The input raster contains no complete pixel observations."
    )
  }

  image_values_complete <- image_values[
    complete_pixels,
    ,
    drop = FALSE
  ]

  # Check that enough complete cells are available
  if (nrow(image_values_complete) < num_clusters) {
    stop(
      paste(
        "The number of complete raster cells must be",
        "greater than or equal to num_clusters."
      )
    )
  }

  # Set the random seed
  if (!is.null(seed)) {
    set.seed(seed)
  }

  # Perform k-means classification
  kmeans_result <- stats::kmeans(
    x = image_values_complete,
    centers = num_clusters
  )

  # Create a single-layer output raster
  classified_image <- input_image[[1]]

  # Initialize all cells as missing
  classified_values <- rep(
    NA_integer_,
    terra::ncell(classified_image)
  )

  # Assign cluster values to complete cells
  classified_values[complete_pixels] <-
    kmeans_result$cluster

  # Store classifications in the output raster
  terra::values(classified_image) <-
    classified_values

  names(classified_image) <- "class"

  # Display the output using the standard terra method
    if (isTRUE(do_plot)) {
    
      class_colors <- viridisLite::viridis(
        num_clusters
      )
    
      terra::plot(
        classified_image,
        col = class_colors
      )
    }

  return(classified_image)
}

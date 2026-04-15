#' Visualize Spectral Distributions Across Classes Using Boxplots
#'
#' This function generates boxplots of raster values grouped by classes derived from a classified image.
#' It allows comparison of spectral distributions across classes, with optional density overlays,
#' median labels, and custom visualization settings.
#'
#' @param input_image A `SpatRaster` object representing the input raster (single or multi-layer).
#' @param classified_image A `SpatRaster` object with a single layer representing class assignments.
#' @param layer A numeric index or character string specifying which layer of `input_image` to visualize (default: 1).
#' @param density A logical value indicating whether to overlay half-eye density plots (default: TRUE).
#' @param median_labels A logical value indicating whether to display median values on the plot (default: FALSE).
#' @param legend A logical value indicating whether to display the legend (default: FALSE).
#' @param limits A numeric vector of length 2 specifying quantile limits (between 0 and 1) for the y-axis (default: NULL).
#' @param custom_colors A character vector specifying colors for the classes (default: NULL).
#'
#' @return A `ggplot` object showing the distribution of pixel values per class.
#'
#' @details
#' The function combines spectral information from a raster image with class assignments
#' from a classified raster to visualize how pixel values are distributed across classes.
#'
#' Each class is represented by a boxplot summarizing:
#' \itemize{
#'   \item Median values
#'   \item Interquartile range (IQR)
#'   \item Distribution spread (excluding outliers by default)
#' }
#'
#' Optional density overlays (half-eye plots) provide a smoothed representation of the
#' distribution, facilitating interpretation of class separability in spectral space.
#'
#' Additional options:
#' \itemize{
#'   \item `density = TRUE` overlays kernel density estimates for each class.
#'   \item `median_labels = TRUE` annotates each class with its median value.
#'   \item `limits` restricts the y-axis to selected quantiles, improving visualization of central distributions.
#'   \item `custom_colors` allows user-defined color palettes for classes.
#' }
#'
#' From an informatics perspective, this function provides a link between classification outputs
#' and spectral feature space, enabling the evaluation of class separability and internal variability.
#' It supports interpretation of classification results by explicitly showing how pixel values are
#' distributed within and across classes.
#'
#' @seealso [im.classify()], [im.barplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggplot2)
#'
#' # Load example raster
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#'
#' # Perform classification
#' classified <- im.classify(r, num_clusters = 3)
#'
#' # Plot spectral distributions for layer 1
#' im.boxplot(r, classified, layer = 1, density = TRUE)
#' }
#'
#' @export
im.boxplot <- function(input_image, classified_image, 
                       layer = 1, # specify the layer to be displayed
                       density = TRUE, # TRUE for adding a half-eye density plot 
                       median_labels = FALSE, # TRUE for adding median labels
                       legend = FALSE, # TRUE for adding a legend
                       limits = NULL, # restrict the visible y-axis range to selected quantiles
                       custom_colors = NULL) { # specify a color palette
  
  # Check input image
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  # Check classified image
  if (!inherits(classified_image, "SpatRaster")) {
    stop("classified_image should be a SpatRaster object.")
  }
  
  if (terra::nlyr(classified_image) != 1) {
    stop("classified_image should have a single layer.")
  }
  
  # Select layer by index or name
  if (is.numeric(layer)) {
    if (layer < 1 || layer > terra::nlyr(input_image)) {
      stop("layer exceeds the number of layers in input_image.")
    }
    layer_name <- names(input_image)[layer]
    layer_rast <- input_image[[layer]]
    
  } else if (is.character(layer)) {
    if (!layer %in% names(input_image)) {
      stop("layer name not found in input_image.")
    }
    layer_name <- layer
    layer_rast <- input_image[[layer]]
    
  } else {
    stop("layer must be either a numeric index or a layer name.")
  }
  
  # Build the  data frame
  df <- terra::as.data.frame(c(layer_rast, classified_image), na.rm = TRUE)
  names(df) <- c("value", "Class")
  df$Class <- as.factor(df$Class)
  
  # Basic plot
  p <- ggplot2::ggplot(
    data = df,
    mapping = ggplot2::aes(x = Class, y = value, colour = Class)
  ) +
    ggplot2::geom_boxplot(
      width = 0.30,
      outlier.shape = NA,
      outlier.color = NA
    ) +
    ggplot2::labs(y = layer_name)
  
  # Optional density layer
  if (isTRUE(density)) {
    p <- p +
      ggdist::stat_halfeye(
        ggplot2::aes(fill = Class),
        adjust = 0.5,
        width = 0.5,
        .width = 0,
        justification = -0.4,
        point_colour = NA,
        alpha = 0.5
      )
  }
  
  # Optional median labels
  if (isTRUE(median_labels)) {
    p <- p +
      ggplot2::stat_summary(
        fun = "median",
        geom = "text",
        size = 3,
        ggplot2::aes(label = round(ggplot2::after_stat(y), 3)),
        position = ggplot2::position_nudge(x = -0.3)
      )
  }
  
  # Optional quantile limits
  if (!is.null(limits)) {
    if (!is.numeric(limits) || length(limits) != 2) {
      stop("limits must be a numeric vector of length 2.")
    }
    if (any(limits < 0 | limits > 1)) {
      stop("limits must contain quantile probabilities between 0 and 1.")
    }
    
    p <- p +
      ggplot2::scale_y_continuous(
        limits = stats::quantile(df$value, probs = limits, na.rm = TRUE)
      )
  }
  
  # Optional custom colors
  if (!is.null(custom_colors)) {
    if (!is.character(custom_colors)) {
      stop("custom_colors must be a character vector of valid color names or hex codes.")
    }
    
    n_classes <- nlevels(df$Class)
    pal <- grDevices::colorRampPalette(custom_colors)(n_classes)
    
    p <- p + ggplot2::scale_colour_manual(values = pal)
    
    if (isTRUE(density)) {
      p <- p + ggplot2::scale_fill_manual(values = pal)
    }
  }
  
  # Optional legend
  if (!isTRUE(legend)) {
    p <- p +
      ggplot2::guides(colour = "none", fill = "none")
  }
  
  return(p)
}

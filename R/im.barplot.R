#' Plot Class Distribution from a Classified Raster
#'
#' This function generates a bar plot summarizing the distribution of classes in a classified raster image.
#' It can display either absolute pixel counts or percentages, with optional labels and custom color palettes.
#'
#' @param classified_image A `SpatRaster` object representing a classified raster with a single layer.
#' @param perc A logical value indicating whether to plot percentages instead of counts (default: FALSE).
#' @param counts A logical value indicating whether to display numeric labels above bars (default: FALSE).
#' @param rescale A logical value indicating whether to rescale the y-axis to full range (default: FALSE).
#' @param custom_colors A character vector of colors to be used for the bar plot (default: NULL).
#'
#' @return A `ggplot` object representing the distribution of classes in the raster.
#'
#' @details
#' The function extracts pixel values from a classified raster and summarizes them as a bar plot.
#' Each class corresponds to a category, and the height of the bars represents either:
#' \itemize{
#'   \item The number of pixels per class (default), or
#'   \item The percentage of pixels per class (if `perc = TRUE`)
#' }
#'
#' Additional options:
#' \itemize{
#'   \item If `counts = TRUE`, numeric values are displayed above each bar.
#'   \item If `rescale = TRUE`, the y-axis is fixed to the full range (0–100 for percentages or total pixel count).
#'   \item If `custom_colors` is provided, it is used to define the color palette of the plot.
#' }
#'
#' This function is particularly useful for summarizing the output of unsupervised or supervised classification
#' and linking spatial patterns to quantitative class proportions.
#'
#' @seealso [im.classify()], [im.kernel()]
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
#' # Plot class distribution
#' im.barplot(classified, perc = TRUE, counts = TRUE)
#' }
#'
#' @export
im.barplot <- function(classified_image,
                       perc = FALSE, # TRUE for bars showing the percentage of pixels per class
                       counts = FALSE, # TRUE for adding numeric labels above the bars
                       rescale = FALSE, # TRUE for rescaling the y-axis
                       custom_colors = NULL) { # add custom colors
  
  # Check input
  if (!inherits(classified_image, "SpatRaster")) {
    stop("classified_image should be a SpatRaster.")
  }
  
  if (terra::nlyr(classified_image) != 1) {
    stop("classified_image should have a single layer.")
  }
  
  # Extract values
  df <- terra::as.data.frame(classified_image, na.rm = TRUE)
  names(df) <- "class"
  df$class <- as.factor(df$class)
  
  # Total number of pixels
  total_pixels <- nrow(df)
  
  # Basic plot
  if (isTRUE(perc)) {
    p <- ggplot2::ggplot(df, ggplot2::aes(x = class, fill = class)) +
      ggplot2::geom_bar(ggplot2::aes(y = ggplot2::after_stat(count / sum(count) * 100)))
    
    if (isTRUE(counts)) {
      p <- p +
        ggplot2::geom_text(
          stat = "count",
          ggplot2::aes(
            y = ggplot2::after_stat(count / sum(count) * 100),
            label = round(ggplot2::after_stat(count / sum(count) * 100), 2),
            colour = class
          ),
          vjust = -0.3,
          size = 3,
          show.legend = FALSE
        )
    }
    
    p <- p + ggplot2::labs(x = "Class", y = "Percentage")
    
    if (isTRUE(rescale)) {
      p <- p + ggplot2::scale_y_continuous(limits = c(0, 100))
    }
    
  } else {
    p <- ggplot2::ggplot(df, ggplot2::aes(x = class, fill = class)) +
      ggplot2::geom_bar()
    
    if (isTRUE(counts)) {
      p <- p +
        ggplot2::geom_text(
          stat = "count",
          ggplot2::aes(label = ggplot2::after_stat(count), colour = class),
          vjust = -0.3,
          size = 3,
          show.legend = FALSE
        )
    }
    
    p <- p + ggplot2::labs(x = "Class", y = "Number of pixels")
    
    if (isTRUE(rescale)) {
      p <- p + ggplot2::scale_y_continuous(limits = c(0, total_pixels))
    }
  }
  
  # Optional custom colors
  if (!is.null(custom_colors)) {
    if (!is.character(custom_colors)) {
      stop("custom_colors must be a character vector of valid color names or hex codes.")
    }
    
    n_classes <- nlevels(df$class)
    pal <- grDevices::colorRampPalette(custom_colors)(n_classes)
    
    p <- p +
      ggplot2::scale_fill_manual(values = pal) +
      ggplot2::scale_colour_manual(values = pal)
  }
  
  # Final plot
  p <- p +
    ggplot2::guides(fill = "none", colour = "none")
  
  return(p)
}

#' Plot Spectral Scatterplot from Classified Raster Images
#'
#' This function generates a scatterplot comparing pixel values from two raster bands,
#' with points colored according to a classified raster image.
#' It can optionally display marginal density plots for each class, with customizable
#' colors, point sizes, transparency, and axis labels.
#'
#' @param band_x A single-layer `SpatRaster` object representing the x-axis values.
#' @param band_y A single-layer `SpatRaster` object representing the y-axis values.
#' @param classified_image A single-layer `SpatRaster` object containing classification results.
#' @param n_sample An optional positive integer specifying the number of pixels to sample
#'   for the scatterplot (default: NULL, all valid pixels).
#' @param seed An optional integer seed for reproducible random sampling (default: NULL).
#' @param marginal A logical value indicating whether to display marginal density plots
#'   for the two raster bands (default: TRUE).
#' @param legend A logical value indicating whether to display the class legend
#'   (default: TRUE).
#' @param custom_colors A character vector of colors to be used for the classes
#'   (default: NULL, viridis palette).
#' @param point_size A numeric value specifying the size of scatterplot points
#'   (default: 1.8).
#' @param alpha A numeric value controlling point transparency, between 0 and 1
#'   (default: 0.6).
#' @param title An optional title for the scatterplot (default: NULL).
#' @param subtitle An optional subtitle for the scatterplot (default: NULL).
#' @param xlab An optional label for the x-axis (default: NULL, raster layer name).
#' @param ylab An optional label for the y-axis (default: NULL, raster layer name).
#'
#' @return A `ggplot` object representing the spectral scatterplot when
#'   `marginal = FALSE`, or a `patchwork` object combining the scatterplot
#'   and marginal density plots when `marginal = TRUE`.
#'
#' @details
#' The function extracts pixel values from two raster bands and associates
#' each observation with its corresponding class in a classified raster.
#' All input rasters must have matching spatial geometry and contain a single layer.
#' Class identifiers must be positive integers.
#'
#' Each point in the scatterplot represents a pixel, with:
#' \itemize{
#'   \item The x-coordinate corresponding to the value of `band_x`.
#'   \item The y-coordinate corresponding to the value of `band_y`.
#'   \item The point color representing the classification assigned to that pixel.
#' }
#'
#' Additional options:
#' \itemize{
#'   \item If `n_sample` is specified, a random subset of pixels is used
#'   for the scatterplot, reducing visual clutter and plotting time.
#'   \item If `seed` is provided, random sampling is reproducible.
#'   \item If `marginal = TRUE`, marginal density plots show the distribution
#'   of pixel values for each class along both axes.
#'   \item Marginal densities are calculated using all valid pixels,
#'   independently of `n_sample`.
#'   \item If `legend = FALSE`, the class legend is hidden.
#'   \item If `custom_colors` is provided, it defines the class color palette.
#'   \item If fewer colors than classes are supplied, colors are interpolated.
#' }
#'
#' The function is particularly useful for exploring spectral separability
#' among land-cover classes, evaluating classification results, and identifying
#' overlapping spectral signatures in multispectral remote sensing imagery.
#'
#' @seealso [im.classify()], [im.barplot()], [im.kernel()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggplot2)
#'
#' # Load example raster
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#'
#' # Create two raster bands
#' band_x <- r
#' band_y <- r * 0.8 + 10
#'
#' # Perform classification
#' classified <- im.classify(r, num_clusters = 3)
#'
#' # Plot spectral scatterplot with marginal densities
#' im.scatter(band_x, band_y, classified)
#'
#' # Plot a random sample without marginal densities
#' im.scatter(
#'   band_x, band_y, classified,
#'   n_sample = 1000,
#'   seed = 42,
#'   marginal = FALSE
#' )
#'
#' # Customize colors and point appearance
#' im.scatter(
#'   band_x, band_y, classified,
#'   custom_colors = c("red", "green", "blue"),
#'   point_size = 1,
#'   alpha = 0.4,
#'   title = "Spectral Separability",
#'   xlab = "Band X",
#'   ylab = "Band Y"
#' )
#' }
#'
#' @export
im.scatter <- function(band_x, # single layer raster for the x-axis
                       band_y, # single layer raster for the y-axis
                       classified_image, # classified raster with same geometry 
                       n_sample = NULL, # numer of pixels to sample
                       seed = NULL, # seed for reproducibility
                       marginal = TRUE, # TRUE for showing marginal density plots
                       legend = TRUE, # TRUE for showing the class legend
                       custom_colors = NULL, # specify a color palette
                       point_size = 1.8, # size of scatterplot points
                       alpha = 0.6, # transparency of scatterplot points
                       title = NULL, # plot title
                       subtitle = NULL, # plot subtitle
                       xlab = NULL, # x-axis labels
                       ylab = NULL) { # y-axis labels
  
  # Check input rasters
  for (r in list(band_x, band_y, classified_image)) {
    if (!inherits(r, "SpatRaster")) {
      stop("All inputs must be SpatRaster objects.")
    }

    if (terra::nlyr(r) != 1) {
      stop("Each input raster must have a single layer.")
    }
  }

  # Check spatial compatibility
  if (!terra::compareGeom(
    band_x, band_y,
    stopOnError = FALSE
  ) ||
    !terra::compareGeom(
      band_x, classified_image,
      stopOnError = FALSE
    )) {
    stop("All input rasters must have matching geometry.")
  }

  # Check sample size
  if (!is.null(n_sample)) {
    if (!is.numeric(n_sample) ||
      length(n_sample) != 1 ||
      !is.finite(n_sample) ||
      n_sample < 1 ||
      n_sample %% 1 != 0) {
      stop("n_sample must be NULL or a positive integer.")
    }
  }

  # Check seed
  if (!is.null(seed)) {
    if (!is.numeric(seed) ||
      length(seed) != 1 ||
      !is.finite(seed) ||
      seed %% 1 != 0) {
      stop("seed must be NULL or a single integer.")
    }
  }

  # Check marginal
  if (!is.logical(marginal) ||
    length(marginal) != 1 ||
    is.na(marginal)) {
    stop("marginal must be TRUE or FALSE.")
  }

  # Check legend
  if (!is.logical(legend) ||
    length(legend) != 1 ||
    is.na(legend)) {
    stop("legend must be TRUE or FALSE.")
  }

  # Check point size
  if (!is.numeric(point_size) ||
    length(point_size) != 1 ||
    !is.finite(point_size) ||
    point_size <= 0) {
    stop("point_size must be a positive number.")
  }

  # Check alpha
  if (!is.numeric(alpha) ||
    length(alpha) != 1 ||
    !is.finite(alpha) ||
    alpha < 0 ||
    alpha > 1) {
    stop("alpha must be a number between 0 and 1.")
  }

  # Extract raster values
  df <- terra::as.data.frame(
    c(band_x, band_y, classified_image),
    na.rm = TRUE
  )

  names(df) <- c("X", "Y", "Class")

  # Remove non-finite observations
  df <- df[
    is.finite(df$X) &
      is.finite(df$Y) &
      is.finite(df$Class), ,
    drop = FALSE
  ]

  if (nrow(df) == 0) {
    stop("No valid pixels found.")
  }

  # Identify classes
  class_values <- sort(unique(df$Class))

  if (any(class_values < 1 |
    class_values %% 1 != 0)) {
    stop("Class IDs must be positive integers.")
  }

  # Obtain maximum class ID from the classified raster
  n_classes <- terra::global(
    classified_image,
    fun = "max",
    na.rm = TRUE
  )[1, 1]

  if (!is.finite(n_classes) ||
    n_classes < 1 ||
    n_classes %% 1 != 0) {
    stop("Invalid class IDs in classified_image.")
  }

  # Preserve original class IDs
  class_levels <- paste("Class", class_values)

  df$Class <- factor(
    df$Class,
    levels = class_values,
    labels = class_levels
  )

  # Define colours
  if (is.null(custom_colors)) {
    # Same default palette as im.classify()
    all_colors <- viridisLite::viridis(n_classes)
  } else {
    if (!is.character(custom_colors) ||
      length(custom_colors) == 0 ||
      anyNA(custom_colors)) {
      stop("custom_colors must be a character vector of colours.")
    }

    tryCatch(
      grDevices::col2rgb(custom_colors),
      error = function(e) {
        stop("custom_colors contains invalid colours.")
      }
    )

    if (length(custom_colors) < n_classes) {
      if (length(custom_colors) < 2) {
        stop("At least two colours are needed for interpolation.")
      }

      all_colors <- grDevices::colorRampPalette(
        custom_colors
      )(n_classes)
    } else {
      all_colors <- custom_colors[seq_len(n_classes)]
    }
  }

  # Associate colours with original class IDs
  class_colors <- stats::setNames(
    all_colors[as.integer(class_values)],
    class_levels
  )

  # Sample pixels for the scatterplot
  plot_data <- df

  if (!is.null(n_sample) && nrow(df) > n_sample) {
    if (!is.null(seed)) {
      set.seed(seed)
    }

    plot_data <- df[
      sample.int(nrow(df), n_sample), ,
      drop = FALSE
    ]
  }

  # Set axis labels
  if (is.null(xlab)) xlab <- names(band_x)[1]
  if (is.null(ylab)) ylab <- names(band_y)[1]

  # Define shared axis limits
  x_limits <- range(df$X)
  y_limits <- range(df$Y)

  x_pad <- max(diff(x_limits) * 0.03, 0.01)
  y_pad <- max(diff(y_limits) * 0.03, 0.01)

  x_limits <- x_limits + c(-x_pad, x_pad)
  y_limits <- y_limits + c(-y_pad, y_pad)

  # Build scatterplot
  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = X,
      y = Y,
      colour = Class
    )
  ) +
    ggplot2::geom_point(
      size = point_size,
      alpha = alpha
    ) +
    ggplot2::scale_colour_manual(
      values = class_colors,
      breaks = class_levels,
      drop = FALSE
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = xlab,
      y = ylab,
      colour = "Class"
    ) +
    ggplot2::coord_cartesian(
      xlim = x_limits,
      ylim = y_limits,
      expand = FALSE
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold"),
      legend.position = if (legend) "bottom" else "none"
    )

  # Return scatterplot without marginal densities
  if (!marginal) {
    return(p)
  }

  # Check patchwork
  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("Package 'patchwork' is required for marginal plots.")
  }

  # Retain classes with sufficient observations
  # for density estimation
  class_counts <- table(df$Class)
  valid_classes <- names(class_counts[class_counts >= 2])

  density_data <- df[df$Class %in% valid_classes, ]

  if (nrow(density_data) == 0) {
    warning("Not enough observations for density plots.")
    return(p)
  }

  # Marginal density for the x-axis
  p_x <- ggplot2::ggplot(
    density_data,
    ggplot2::aes(
      x = X,
      fill = Class,
      colour = Class
    )
  ) +
    ggplot2::geom_density(
      alpha = 0.3,
      linewidth = 0.5
    ) +
    ggplot2::scale_fill_manual(
      values = class_colors,
      guide = "none"
    ) +
    ggplot2::scale_colour_manual(
      values = class_colors,
      guide = "none"
    ) +
    ggplot2::coord_cartesian(
      xlim = x_limits,
      expand = FALSE
    ) +
    ggplot2::theme_void()

  # Marginal density for the y-axis
  p_y <- ggplot2::ggplot(
    density_data,
    ggplot2::aes(
      x = Y,
      fill = Class,
      colour = Class
    )
  ) +
    ggplot2::geom_density(
      alpha = 0.3,
      linewidth = 0.5
    ) +
    ggplot2::scale_fill_manual(
      values = class_colors,
      guide = "none"
    ) +
    ggplot2::scale_colour_manual(
      values = class_colors,
      guide = "none"
    ) +
    ggplot2::coord_flip(
      xlim = y_limits,
      expand = FALSE
    ) +
    ggplot2::theme_void()

  # Combine plots
  final_plot <- patchwork::wrap_plots(
    p_x,
    patchwork::plot_spacer(),
    p,
    p_y,
    design = "AB\nCD",
    widths = c(4, 1),
    heights = c(1, 4)
  )

  return(final_plot)
}

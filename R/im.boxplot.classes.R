#' Visualize Spectral Distributions Across Classes
#'
#' This function visualizes raster-value distributions across image classes
#' derived from a classified raster. It can display boxplots or violin plots,
#' optionally combined with half-eye kernel density estimates, median labels,
#' quantile-based display limits, custom colors, and non-parametric statistical
#' comparisons among classes.
#'
#' @param input_image A `SpatRaster` object representing the input raster
#'   image, containing one or more layers.
#' @param classified_image A single-layer `SpatRaster` containing class
#'   assignments, typically produced by [im.classify()].
#' @param layer A numeric index or character string specifying the layer of
#'   `input_image` to visualize (default: 1).
#' @param density A logical value indicating whether to add half-eye kernel
#'   density estimates (default: TRUE). Ignored when `violin = TRUE`.
#' @param median_labels A logical value indicating whether to display median
#'   values for each class (default: FALSE).
#' @param median_position A numeric value controlling the position of median
#'   labels along the class axis (default: -0.3).
#' @param legend A logical value indicating whether to display the legend
#'   (default: FALSE).
#' @param limits An optional numeric vector of length two specifying lower and
#'   upper quantile probabilities used to restrict the displayed value range
#'   (default: NULL).
#' @param custom_colors An optional character vector specifying custom colors.
#'   If `NULL`, the same viridis color scale used by the default
#'   `terra::plot()` method is applied.
#' @param flip A logical value indicating whether to flip the plot coordinates
#'   (default: FALSE).
#' @param violin A logical value indicating whether to display violin plots
#'   instead of boxplots (default: FALSE).
#' @param stat_test A logical value indicating whether to perform a
#'   non-parametric comparison among classes (default: FALSE). A Wilcoxon
#'   rank-sum test is used for two classes and a Kruskal-Wallis test for more
#'   than two classes. Results are printed in the console.
#'
#' @return A `ggplot` object showing raster-value distributions for each class.
#'
#' @details
#' Pixel values are extracted from the selected layer of `input_image` and
#' grouped according to the classes stored in `classified_image`.
#'
#' When `custom_colors = NULL`, class colors are sampled from the viridis scale
#' used by the standard `terra::plot()` method. Consequently, the classes in
#' the distribution plot use the same colors as the classified raster.
#'
#' @seealso [im.classify()], [im.barplot()], [im.boxplot.layers()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' canale <- rast("canale.jpg")
#'
#' classes <- im.classify(
#'   canale,
#'   num_clusters = 4,
#'   seed = 42
#' )
#'
#' im.boxplot.classes(
#'   canale,
#'   classes,
#'   layer = 2,
#'   density = TRUE,
#'   median_labels = TRUE,
#'   legend = TRUE
#' )
#' }
#'
#' @export
im.boxplot.classes <- function(
    input_image,
    classified_image,
    layer = 1,
    density = TRUE,
    median_labels = FALSE,
    median_position = -0.3,
    legend = FALSE,
    limits = NULL,
    custom_colors = NULL,
    flip = FALSE,
    violin = FALSE,
    stat_test = FALSE
) {

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

  # Check spatial compatibility
  if (!terra::compareGeom(
    input_image,
    classified_image,
    stopOnError = FALSE
  )) {
    stop(
      paste(
        "input_image and classified_image must have matching",
        "extent, resolution, origin and coordinate reference system."
      )
    )
  }

  # Check logical arguments
  if (!is.logical(density) ||
      length(density) != 1 ||
      is.na(density)) {
    stop("density must be either TRUE or FALSE.")
  }

  if (!is.logical(median_labels) ||
      length(median_labels) != 1 ||
      is.na(median_labels)) {
    stop("median_labels must be either TRUE or FALSE.")
  }

  if (!is.logical(legend) ||
      length(legend) != 1 ||
      is.na(legend)) {
    stop("legend must be either TRUE or FALSE.")
  }

  if (!is.logical(flip) ||
      length(flip) != 1 ||
      is.na(flip)) {
    stop("flip must be either TRUE or FALSE.")
  }

  if (!is.logical(violin) ||
      length(violin) != 1 ||
      is.na(violin)) {
    stop("violin must be either TRUE or FALSE.")
  }

  if (!is.logical(stat_test) ||
      length(stat_test) != 1 ||
      is.na(stat_test)) {
    stop("stat_test must be either TRUE or FALSE.")
  }

  # Check median-label position
  if (!is.numeric(median_position) ||
      length(median_position) != 1 ||
      !is.finite(median_position)) {
    stop("median_position must be a single finite numeric value.")
  }

  # Warn if density is ignored
  if (isTRUE(violin) && isTRUE(density)) {
    warning("density is ignored when violin = TRUE.")
  }

  # Select layer by index or name
  if (is.numeric(layer)) {

    if (length(layer) != 1 ||
        is.na(layer) ||
        layer %% 1 != 0 ||
        layer < 1 ||
        layer > terra::nlyr(input_image)) {
      stop("layer must be a valid layer index.")
    }

    layer <- as.integer(layer)
    layer_name <- names(input_image)[layer]
    layer_rast <- input_image[[layer]]

  } else if (is.character(layer)) {

    if (length(layer) != 1 ||
        is.na(layer) ||
        !layer %in% names(input_image)) {
      stop("layer name not found in input_image.")
    }

    layer_name <- layer
    layer_rast <- input_image[[layer]]

  } else {
    stop("layer must be either a numeric index or a layer name.")
  }

  # Build data frame
  df <- terra::as.data.frame(
    c(layer_rast, classified_image),
    na.rm = TRUE
  )

  names(df) <- c("value", "Class")

  df <- df[
    is.finite(df$value) & !is.na(df$Class),
    ,
    drop = FALSE
  ]

  if (nrow(df) == 0) {
    stop("No complete raster values are available for plotting.")
  }

  # Store class values in ascending order
  class_values <- sort(unique(df$Class))
  n_classes <- length(class_values)

  if (n_classes < 1) {
    stop("No valid classes are available for plotting.")
  }

  # Convert class values to an ordered factor
  df$Class <- factor(
    df$Class,
    levels = class_values
  )

  # Optional statistical comparison
  if (isTRUE(stat_test)) {

    if (n_classes < 2) {
      stop(
        "At least two classes are required to perform a statistical test."
      )
    }

    warning(
      paste(
        "Wilcoxon and Kruskal-Wallis tests treat raster cells as",
        "independent observations. Spatial autocorrelation may inflate",
        "the test statistic and produce overly small p-values."
      )
    )

    if (n_classes == 2) {

      cat("\nWilcoxon rank-sum test\n\n")

      print(
        stats::wilcox.test(
          value ~ Class,
          data = df,
          exact = FALSE
        )
      )

    } else {

      cat("\nKruskal-Wallis rank-sum test\n\n")

      print(
        stats::kruskal.test(
          value ~ Class,
          data = df
        )
      )
    }
  }

  # Build basic plot
  p <- ggplot2::ggplot(
    data = df,
    mapping = ggplot2::aes(
      x = Class,
      y = value,
      colour = Class
    )
  ) +
    ggplot2::labs(
      x = "Class",
      y = layer_name,
      colour = "Class",
      fill = "Class"
    )

  # Add either boxplots or violin plots
  if (isTRUE(violin)) {

    p <- p +
      ggplot2::geom_violin(
        mapping = ggplot2::aes(fill = Class),
        width = 0.7,
        alpha = 0.5,
        trim = TRUE
      )

  } else {

    p <- p +
      ggplot2::geom_boxplot(
        width = 0.30,
        outlier.shape = NA,
        outlier.colour = NA
      )
  }

  # Optional half-eye density layer
  if (isTRUE(density) && !isTRUE(violin)) {

    p <- p +
      ggdist::stat_halfeye(
        mapping = ggplot2::aes(fill = Class),
        adjust = 2,
        width = 0.5,
        .width = 0,
        justification = -0.4,
        point_colour = NA,
        slab_colour = NA,
        alpha = 0.5
      )
  }

  # Optional median labels
  if (isTRUE(median_labels)) {

    p <- p +
      ggplot2::stat_summary(
        fun = stats::median,
        geom = "text",
        size = 3,
        mapping = ggplot2::aes(
          label = round(
            ggplot2::after_stat(y),
            3
          )
        ),
        position = ggplot2::position_nudge(
          x = median_position
        ),
        show.legend = FALSE
      )
  }

  # Optional quantile limits
  if (!is.null(limits)) {

    if (!is.numeric(limits) ||
        length(limits) != 2 ||
        any(!is.finite(limits))) {
      stop("limits must be a finite numeric vector of length 2.")
    }

    if (any(limits < 0 | limits > 1)) {
      stop(
        "limits must contain quantile probabilities between 0 and 1."
      )
    }

    if (limits[1] >= limits[2]) {
      stop(
        "The first value of limits must be smaller than the second."
      )
    }

    value_limits <- stats::quantile(
      df$value,
      probs = limits,
      na.rm = TRUE,
      names = FALSE
    )

    p <- p +
      ggplot2::coord_cartesian(
        ylim = value_limits
      )
  }

  # Build class colors
  if (is.null(custom_colors)) {

    # Same viridis palette used by the standard terra plot
    color_palette <- terra::map.pal(
      "viridis",
      100
    )

  } else {

    if (!is.character(custom_colors) ||
        length(custom_colors) == 0) {
      stop(
        paste(
          "custom_colors must be a character vector",
          "of valid color names or hexadecimal codes."
        )
      )
    }

    if (length(custom_colors) == 1) {

      color_palette <- rep(
        custom_colors,
        100
      )

    } else {

      color_palette <- grDevices::colorRampPalette(
        custom_colors
      )(100)
    }
  }

  # Match each class to its position in the raster color scale
  if (n_classes == 1) {

    color_indices <- 1L

  } else {

    color_indices <- round(
      1 + (
        (class_values - min(class_values)) /
          (max(class_values) - min(class_values))
      ) * 99
    )
  }

  class_colors <- color_palette[color_indices]

  # Explicitly associate colors with class values
  names(class_colors) <- as.character(class_values)

  # Apply class colors
  p <- p +
    ggplot2::scale_colour_manual(
      values = class_colors,
      breaks = as.character(class_values),
      limits = as.character(class_values),
      drop = FALSE
    )

  # Apply fill colors where needed
  if (isTRUE(density) || isTRUE(violin)) {

    p <- p +
      ggplot2::scale_fill_manual(
        values = class_colors,
        breaks = as.character(class_values),
        limits = as.character(class_values),
        drop = FALSE
      )
  }

  # Optional legend
  if (!isTRUE(legend)) {

    p <- p +
      ggplot2::guides(
        colour = "none",
        fill = "none"
      )
  }

  # Optional coordinate flipping
  if (isTRUE(flip)) {
    p <- p +
      ggplot2::coord_flip()
  }

  return(p)
}

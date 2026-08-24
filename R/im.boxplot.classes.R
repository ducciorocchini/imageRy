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
    layer = 1, # specify the layer to be displayed
    density = TRUE, # TRUE for adding a half-eye density plot
    median_labels = FALSE, # TRUE for adding median labels
    median_position = -0.3, # position of median labels along the class axis
    legend = FALSE, # TRUE for adding a legend
    limits = NULL, # restrict the visible y-axis range to selected quantiles
    custom_colors = NULL, # specify a color palette
    flip = FALSE, # flip plot coordinates
    violin = FALSE # TRUE for using a violin plot instead of a boxplot
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
  
  # Check density
  if (!is.logical(density) ||
      length(density) != 1 ||
      is.na(density)) {
    stop("density must be either TRUE or FALSE.")
  }
  
  # Check median_labels
  if (!is.logical(median_labels) ||
      length(median_labels) != 1 ||
      is.na(median_labels)) {
    stop("median_labels must be either TRUE or FALSE.")
  }
  
  # Check median_position
  if (!is.numeric(median_position) ||
      length(median_position) != 1 ||
      is.na(median_position)) {
    stop("median_position must be a single numeric value.")
  }
  
  # Check legend
  if (!is.logical(legend) ||
      length(legend) != 1 ||
      is.na(legend)) {
    stop("legend must be either TRUE or FALSE.")
  }
  
  # Check flip
  if (!is.logical(flip) ||
      length(flip) != 1 ||
      is.na(flip)) {
    stop("flip must be either TRUE or FALSE.")
  }
  
  # Check violin
  if (!is.logical(violin) ||
      length(violin) != 1 ||
      is.na(violin)) {
    stop("violin must be either TRUE or FALSE.")
  }
  
  # Warn if density is ignored
  if (isTRUE(violin) && isTRUE(density)) {
    warning("density is ignored when violin = TRUE.")
  }
  
  # Select layer by index or name
  if (is.numeric(layer)) {
    
    if (length(layer) != 1 ||
        is.na(layer) ||
        layer < 1 ||
        layer > terra::nlyr(input_image)) {
      stop("layer exceeds the number of layers in input_image.")
    }
    
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
  
  # Build the data frame
  df <- terra::as.data.frame(
    c(layer_rast, classified_image),
    na.rm = TRUE
  )
  
  names(df) <- c("value", "Class")
  
  # Store class values in ascending numeric order
  class_values <- sort(unique(df$Class))
  n_classes <- length(class_values)
  
  # Convert classes to a factor with explicit level order
  df$Class <- factor(
    df$Class,
    levels = class_values
  )
  
  # Basic plot
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
      y = layer_name
    )
  
  # Add either a boxplot or a violin plot
  if (isTRUE(violin)) {
    
    p <- p +
      ggplot2::geom_violin(
        ggplot2::aes(fill = Class),
        width = 0.7,
        alpha = 0.5,
        trim = TRUE
      )
    
  } else {
    
    p <- p +
      ggplot2::geom_boxplot(
        width = 0.30,
        outlier.shape = NA,
        outlier.color = NA
      )
  }
  
  # Optional density layer
  if (isTRUE(density) && !isTRUE(violin)) {
    
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
        fun = stats::median,
        geom = "text",
        size = 3,
        ggplot2::aes(
          label = round(
            ggplot2::after_stat(y),
            3
          )
        ),
        position = ggplot2::position_nudge(
          x = median_position
        )
      )
  }
  
  # Optional quantile limits
  if (!is.null(limits)) {
    
    if (!is.numeric(limits) ||
        length(limits) != 2) {
      stop("limits must be a numeric vector of length 2.")
    }
    
    if (any(is.na(limits)) ||
        any(limits < 0 | limits > 1)) {
      stop(
        "limits must contain quantile probabilities between 0 and 1."
      )
    }
    
    if (limits[1] >= limits[2]) {
      stop(
        "The first value of limits must be smaller than the second."
      )
    }
    
    y_limits <- stats::quantile(
      df$value,
      probs = limits,
      na.rm = TRUE
    )
    
    p <- p +
      ggplot2::scale_y_continuous(
        limits = y_limits
      )
  }
  
  # Default palette used by im.classify()
  base_colors <- c("#0072B2", "#E69F00", "#009E73", "#CC79A7", 
                   "#000000", "#D55E00")
  
  # Select the base colors
  if (is.null(custom_colors)) {
    
    if (n_classes > length(base_colors)) {
      
      colors <- grDevices::colorRampPalette(
        base_colors
      )(n_classes)
      
    } else {
      
      colors <- base_colors[seq_len(n_classes)]
    }
    
  } else {
    
    if (!is.character(custom_colors) ||
        length(custom_colors) == 0) {
      stop(
        paste(
          "custom_colors must be a character vector",
          "of valid color names or hex codes."
        )
      )
    }
    
    if (n_classes > length(custom_colors)) {
      
      colors <- grDevices::colorRampPalette(
        custom_colors
      )(n_classes)
      
    } else {
      
      colors <- custom_colors[seq_len(n_classes)]
    }
  }
  
  # Reproduce the 100-color palette used by im.classify()
  num_colors <- 100
  
  color_palette <- grDevices::colorRampPalette(
    colors
  )(num_colors)
  
  # Match each class value to its position in the raster color scale
  if (n_classes == 1) {
    
    color_indices <- 1
    
  } else {
    
    color_indices <- round(
      seq(
        from = 1,
        to = num_colors,
        length.out = n_classes
      )
    )
  }
  
  class_colors <- color_palette[color_indices]
  
  # Explicitly associate each color with its class
  names(class_colors) <- as.character(class_values)
  
  # Apply class colors
  p <- p +
    ggplot2::scale_colour_manual(
      values = class_colors,
      breaks = as.character(class_values),
      limits = as.character(class_values),
      drop = FALSE
    )
  
  # Apply fill colors when needed
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
      ggplot2::coord_flip() +
      ggplot2::scale_x_discrete(
        limits = rev(levels(df$Class))
      )
  }
  
  return(p)
}

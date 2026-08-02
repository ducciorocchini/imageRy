#' Plot Value Distributions Across Raster Layers
#'
#' This function visualizes the distribution of pixel values across the layers
#' of a multi-layer raster image. Distributions can be represented using
#' boxplots, violin plots, or boxplots combined with half-eye density plots.
#'
#' Median labels, custom color palettes, quantile-based display limits,
#' legends, coordinate flipping, and a Friedman rank-sum test can optionally
#' be added.
#'
#' @param input_image A multi-layer `SpatRaster` object. Each raster layer is
#'   displayed as a separate group in the plot.
#'
#' @param density A logical value indicating whether to add a half-eye density
#'   distribution beside each boxplot (default: `TRUE`). This argument is
#'   ignored when `violin = TRUE`.
#'
#' @param median_labels A logical value indicating whether to display the median
#'   value for each raster layer (default: `FALSE`).
#'
#' @param median_position A single numeric value controlling the position of
#'   median labels along the layer axis (default: `-0.3`). Negative values move
#'   labels to the left of the corresponding layer, whereas positive values
#'   move them to the right.
#'
#' @param legend A logical value indicating whether to display the color and
#'   fill legends (default: `FALSE`).
#'
#' @param limits An optional numeric vector of length 2 defining the lower and
#'   upper quantile probabilities used to restrict the visible value range.
#'   Values must be between 0 and 1, and the first value must be smaller than
#'   the second (default: `NULL`).
#'
#' @param custom_colors An optional character vector containing valid color
#'   names or hexadecimal color codes. The supplied colors are interpolated to
#'   generate one color for each raster layer (default: `NULL`).
#'
#' @param flip A logical value indicating whether to flip the plot coordinates
#'   using `ggplot2::coord_flip()` (default: `FALSE`).
#'
#' @param violin A logical value indicating whether to use violin plots instead
#'   of boxplots (default: `FALSE`). When `violin = TRUE`, the `density`
#'   argument is ignored because violin plots already represent the value
#'   distribution.
#'
#' @param friedman_test A logical value indicating whether to perform a
#'   Friedman rank-sum test comparing raster layers (default: `FALSE`).
#'
#' @return A `ggplot` object representing the distribution of pixel values
#'   across raster layers.
#'
#' If `friedman_test = TRUE`, the complete result returned by
#' `stats::friedman.test()` is stored in the `"friedman_test"` attribute of the
#' returned plot.
#'
#' @details
#' Pixel values are extracted from all layers of `input_image` and converted to
#' long format for plotting. Each raster layer is represented as a separate
#' group.
#'
#' The graphical representation depends on the selected arguments:
#'
#' \itemize{
#'   \item If `violin = FALSE`, raster values are represented using boxplots.
#'   \item If `violin = TRUE`, boxplots are replaced by violin plots.
#'   \item If `density = TRUE` and `violin = FALSE`, a half-eye density
#'   distribution is added using `ggdist::stat_halfeye()`.
#'   \item If `median_labels = TRUE`, the median value of each layer is
#'   displayed beside the corresponding distribution.
#'   \item The position of median labels can be adjusted using
#'   `median_position`.
#'   \item If `custom_colors` is provided, the supplied colors are interpolated
#'   to generate one color for each raster layer.
#'   \item If `legend = FALSE`, both the color and fill legends are hidden.
#'   \item If `flip = TRUE`, the layer and value axes are exchanged.
#' }
#'
#' If `limits` is provided, the lower and upper values are calculated from the
#' selected quantiles of all non-missing raster values. The visible value range
#' is then restricted using `ggplot2::coord_cartesian()`.
#'
#' Because `coord_cartesian()` performs a visual zoom rather than removing
#' observations, values outside the displayed range remain part of the data.
#' They are therefore retained when calculating boxplots, violin plots,
#' half-eye density distributions, and median values.
#'
#' If `friedman_test = TRUE`, a Friedman rank-sum test is performed using raster
#' cells as blocks and raster layers as repeated measurements. Each row of the
#' input data represents a raster cell, and each column represents a raster
#' layer.
#'
#' Only raster cells containing non-missing values in every layer are included
#' in the Friedman test.
#'
#' The null hypothesis of the Friedman test is that all raster layers have the
#' same location distribution. A significant result indicates that at least
#' one raster layer differs from the others, but it does not identify which
#' layers differ.
#'
#' Corresponding raster cells must represent paired observations across raster
#' layers. The layers must therefore have matching spatial geometry and cell
#' alignment.
#'
#' The Friedman test does not account for spatial autocorrelation among
#' neighbouring raster cells. Spatial autocorrelation may inflate the test
#' statistic and produce overly small p-values, particularly when large numbers
#' of raster cells are included.
#'
#' Although the function accepts two or more raster layers, the Friedman test
#' is primarily intended for three or more repeated measurements. For exactly
#' two raster layers, a paired Wilcoxon signed-rank test is generally more
#' appropriate.
#'
#' @seealso
#' [im.barplot()],
#' [im.classify()],
#' [im.boxplot.classes()],
#' [stats::friedman.test()],
#' [ggdist::stat_halfeye()],
#' [ggplot2::geom_boxplot()],
#' [ggplot2::geom_violin()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ggplot2)
#' library(viridis)
#'
#' # Import a multi-layer raster
#' dolom <- im.import("sentinel.dolomites")
#'
#' names(dolom) <- c("B2", "B3", "B4", "B5")
#'
#' # Basic boxplots with half-eye density distributions
#' im.boxplot.layers(dolom)
#'
#' # Add median labels
#' im.boxplot.layers(
#'   dolom,
#'   density = TRUE,
#'   median_labels = TRUE
#' )
#'
#' # Adjust the position of median labels
#' im.boxplot.layers(
#'   dolom,
#'   median_labels = TRUE,
#'   median_position = -0.4
#' )
#'
#' # Restrict the visible range using pooled raster quantiles
#' im.boxplot.layers(
#'   dolom,
#'   limits = c(0.01, 0.99)
#' )
#'
#' # Use custom colors
#' im.boxplot.layers(
#'   dolom,
#'   density = TRUE,
#'   custom_colors = viridis::viridis(4, end = 0.5)
#' )
#'
#' # Display the legend
#' im.boxplot.layers(
#'   dolom,
#'   legend = TRUE
#' )
#'
#' # Flip the plot coordinates
#' im.boxplot.layers(
#'   dolom,
#'   median_labels = TRUE,
#'   flip = TRUE
#' )
#'
#' # Use violin plots instead of boxplots
#' im.boxplot.layers(
#'   dolom,
#'   violin = TRUE,
#'   median_labels = TRUE,
#'   median_position = 0.4,
#'   limits = c(0.01, 0.99),
#'   custom_colors = viridis::viridis(4, end = 0.5),
#'   flip = TRUE
#' )
#'
#' # Perform the Friedman rank-sum test
#' im.boxplot.layers(
#'   dolom,
#'   density = TRUE,
#'   friedman_test = TRUE
#' )
#'
#' # Store the plot and retrieve the complete test result
#' p <- im.boxplot.layers(
#'   dolom,
#'   friedman_test = TRUE
#' )
#'
#' attr(p, "friedman_test")
#' }
#'
#' @export
im.boxplot.layers <- function(input_image,
                               density = TRUE, # TRUE for adding a half-eye density plot
                               median_labels = FALSE, # TRUE for adding median labels
                               median_position = -0.3, # position of median labels along the layer axis
                               legend = FALSE, # TRUE for adding a legend
                               limits = NULL, # restrict the visible y-axis range to selected quantiles
                               custom_colors = NULL, # specify a color palette
                               flip = FALSE, # flip plot coordinates
                               violin = FALSE, # TRUE for using a violin plot instead of a boxplot
							   friedman_test = FALSE # TRUE for using the Friedman test
) { 
  
  # Check input image
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  if (terra::nlyr(input_image) < 2) {
    stop("input_image should have at least two layers.")
  }
  
  # Check density
  if (!is.logical(density) || length(density) != 1 || is.na(density)) {
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
  if (!is.logical(legend) || length(legend) != 1 || is.na(legend)) {
    stop("legend must be either TRUE or FALSE.")
  }
  
  # Check flip
  if (!is.logical(flip) || length(flip) != 1 || is.na(flip)) {
    stop("flip must be either TRUE or FALSE.")
  }
  
  # Check violin
  if (!is.logical(violin) || length(violin) != 1 || is.na(violin)) {
    stop("violin must be either TRUE or FALSE.")
  }
  
  # Warn if density is ignored
  if (isTRUE(violin) && isTRUE(density)) {
    warning("density is ignored when violin = TRUE.")
  }
  
  # Build the data frame
  df_wide <- terra::as.data.frame(input_image, na.rm = FALSE)
  
  df <- utils::stack(df_wide)
  names(df) <- c("value", "Layer")
  
  df <- df[!is.na(df$value), ]
  df$Layer <- factor(df$Layer, levels = names(input_image))
  
  # Basic plot
  p <- ggplot2::ggplot(
    data = df,
    mapping = ggplot2::aes(x = Layer, y = value, colour = Layer)
  ) +
    ggplot2::labs(y = "Value", x = "Layer")
  
  # Add either a boxplot or a violin plot
  if (isTRUE(violin)) {
    
    p <- p +
      ggplot2::geom_violin(
        ggplot2::aes(fill = Layer),
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
        ggplot2::aes(fill = Layer),
        adjust = 2,
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
          label = round(ggplot2::after_stat(y), 3)
        ),
        position = ggplot2::position_nudge(
          x = median_position
        )
      )
  }
  
  # Optional quantile limits
  if (!is.null(limits)) {
    
    if (!is.numeric(limits) || length(limits) != 2) {
      stop("limits must be a numeric vector of length 2.")
    }
    
    if (any(is.na(limits)) || any(limits < 0 | limits > 1)) {
      stop("limits must contain quantile probabilities between 0 and 1.")
    }
    
    if (limits[1] >= limits[2]) {
      stop("The first value of limits must be smaller than the second.")
    }
    
    p <- p +
      ggplot2::scale_y_continuous(
        limits = stats::quantile(
          df$value,
          probs = limits,
          na.rm = TRUE
        )
      )
  }
  
  # Optional custom colors
  if (!is.null(custom_colors)) {
    
    if (!is.character(custom_colors)) {
      stop("custom_colors must be a character vector of valid color names or hex codes.")
    }
    
    n_layers <- nlevels(df$Layer)
    pal <- grDevices::colorRampPalette(custom_colors)(n_layers)
    
    p <- p + ggplot2::scale_colour_manual(values = pal)
    
    if (isTRUE(density) || isTRUE(violin)) {
      p <- p + ggplot2::scale_fill_manual(values = pal)
    }
  }
  
  # Optional legend
  if (!isTRUE(legend)) {
    p <- p +
      ggplot2::guides(colour = "none", fill = "none")
  }
  
  # Optional coordinate flipping
  if (isTRUE(flip)) {
    p <- p + ggplot2::coord_flip()
  }

   # Optional Friedman test
  if (isTRUE(friedman_test)) {

    # Keep only raster cells with values in every layer
    df_friedman <- terra::as.data.frame(
      input_image,
      na.rm = FALSE
    )

    df_friedman <- df_friedman[
      stats::complete.cases(df_friedman),
      ,
      drop = FALSE
    ]

    if (nrow(df_friedman) == 0) {

      warning(
        "Friedman test could not be performed because no raster cells contain non-missing values in every layer."
      )

    } else {

      ft <- stats::friedman.test(
        as.matrix(df_friedman)
      )

      p_text <- if (ft$p.value < .Machine$double.eps) {
        paste0("p < ", format(.Machine$double.eps, scientific = TRUE))
      } else {
        paste0("p = ", format.pval(ft$p.value, digits = 3))
      }

      message(
        sprintf(
          "Friedman test: chi-squared = %.2f, df = %d, %s",
          unname(ft$statistic),
          unname(ft$parameter),
          p_text
        )
      )

      warning(
        paste(
          "The Friedman test assumes paired observations across raster layers",
          "but does not account for spatial autocorrelation.",
          "Spatial autocorrelation may inflate the test statistic and",
          "produce overly small p-values."
        )
      )

      attr(p, "friedman_test") <- ft
    }
  }
  	
  return(p)
}

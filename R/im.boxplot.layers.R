#' Plot Value Distributions Across Raster Layers
#'
#' This function generates boxplots summarizing the distribution of pixel
#' values across the layers of a multi-layer raster image.
#' Optional half-eye density distributions, median labels, custom color
#' palettes, quantile-based display limits, legends, and a Friedman rank-sum
#' test can be added.
#'
#' @param input_image A multi-layer `SpatRaster` object. Each raster layer is
#'   displayed as a separate group in the plot.
#' @param density A logical value indicating whether to add a half-eye density
#'   distribution beside each boxplot (default: TRUE).
#' @param median_labels A logical value indicating whether to display the median
#'   value for each raster layer (default: FALSE).
#' @param legend A logical value indicating whether to display the plot legend
#'   (default: FALSE).
#' @param limits An optional numeric vector of length 2 defining the lower and
#'   upper quantile probabilities used to restrict the visible y-axis range.
#'   Values must be between 0 and 1, with the first value smaller than the
#'   second (default: NULL).
#' @param custom_colors An optional character vector of valid color names or
#'   hexadecimal color codes used to construct the color palette for the raster
#'   layers (default: NULL).
#' @param friedman_test A logical value indicating whether to perform a Friedman
#'   rank-sum test comparing raster layers (default: FALSE).
#'
#' @return A `ggplot` object representing the distribution of pixel values
#'   across raster layers.
#'
#' If `friedman_test = TRUE`, the complete test result is also stored in the
#' `"friedman_test"` attribute of the returned plot.
#'
#' @details
#' The function extracts pixel values from all layers of `input_image` and
#' converts them to long format. Each raster layer is represented by a separate
#' boxplot.
#'
#' Additional options:
#' \itemize{
#'   \item If `density = TRUE`, a half-eye density distribution is added using
#'   `ggdist::stat_halfeye()`.
#'   \item If `median_labels = TRUE`, the median value of each layer is displayed
#'   beside the corresponding boxplot.
#'   \item If `limits` is provided, the visible y-axis range is restricted to the
#'   selected quantiles of the pooled raster values.
#'   \item If `custom_colors` is provided, the supplied colors are interpolated
#'   to generate one color for each raster layer.
#'   \item If `legend = FALSE`, both the color and fill legends are hidden.
#'   \item If `friedman_test = TRUE`, a Friedman rank-sum test is performed using
#'   raster cells as blocks and raster layers as repeated measurements.
#' }
#'
#' The `limits` argument changes only the visible y-axis range through
#' `ggplot2::coord_cartesian()`. Values outside the displayed range are retained
#' when calculating boxplots, density distributions, and medians.
#'
#' For the Friedman test, only raster cells containing non-missing values in
#' every layer are included. The null hypothesis is that the distributions of
#' the raster layers have the same location. A significant result indicates
#' that at least one layer differs from the others.
#'
#' Corresponding raster cells must represent paired observations across layers.
#' The Friedman test does not account for spatial autocorrelation among
#' neighbouring cells. With large rasters, small differences may therefore
#' produce very small p-values.
#'
#' Although the function accepts two or more raster layers, the Friedman test
#' is primarily intended for three or more repeated measurements. For exactly
#' two layers, a paired Wilcoxon signed-rank test is generally more appropriate.
#'
#' @seealso [im.barplot()], [im.classify()], [im.boxplot.classes()]
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
#' # Basic boxplot
#' im.boxplot.layers(dolom)
#'
#' # Add density distributions and median labels
#' im.boxplot.layers(
#'   dolom,
#'   density = TRUE,
#'   median_labels = TRUE
#' )
#'
#' # Restrict the visible range and use custom colors
#' im.boxplot.layers(
#'   dolom,
#'   density = TRUE,
#'   median_labels = TRUE,
#'   limits = c(0.01, 0.99),
#'   custom_colors = viridis::viridis(4, end = 0.5)
#' )
#'
#' # Display the legend
#' im.boxplot.layers(
#'   dolom,
#'   legend = TRUE
#' )
#'
#' # Perform the Friedman test
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
                              legend = FALSE, # TRUE for adding a legend
                              limits = NULL, # restrict the visible y-axis range to selected quantiles
                              custom_colors = NULL, # specify a color palette
							  friedman_test = FALSE) { # apply a Friedman test
  

  # Check input image
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  if (terra::nlyr(input_image) < 2) {
    stop("input_image should have at least two layers.")
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
    ggplot2::geom_boxplot(
      width = 0.30,
      outlier.shape = NA,
      outlier.color = NA
    ) +
    ggplot2::labs(y = "Value", x = "Layer")
  
  # Optional density layer
  if (isTRUE(density)) {
    p <- p +
      ggdist::stat_halfeye(
        ggplot2::aes(fill = Layer),
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

    if (limits[1] >= limits[2]) {
      stop("The first limit must be smaller than the second.")
    }

    y_limits <- stats::quantile(
      df$value,
      probs = limits,
      na.rm = TRUE,
      names = FALSE
    )

    p <- p +
      ggplot2::coord_cartesian(
        ylim = y_limits
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
    
    if (isTRUE(density)) {
      p <- p + ggplot2::scale_fill_manual(values = pal)
    }
  }

  # Optional legend
  if (!isTRUE(legend)) {
    p <- p +
      ggplot2::guides(colour = "none", fill = "none")
  }
  
  # Friedman test

  if (isTRUE(friedman_test)) {

    df_friedman <- terra::as.data.frame(input_image, na.rm = TRUE)
    df_friedman <- df_friedman[complete.cases(df_friedman), ]

    if (ncol(df_friedman) < 2) {
      warning("Friedman test requires at least two layers.")
    } else {

			ft <- stats::friedman.test(as.matrix(df_friedman))

			p_text <- if (ft$p.value == 0) {
			  "p < 2.2e-16"
			} else {
			  paste0("p = ", signif(ft$p.value, 3))
			}

			message(
			  sprintf(
			    "Friedman test: chi-squared = %.2f, df = %d, %s",
			    unname(ft$statistic),
			    unname(ft$parameter),
			    p_text
			  )
			)
      attr(p, "friedman_test") <- ft
    }
  }

  return(p)
}

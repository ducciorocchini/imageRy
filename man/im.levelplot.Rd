
#' Visualize Raster Layers Using Level Plots
#'
#' Visualizes single- and multi-layer SpatRaster objects using level plots,
#' with optional row- and column-wise marginal profiles.
#'
#' @param input_image A SpatRaster object containing the raster data.
#' @param layer Numeric index or name of the layer to display.
#'   If NULL, all layers are displayed (default: NULL).
#' @param margin Function used to calculate marginal profiles.
#'   Accepted values are "mean" (default), "median", or NULL
#'   to disable marginal profiles.
#' @param custom_colors Name of a viridis palette ("viridis", "magma",
#'   "plasma", "inferno", "cividis", "mako", "rocket", "turbo")
#'   or a character vector of custom colors (default: "viridis").
#' @param direction Direction of the viridis palette:
#'   1 (default) or -1 (reversed).
#' @param contour Logical. If TRUE, contour lines are added
#'   to the raster visualization (default: FALSE).
#' @param ncol Number of columns used to arrange multiple raster
#'   layers. If NULL, the layout is determined automatically.
#' @param main Optional title for the plot (default: NULL).
#' @param legend_title Optional title for the color legend
#'   (default: NULL).
#'
#' @return A trellis object for single-layer plots or multi-layer plots
#'   without marginal profiles. For multi-layer plots with marginal
#'   profiles, a gtable object is returned invisibly after plotting.
#'
#' @details
#' The function is based on rasterVis::levelplot() and supports
#' visualization of individual raster layers or multiple layers
#' arranged in a multi-panel layout.
#'
#' Marginal summaries, also referred to as marginal profiles,
#' describe variation in raster values along rows and columns.
#' They are calculated using the mean or median.
#'
#' By default, margin = "mean" displays marginal profiles.
#' Setting margin = "median" uses the median, whereas
#' margin = NULL disables marginal profiles.
#'
#' For multi-layer rasters, each layer is displayed in a separate
#' panel together with its corresponding marginal profiles.
#' A common color scale is applied across all layers when
#' marginal profiles are enabled, facilitating comparisons.
#'
#' The number of columns in the multi-panel layout can be
#' controlled using ncol.
#'
#' Marginal profiles are primarily intended for continuous
#' numerical raster data. For categorical rasters, numerical
#' class identifiers may represent labels rather than
#' quantitative measurements, making mean and median
#' summaries potentially inappropriate.
#'
#' Geographic rasters are labelled using longitude and latitude.
#' For other rasters, axis labels follow the default behavior
#' of rasterVis::levelplot().
#'
#' @seealso im.ridgeline, im.boxplot.layers, im.ggplot
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#'
#' # Single-layer raster with mean marginal profiles
#' im.levelplot(r)
#'
#' # Median marginal profiles
#' im.levelplot(r, margin = "median")
#'
#' # Without marginal profiles
#' im.levelplot(r, margin = NULL)
#'
#' # Custom palette
#' im.levelplot(r, custom_colors = "mako", direction = -1)
#'
#' # Multi-layer raster with marginal profiles
#' r_multi <- c(r, r * 2, r * 3)
#' names(r_multi) <- c("Layer1", "Layer2", "Layer3")
#'
#' im.levelplot(
#'   r_multi,
#'   margin = "mean",
#'   ncol = 2
#' )
#' }
#'
#' @export

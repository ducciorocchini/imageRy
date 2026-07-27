#' Create a Bivariate Raster Map
#'
#' This function generates a bivariate choropleth map from two raster layers
#' using the \pkg{biscale} classification framework. The two variables are
#' jointly classified into a two-dimensional color palette, allowing spatial
#' patterns of co-occurrence to be visualized.
#'
#' @param r1 A single-layer `SpatRaster` representing the first variable.
#' @param r2 A single-layer `SpatRaster` representing the second variable.
#' @param xlab A character string specifying the label of the x-axis in the
#'   bivariate legend.
#' @param ylab A character string specifying the label of the y-axis in the
#'   bivariate legend.
#' @param style A character string specifying the method used to calculate class
#'   breaks. Passed to `biscale::bi_class()`. Defaults to `"quantile"`.
#' @param dim An integer specifying the number of classes per variable.
#'   Defaults to `3`.
#' @param custom_colors Either the name of a built-in `biscale` palette or a
#'   character vector containing exactly `dim^2` colors defining a custom
#'   bivariate palette. Defaults to `"BlueOr"`.
#' @param add_legend A logical value indicating whether to add the bivariate
#'   legend to the map (default: TRUE).
#' @param legend_x Horizontal position of the legend in normalized plotting
#'   coordinates (default: 0.7).
#' @param legend_y Vertical position of the legend in normalized plotting
#'   coordinates (default: 0.65).
#' @param legend_width Width of the legend as a proportion of the plotting
#'   region (default: 0.3).
#' @param legend_height Height of the legend as a proportion of the plotting
#'   region (default: 0.3).
#' @param legend_size Numeric value controlling the overall size of the
#'   bivariate legend (default: 10).
#' @param legend_label_size Numeric value controlling the font size of the
#'   legend axis labels (default: 10).
#'
#' @return A `ggplot` object if `add_legend = FALSE`, otherwise a combined
#'   `cowplot` object containing the bivariate map and its legend.
#'
#' @details
#' The function first checks that the two raster layers share the same
#' coordinate reference system, extent, resolution, and dimensions.
#'
#' Pixel values are extracted from both rasters and jointly classified using
#' `biscale::bi_class()`. Each pixel is assigned to one of `dim × dim`
#' bivariate classes according to the selected classification style.
#'
#' The resulting classes are displayed using either:
#' \itemize{
#'   \item a built-in `biscale` palette specified by name, or
#'   \item a user-defined palette containing exactly `dim^2` colors.
#' }
#'
#' If `add_legend = TRUE`, a bivariate legend is created using
#' `biscale::bi_legend()` and inserted into the map using
#' `cowplot::draw_plot()`.
#'
#' This function is particularly useful for visualizing the spatial
#' relationship between two continuous raster variables, such as ecological,
#' climatic, or remotely sensed data.
#'
#' @seealso [im.scatter()], [im.boxplot.layers()], [im.classify()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Import two raster layers
#' r <- im.import("sentinel.dolomites")
#'
#' b2 <- r[[1]]
#' b8 <- r[[4]]
#'
#' # Basic bivariate map
#' im.bivariate(
#'   b2,
#'   b8,
#'   xlab = "Blue",
#'   ylab = "NIR"
#' )
#'
#' # Use a different classification style
#' im.bivariate(
#'   b2,
#'   b8,
#'   xlab = "Blue",
#'   ylab = "NIR",
#'   style = "equal"
#' )
#'
#' # Use four classes per variable
#' im.bivariate(
#'   b2,
#'   b8,
#'   xlab = "Blue",
#'   ylab = "NIR",
#'   dim = 4
#' )
#'
#' # Hide the legend
#' im.bivariate(
#'   b2,
#'   b8,
#'   xlab = "Blue",
#'   ylab = "NIR",
#'   add_legend = FALSE
#' )
#'
#' # Use a custom palette
#' mycols <- c(
#'   "#e8e8e8", "#ace4e4", "#5ac8c8",
#'   "#dfb0d6", "#a5add3", "#5698b9",
#'   "#be64ac", "#8c62aa", "#3b4994"
#' )
#'
#' im.bivariate(
#'   b2,
#'   b8,
#'   xlab = "Blue",
#'   ylab = "NIR",
#'   custom_colors = mycols
#' )
#' }
#'
#' @export
im.bivariate <- function(r1, r2, # SpatRasters of the two variables to plot
                         xlab, ylab, # x and y legend labels
                         style = "quantile", # a string identifying the style used to calculate breaks
                         dim = 3, # dimension of the palette
                         custom_colors = "BlueOr", # custom color palettes
                         add_legend = TRUE, # show the legend
                         legend_x = 0.7, legend_y = 0.65, # legend horizontal/vertical position
                         legend_width = 0.3, legend_height = 0.3, # space occupied by the legend in the plot
                         legend_size = 10, # size of the legend
                         legend_label_size = 10) { # fontsize of legend labels
  
  if (!inherits(r1, "SpatRaster") || !inherits(r2, "SpatRaster")) {
    stop("r1 and r2 must be SpatRaster objects.")
  }
  
  if (!is.character(xlab) || length(xlab) != 1) {
    stop("xlab must be a single character string.")
  }
  
  if (!is.character(ylab) || length(ylab) != 1) {
    stop("ylab must be a single character string.")
  }
  
  same_geom <- terra::compareGeom(
    r1, r2,
    crs = TRUE, ext = TRUE, rowcol = TRUE, res = TRUE,
    stopOnError = FALSE
  )
  
  if (!same_geom) {
    stop("r1 and r2 must have the same CRS, extent, resolution, and dimensions.")
  }
  
  # Handle palette
  if (is.character(custom_colors) && length(custom_colors) == 1) {
    pal_use <- custom_colors
  } else {
    if (length(custom_colors) != dim^2) {
      stop(paste0(
        "Custom palette must contain exactly ", dim^2,
        " colors when dim = ", dim, "."
      ))
    }
    
    rgb_mat <- grDevices::col2rgb(custom_colors)
    pal_use <- grDevices::rgb(
      rgb_mat[1, ], rgb_mat[2, ], rgb_mat[3, ],
      maxColorValue = 255
    )
    
    names(pal_use) <- paste(
      rep(1:dim, times = dim),
      rep(1:dim, each = dim),
      sep = "-"
    )
  }
  
  rasters <- c(r1, r2)
  names(rasters) <- c(xlab, ylab)
  
  rasters_df <- as.data.frame(rasters, xy = TRUE, na.rm = TRUE)
  names(rasters_df)[3:4] <- c("var_x", "var_y")
  
  data <- biscale::bi_class(
    rasters_df,
    x = var_x,
    y = var_y,
    style = style,
    dim = dim
  )
  
  bivmap <- ggplot2::ggplot() +
    ggplot2::theme_void() +
    ggplot2::geom_raster(
      data = data,
      mapping = ggplot2::aes(x = x, y = y, fill = bi_class),
      show.legend = FALSE
    ) +
    biscale::bi_scale_fill(
      pal = pal_use,
      dim = dim,
      flip_axes = FALSE,
      rotate_pal = FALSE
    )
  
  if (!add_legend) {
    return(bivmap)
  }
  
  legend <- biscale::bi_legend(
    pal = pal_use,
    flip_axes = FALSE,
    rotate_pal = FALSE,
    dim = dim,
    xlab = xlab,
    ylab = ylab,
    size = legend_size
  ) +
    ggplot2::theme(
      axis.title.x = ggplot2::element_text(size = legend_label_size),
      axis.title.y = ggplot2::element_text(size = legend_label_size)
    )
  
  finalPlot <- cowplot::ggdraw() +
    cowplot::draw_plot(bivmap, 0, 0, 1, 1) +
    cowplot::draw_plot(legend, legend_x, legend_y, legend_width, legend_height)
  
  return(finalPlot)
}

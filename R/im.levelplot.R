#' Visualize Raster Layers Using Level Plots
#'
#' This function visualizes single- or multi-layer raster images using
#' level plots. It supports customizable color palettes, contour overlays,
#' row- and column-wise marginal summaries, flexible multi-panel layouts,
#' and coordinate labels based on the raster coordinate reference system.
#'
#' @param input_image A `SpatRaster` object representing the input raster image.
#' @param layer A numeric index or character string specifying the layer to
#'   display. If `NULL`, all raster layers are displayed (default: NULL).
#' @param margin An optional character value specifying the function used to
#'   summarize raster values along rows and columns for each displayed layer.
#'   Accepted values are `"mean"` (default), `"median"`, and `NULL`
#'   (no marginal summaries).
#' @param custom_colors Either the name of a viridis palette (`"viridis"`,
#'   `"magma"`, `"plasma"`, `"inferno"`, `"cividis"`, `"mako"`, `"rocket"`,
#'   `"turbo"`) or a character vector of colors defining a custom palette
#'   (default: `"viridis"`).
#' @param direction An integer specifying the direction of the viridis palette.
#'   Accepted values are `1` (default) and `-1`. This argument applies
#'   when a predefined viridis palette is selected.
#' @param contour A logical value indicating whether contour lines should be
#'   overlaid on the raster (default: FALSE).
#' @param ncol An optional positive integer specifying the number of columns
#'   used when displaying multiple raster layers (default: NULL).
#'   When marginal summaries are enabled, `NULL` automatically determines
#'   the number of columns based on the number of raster layers.
#' @param main An optional character string specifying the plot title
#'   (default: NULL). For multi-layer displays with marginal summaries,
#'   this title is placed above the combined multi-panel plot.
#' @param legend_title An optional character string specifying the color
#'   legend title (default: NULL).
#'
#' @return A `trellis` object produced by `rasterVis::levelplot()` when
#'   displaying a single raster layer or when `margin = NULL`.
#'   For multi-layer rasters with marginal summaries enabled, a `gtable`
#'   object produced by `gridExtra::arrangeGrob()` is returned invisibly
#'   after displaying the combined multi-panel plot.
#'
#' @details
#' The function creates level plots for raster data using
#' `rasterVis::levelplot()`. A single raster layer or all layers of a
#' multi-layer raster can be displayed.
#'
#' Marginal summaries, also referred to as marginal profiles, describe
#' variation in raster values along rows and columns. They are calculated
#' using either the mean or median of the raster values.
#'
#' By default, `margin = "mean"` displays row- and column-wise mean
#' profiles. Setting `margin = "median"` uses the median instead,
#' whereas `margin = NULL` disables marginal summaries.
#'
#' For single-layer rasters, the level plot and its marginal profiles
#' are displayed together in a single graphical representation.
#'
#' For multi-layer rasters with marginal summaries enabled, each layer
#' is displayed in a separate panel together with its corresponding
#' row- and column-wise marginal profiles. The individual plots are
#' arranged in a grid using `gridExtra::arrangeGrob()`.
#'
#' A common color scale is calculated across all raster layers in
#' multi-panel displays with marginal summaries, allowing direct
#' comparison of raster values among layers.
#'
#' When `margin = NULL`, multi-layer rasters are displayed using
#' the standard multi-panel behavior of `rasterVis::levelplot()`.
#'
#' Marginal summaries based on the mean or median are primarily
#' intended for continuous numerical raster data. For categorical
#' rasters, numerical class identifiers may represent labels rather
#' than quantitative measurements, making such summaries difficult
#' to interpret.
#'
#' Additional options:
#' \itemize{
#'   \item If `margin = "mean"` or `margin = "median"`, marginal profiles
#'   are displayed for each raster layer.
#'   \item If `contour = TRUE`, contour lines are superimposed on the raster.
#'   \item If `ncol` is specified, multiple raster layers are arranged
#'   using the requested number of columns.
#'   \item If `custom_colors` is a viridis palette name, a 100-color
#'   palette is automatically generated.
#'   \item If `custom_colors` is a vector of colors, the supplied colors
#'   are used directly to define the palette.
#'   \item If `direction = -1`, the selected viridis palette is reversed.
#' }
#'
#' Geographic rasters are explicitly labelled with longitude and
#' latitude. For projected rasters and rasters without a defined
#' coordinate reference system, axis labels follow the default
#' behavior of `rasterVis::levelplot()`.
#'
#' The function is particularly useful as an initial exploratory step
#' before applying distribution-based visualization methods such as
#' [im.ridgeline()] or [im.boxplot.layers()].
#'
#' @seealso [im.ridgeline()], [im.boxplot.layers()], [im.ggplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load a raster image
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#'
#' # Display a single layer with mean marginal profiles
#' im.levelplot(r)
#'
#' # Display median marginal profiles
#' im.levelplot(
#'   r,
#'   margin = "median"
#' )
#'
#' # Display a raster without marginal summaries
#' im.levelplot(
#'   r,
#'   margin = NULL
#' )
#'
#' # Use a reversed viridis palette and add contour lines
#' im.levelplot(
#'   r,
#'   custom_colors = "mako",
#'   direction = -1,
#'   contour = TRUE
#' )
#'
#' # Use a custom color vector
#' im.levelplot(
#'   r,
#'   custom_colors = c("navy", "white", "orange")
#' )
#'
#' # Create a multi-layer raster
#' r_multi <- c(r, r * 2, r * 3)
#' names(r_multi) <- c("Layer1", "Layer2", "Layer3")
#'
#' # Display multiple layers with individual mean marginal profiles
#' im.levelplot(
#'   r_multi,
#'   margin = "mean",
#'   ncol = 2
#' )
#'
#' # Display multiple layers with median marginal profiles
#' im.levelplot(
#'   r_multi,
#'   margin = "median",
#'   custom_colors = "plasma",
#'   ncol = 2,
#'   main = "Multi-layer raster comparison"
#' )
#'
#' # Display multiple layers without marginal summaries
#' im.levelplot(
#'   r_multi,
#'   margin = NULL,
#'   ncol = 2
#' )
#' }
#'
#' @export
im.levelplot <- function(input_image, # a SpatRaster object
                         layer = NULL, # Layer to display
                         margin = "mean", # Function for the margin plots (either "mean" or "median) (only works for single layer display)
                         custom_colors = "viridis", # Custom color palette
                         direction = 1, # Direction of the custom color palette (if it's a viridis palette)
                         contour = FALSE, # Contour lines
                         ncol = NULL, # Number of columns (if multiple layers are displayed)
                         main = NULL, # Title
                         legend_title = NULL) { # Legend title
  
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image must be a SpatRaster object.")
  }
  
  # Select layer if requested
  if (!is.null(layer)) {
    
    if (is.numeric(layer)) {
      if (length(layer) != 1 || layer < 1 || layer > terra::nlyr(input_image)) {
        stop("layer must be a valid layer index.")
      }
      input_image <- input_image[[layer]]
      
    } else if (is.character(layer)) {
      if (length(layer) != 1 || !layer %in% names(input_image)) {
        stop("layer must be a valid layer name.")
      }
      input_image <- input_image[[layer]]
      
    } else {
      stop("layer must be NULL, a numeric index, or a layer name.")
    }
  }
  
  # Check margin
  if (!is.null(margin) && !margin %in% c("mean", "median")) {
    stop("margin must be NULL, 'mean', or 'median'.")
  }
  
  # Check direction
  if (!direction %in% c(1, -1)) {
    stop("direction must be either 1 or -1.")
  }
  
  # Check contour
  if (!is.logical(contour) || length(contour) != 1) {
    stop("contour must be either TRUE or FALSE.")
  }
  
  # Handle colours
  viridis_opts <- c(
    "viridis", "magma", "plasma", "inferno",
    "cividis", "mako", "rocket", "turbo"
  )
  
  if (is.character(custom_colors) && length(custom_colors) == 1) {
    
    if (!custom_colors %in% viridis_opts) {
      stop(
        "If custom_colors is a single string, it must be one of: ",
        paste(viridis_opts, collapse = ", "),
        "."
      )
    }
    
    pal <- viridisLite::viridis(
      100,
      option = custom_colors,
      direction = direction
    )
    
  } else if (is.character(custom_colors) && length(custom_colors) >= 2) {
    
    pal <- custom_colors
    
  } else {
    stop("custom_colors must be a palette name or a character vector of colors.")
  }
  
  # rasterVis colour theme
  plt_theme <- rasterVis::rasterTheme(region = pal)
  
  # Margin settings
  margin_arg <- FALSE
  
  if (!is.null(margin)) {
    
    margin_fun <- switch(
      margin,
      mean = mean,
      median = stats::median
    )
    
    margin_arg <- list(
      draw = TRUE,
      FUN = margin_fun,
      axis = TRUE
    )
  }
  
  # Layout for multi-layer images
  layout_arg <- NULL
  
  if (terra::nlyr(input_image) > 1 && !is.null(ncol)) {
    nrow <- ceiling(terra::nlyr(input_image) / ncol)
    layout_arg <- c(ncol, nrow)
  }
  
  # Legend settings
  colorkey_arg <- TRUE
  
  if (!is.null(legend_title)) {
    colorkey_arg <- list(
      space = "right",
      title = legend_title
    )
  }
  
  # Handle axis labels for georeferenced and non-georeferenced images
  is_lonlat <- isTRUE(terra::is.lonlat(input_image, warn = FALSE))
  
  xlab <- if (is_lonlat) "Longitude" else NULL
  ylab <- if (is_lonlat) "Latitude" else NULL
  
  # Build plot
  
  n_layers <- terra::nlyr(input_image)
  
  # Single layer or multiple layers without margins
  if (n_layers == 1 || is.null(margin)) {
    
    return(
      rasterVis::levelplot(
        input_image,
        margin = margin_arg,
        contour = contour,
        layout = layout_arg,
        par.settings = plt_theme,
        main = main,
        colorkey = colorkey_arg,
        xlab = xlab,
        ylab = ylab
      )
    )
  }
  
  # Multiple layers with margins
  
  # Set number of columns
  if (is.null(ncol)) {
    ncol <- ceiling(sqrt(n_layers))
  }
  
  if (!is.numeric(ncol) || length(ncol) != 1 ||
      is.na(ncol) || !is.finite(ncol) ||
      ncol < 1 || ncol != floor(ncol)) {
    stop("ncol must be a positive integer.")
  }
  
  # Calculate a common color scale across all layers
  stats <- terra::global(
    input_image,
    fun = c("min", "max"),
    na.rm = TRUE
  )
  
  zvals <- unlist(stats, use.names = FALSE)
  zvals <- zvals[is.finite(zvals)]
  
  common_at <- NULL
  
  if (length(zvals) > 0) {
    limits <- range(zvals)
    pad <- max(1, abs(limits), diff(limits)) * 1e-8
    
    common_at <- seq(
      limits[1] - pad,
      limits[2] + pad,
      length.out = 101
    )
  }
  
  # Generate a separate levelplot for each layer
  plots <- lapply(seq_len(n_layers), function(i) {
    
    rasterVis::levelplot(
      input_image[[i]],
      margin = margin_arg,
      contour = contour,
      par.settings = plt_theme,
      colorkey = colorkey_arg,
      at = common_at,
      main = names(input_image)[i],
      xlab = xlab,
      ylab = ylab
    )
  })
  
  # Arrange all plots in a grid
  combined_plot <- gridExtra::arrangeGrob(
    grobs = plots,
    ncol = ncol,
    top = main
  )
  
  # Display combined plot
  grid::grid.newpage()
  grid::grid.draw(combined_plot)
  
  invisible(combined_plot)
}

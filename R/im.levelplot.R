#' Visualize Raster Layers Using Level Plots
#'
#' This function visualizes single- or multi-layer raster images using level plots.
#' It supports customizable color palettes, contour overlays, optional marginal
#' summaries for single-layer rasters, flexible multi-panel layouts, and
#' automatic axis labeling based on the raster coordinate reference system.
#'
#' @param input_image A `SpatRaster` object representing the input raster image.
#' @param layer A numeric index or character string specifying the layer to
#' display. If `NULL`, all raster layers are displayed (default: NULL).
#' @param margin An optional character value specifying the function used to
#' summarize rows and columns for single-layer rasters. Accepted values are
#' `"mean"` and `"median"` (default: NULL).
#' @param custom_colors Either the name of a viridis palette (`"viridis"`,
#' `"magma"`, `"plasma"`, `"inferno"`, `"cividis"`, `"mako"`, `"rocket"`,
#' `"turbo"`) or a character vector of colors used to build a custom palette
#' (default: `"viridis"`).
#' @param direction An integer specifying the direction of the viridis palette.
#' Accepted values are `1` (default) and `-1`.
#' @param contour A logical value indicating whether contour lines should be
#' overlaid on the raster (default: FALSE).
#' @param ncol An optional positive integer specifying the number of columns
#' used when displaying multiple raster layers (default: NULL).
#' @param main An optional character string specifying the plot title
#' (default: NULL).
#' @param legend_title An optional character string specifying the legend title
#' (default: NULL).
#'
#' @return
#' A `trellis` object produced by `rasterVis::levelplot()`.
#'
#' @details
#' The function creates level plots for raster data using
#' `rasterVis::levelplot()`. A single raster layer or all layers of a
#' multi-layer raster can be displayed.
#'
#' For single-layer rasters, optional marginal summaries can be added along the
#' rows and columns using either the mean or the median of raster values.
#'
#' Additional options:
#' \itemize{
#'   \item If `margin = "mean"` or `margin = "median"`, marginal profiles are
#'   displayed for single-layer rasters.
#'   \item If `contour = TRUE`, contour lines are superimposed on the raster.
#'   \item If `ncol` is specified, multiple raster layers are arranged using
#'   the requested number of columns.
#'   \item If `custom_colors` is a viridis palette name, a 100-color viridis
#'   palette is automatically generated.
#'   \item If `custom_colors` is a vector of colors, a continuous palette is
#'   interpolated from the supplied colors.
#' }
#'
#' Axis labels are automatically adapted to the raster coordinate reference
#' system. Geographic rasters are labelled as longitude and latitude,
#' projected rasters as easting and northing, whereas rasters without a
#' coordinate reference system use generic X and Y coordinates.
#'
#' This function provides an intuitive visualization of raster data and is
#' particularly useful as a first exploratory step before applying
#' distribution-based analyses such as [im.ridgeline()] or
#' [im.boxplot.layers()].
#'
#' @seealso [im.ridgeline()], [im.boxplot.layers()], [im.ggplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load a raster
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#'
#' # Display a single layer
#' im.levelplot(r)
#'
#' # Add median marginal profiles
#' im.levelplot(
#'   r,
#'   margin = "median"
#' )
#'
#' # Reverse a viridis palette and add contours
#' im.levelplot(
#'   r,
#'   custom_colors = "mako",
#'   direction = -1,
#'   contour = TRUE
#' )
#'
#' # Display all layers in two columns
#' im.levelplot(
#'   r,
#'   ncol = 2
#' )
#' }
#'
#' @export
im.levelplot <- function(
    input_image,                   # a SpatRaster object
    layer = NULL,                  # layer to display
    margin = NULL,                 # "mean" or "median"
    custom_colors = "viridis",     # viridis palette name or vector of colors
    direction = 1,                 # direction of viridis palette
    contour = FALSE,               # add contour lines
    ncol = NULL,                   # number of columns for multi-layer display
    main = NULL,                   # plot title
    legend_title = NULL            # legend title
) {
  
  # Check input image
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image must be a SpatRaster object.")
  }
  
  # Select layer if requested
  if (!is.null(layer)) {
    
    if (is.numeric(layer)) {
      
      if (length(layer) != 1 ||
          is.na(layer) ||
          layer < 1 ||
          layer > terra::nlyr(input_image)) {
        stop("layer must be a valid layer index.")
      }
      
      input_image <- input_image[[layer]]
      
    } else if (is.character(layer)) {
      
      if (length(layer) != 1 ||
          is.na(layer) ||
          !layer %in% names(input_image)) {
        stop("layer must be a valid layer name.")
      }
      
      input_image <- input_image[[layer]]
      
    } else {
      stop("layer must be NULL, a numeric index, or a layer name.")
    }
  }
  
  # Check margin
  if (!is.null(margin)) {
    
    if (!is.character(margin) ||
        length(margin) != 1 ||
        is.na(margin) ||
        !margin %in% c("mean", "median")) {
      stop("margin must be NULL, 'mean', or 'median'.")
    }
  }
  
  # Check direction
  if (!is.numeric(direction) ||
      length(direction) != 1 ||
      is.na(direction) ||
      !direction %in% c(1, -1)) {
    stop("direction must be either 1 or -1.")
  }
  
  # Check contour
  if (!is.logical(contour) ||
      length(contour) != 1 ||
      is.na(contour)) {
    stop("contour must be either TRUE or FALSE.")
  }
  
  # Check ncol
  if (!is.null(ncol)) {
    
    if (!is.numeric(ncol) ||
        length(ncol) != 1 ||
        is.na(ncol) ||
        ncol < 1 ||
        ncol %% 1 != 0) {
      stop("ncol must be NULL or a positive integer.")
    }
  }
  
  # Ignore margin for multi-layer images
  if (terra::nlyr(input_image) > 1 && !is.null(margin)) {
    warning("margin is ignored for multi-layer images.")
    margin <- NULL
  }
  
  # Available viridis palettes
  viridis_opts <- c(
    "viridis",
    "magma",
    "plasma",
    "inferno",
    "cividis",
    "mako",
    "rocket",
    "turbo"
  )
  
  # Build color palette
  if (is.character(custom_colors) &&
      length(custom_colors) == 1) {
    
    if (!custom_colors %in% viridis_opts) {
      stop(
        paste0(
          "If custom_colors is a single string, it must be one of: ",
          paste(viridis_opts, collapse = ", "),
          "."
        )
      )
    }
    
    pal <- viridisLite::viridis(
      n = 100,
      option = custom_colors,
      direction = direction
    )
    
  } else if (is.character(custom_colors) &&
             length(custom_colors) >= 2) {
    
    pal <- grDevices::colorRampPalette(
      custom_colors
    )(100)
    
  } else {
    stop(
      paste(
        "custom_colors must be either a valid viridis palette name",
        "or a character vector containing at least two colors."
      )
    )
  }
  
  # rasterVis color theme
  plt_theme <- rasterVis::rasterTheme(
    region = pal
  )
  
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
  
  if (terra::nlyr(input_image) > 1 &&
      !is.null(ncol)) {
    
    nrow <- ceiling(
      terra::nlyr(input_image) / ncol
    )
    
    layout_arg <- c(
      ncol,
      nrow
    )
  }
  
  # Legend settings
  colorkey_arg <- TRUE
  
  if (!is.null(legend_title)) {
    
    if (!is.character(legend_title) ||
        length(legend_title) != 1 ||
        is.na(legend_title)) {
      stop("legend_title must be NULL or a single character value.")
    }
    
    colorkey_arg <- list(
      space = "right",
      title = legend_title
    )
  }
  
  # Determine axis labels while handling missing CRS
  raster_crs <- terra::crs(
    input_image,
    proj = TRUE
  )
  
  if (is.na(raster_crs) ||
      !nzchar(raster_crs)) {
  
    xlab_arg <- "X"
    ylab_arg <- "Y"
  
  } else if (isTRUE(
    terra::is.lonlat(
      input_image,
      warn = FALSE
    )
  )) {
  
    xlab_arg <- "Longitude"
    ylab_arg <- "Latitude"
  
  } else {
  
    xlab_arg <- "Easting"
    ylab_arg <- "Northing"
  }
  
  # Build plot
  rasterVis::levelplot(
    input_image,
    margin = margin_arg,
    contour = contour,
    layout = layout_arg,
    par.settings = plt_theme,
    main = main,
    colorkey = colorkey_arg,
    xlab = xlab_arg,
    ylab = ylab_arg
  )
}

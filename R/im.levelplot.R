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

im.levelplot <- function(input_image, # a SpatRaster object
                         layer = NULL, # Layer to display
                         margin = NULL, # Function for the margin plots (either "mean" or "median) (only works for single layer display)
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
  
  # Ignore margin for multi-layer images
  if (terra::nlyr(input_image) > 1 && !is.null(margin)) {
    warning("margin is ignored for multi-layer images.")
    margin <- NULL
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
  
  # Build plot
  rasterVis::levelplot(
    input_image,
    margin = margin_arg,
    contour = contour,
    layout = layout_arg,
    par.settings = plt_theme,
    main = main,
    colorkey = colorkey_arg
  )
}

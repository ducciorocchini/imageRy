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

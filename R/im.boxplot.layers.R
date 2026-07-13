im.boxplot.layers <- function(input_image,
                              density = TRUE, # TRUE for adding a half-eye density plot
                              median_labels = FALSE, # TRUE for adding median labels
                              legend = FALSE, # TRUE for adding a legend
                              limits = NULL, # restrict the visible y-axis range to selected quantiles
                              custom_colors = NULL) { # specify a color palette
  
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
    
    p <- p +
      ggplot2::scale_y_continuous(
        limits = stats::quantile(df$value, probs = limits, na.rm = TRUE)
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
  
  return(p)
}

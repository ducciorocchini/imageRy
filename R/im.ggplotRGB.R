im.ggplotRGB <- function(input_image, r = 1, g = 2, b = 3,
                         stretch = "lin",
                         quantiles = c(0.02, 0.98),
                         title = "",
                         downsample = 1) {
  
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  if (downsample == 1) {
    rgb_small <- input_image
  } else {
    rgb_small <- terra::aggregate(input_image, fact = downsample)
  }
  
  rgb_df <- terra::as.data.frame(rgb_small, xy = TRUE, na.rm = TRUE)
  band_names <- names(rgb_df)[-(1:2)]
  
  red   <- rgb_df[[band_names[r]]]
  green <- rgb_df[[band_names[g]]]
  blue  <- rgb_df[[band_names[b]]]
  
  scale01 <- function(x, probs = c(0.02, 0.98)) {
    q <- stats::quantile(x, probs = probs, na.rm = TRUE)
    x <- (x - q[1]) / (q[2] - q[1])
    pmin(pmax(x, 0), 1)
  }
  
  if (stretch == "lin") {
    red   <- scale01(red, quantiles)
    green <- scale01(green, quantiles)
    blue  <- scale01(blue, quantiles)
  } else {
    maxval <- max(c(red, green, blue), na.rm = TRUE)
    red   <- red / maxval
    green <- green / maxval
    blue  <- blue / maxval
  }
  
  rgb_df$rgb_col <- grDevices::rgb(red, green, blue)
  
  ggplot2::ggplot(rgb_df) +
    ggplot2::geom_raster(
      ggplot2::aes(x = x, y = y, fill = rgb_col)
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_equal() +
    ggplot2::labs(title = title) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
      axis.text = ggplot2::element_text(size = 8),
      panel.grid = ggplot2::element_blank()
    )
}

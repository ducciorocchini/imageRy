im.pairs <- function(input_image, # original multi-layer SpatRaster
                     color = "black", # color for density and scatterplots
                     bivariate_color = "BlueOr", # colors for the bivariate maps
                     dim = 2, # dimension of the bivariate palette
                     sample_pixels = NULL, # optional number of pixels to sample for scatterplots/densities
                     seed = 42, # seed for reproducible sampling
                     map_factor = 1, # aggregation factor for bivariate maps
                     legend_x = 0.72, legend_y = 0.72,
                     legend_width = 0.32, legend_height = 0.32,
                     legend_size = 10,
                     legend_label_size = 6) {
  
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image must be a SpatRaster object.")
  }
  
  if (terra::nlyr(input_image) < 2) {
    stop("input_image must contain at least two layers.")
  }
  
  if (!is.null(sample_pixels)) {
    if (!is.numeric(sample_pixels) || length(sample_pixels) != 1 || sample_pixels <= 0) {
      stop("sample_pixels must be a single positive number.")
    }
  }
  
  if (!is.numeric(map_factor) || length(map_factor) != 1 || map_factor < 1) {
    stop("map_factor must be a single number >= 1.")
  }
  
  # Extract values
  X <- terra::values(input_image)
  
  dat <- as.data.frame(X) |>
    tidyr::drop_na()
  
  # Optional sampling for diagonal/lower panels
  if (!is.null(sample_pixels) && nrow(dat) > sample_pixels) {
    set.seed(seed)
    idx <- sample.int(nrow(dat), sample_pixels)
    dat <- dat[idx, , drop = FALSE]
  }
  
  # Panel function
  make_panel <- function(i, j) {
    
    xvar <- names(input_image)[j]
    yvar <- names(input_image)[i]
    
    # Diagonal: density plots
    if (i == j) {
      
      ggplot2::ggplot(
        dat,
        ggplot2::aes(x = .data[[xvar]])
      ) +
        ggplot2::geom_density(
          colour = color,
          fill = color,
          alpha = 0.5,
          linewidth = 0.8
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          legend.position = "none",
          axis.title = ggplot2::element_blank()
        )
      
    } else if (i > j) {
      
      # Lower triangle: scatterplots with R2 and p-value
      model <- stats::lm(dat[[yvar]] ~ dat[[xvar]])
      smry <- summary(model)
      
      r2 <- smry$r.squared
      pval <- coef(smry)[2, 4]
      
      label_txt <- paste0(
        "R² = ", round(r2, 3),
        "\nP = ", format.pval(pval, digits = 3, eps = 0.001)
      )
      
      ggplot2::ggplot(
        dat,
        ggplot2::aes(
          x = .data[[xvar]],
          y = .data[[yvar]]
        )
      ) +
        ggplot2::geom_point(
          colour = color,
          alpha = 0.35,
          size = 0.6
        ) +
        ggplot2::annotate(
          "text",
          x = Inf, y = Inf,
          label = label_txt,
          hjust = 1.1, vjust = 1.3,
          size = 3.5,
          colour = "black"
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          legend.position = "none",
          axis.title = ggplot2::element_blank()
        )
      
    } else {
      
      # Optional aggregation for faster bivariate maps
      r1_use <- input_image[[xvar]]
      r2_use <- input_image[[yvar]]
      
      if (map_factor > 1) {
        r1_use <- terra::aggregate(r1_use, fact = map_factor, fun = mean, na.rm = TRUE)
        r2_use <- terra::aggregate(r2_use, fact = map_factor, fun = mean, na.rm = TRUE)
      }
      
      # Upper triangle: bivariate maps
      im.bivariate(
        r1 = r1_use,
        r2 = r2_use,
        xlab = xvar,
        ylab = yvar,
        custom_colors = bivariate_color,
        dim = dim,
        legend_x = legend_x,
        legend_y = legend_y,
        legend_width = legend_width,
        legend_height = legend_height,
        legend_size = legend_size,
        legend_label_size = legend_label_size
      )
    }
  }
  
  # Build matrix
  plot_list <- tidyr::expand_grid(
    i = seq_along(names(input_image)),
    j = seq_along(names(input_image))
  ) |>
    dplyr::mutate(plot = purrr::map2(i, j, make_panel)) |>
    dplyr::pull(plot)
  
  # Combine panels
  patchwork::wrap_plots(plot_list, ncol = length(names(input_image)))
}

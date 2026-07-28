#' Pairwise Visualization of Multi-Layer Raster Data
#'
#' This function creates a matrix of plots for exploring pairwise relationships
#' among the layers of a multi-layer raster image. Density plots are displayed
#' along the diagonal, scatterplots with linear regression statistics in the
#' lower triangle, and bivariate maps in the upper triangle.
#'
#' @param input_image A multi-layer `SpatRaster` object containing at least two
#'   raster layers.
#' @param color A character value specifying the color used for density plots
#'   and scatterplot points (default: `"black"`).
#' @param bivariate_color A character value specifying the palette used for the
#'   bivariate maps (default: `"BlueOr"`). This argument is passed to
#'   [im.bivariate()].
#' @param dim A numeric value specifying the number of classes per variable in
#'   the bivariate color palette (default: `2`).
#' @param sample_pixels An optional positive integer specifying the number of
#'   complete raster cells randomly sampled for density plots, scatterplots,
#'   and regression analyses. If `NULL`, all complete raster cells are used
#'   (default: `NULL`).
#' @param seed A numeric value used as the random seed for reproducible
#'   sampling (default: `42`).
#' @param map_factor A numeric value greater than or equal to `1` specifying
#'   the aggregation factor applied to raster layers before creating the
#'   bivariate maps. Values greater than `1` reduce computation time for
#'   large rasters (default: `1`).
#' @param legend_x A numeric value specifying the horizontal position of the
#'   bivariate legend (default: `0.72`).
#' @param legend_y A numeric value specifying the vertical position of the
#'   bivariate legend (default: `0.72`).
#' @param legend_width A numeric value specifying the relative width of the
#'   bivariate legend (default: `0.32`).
#' @param legend_height A numeric value specifying the relative height of the
#'   bivariate legend (default: `0.32`).
#' @param legend_size A numeric value specifying the size of the bivariate
#'   legend (default: `10`).
#' @param legend_label_size A numeric value specifying the text size of the
#'   legend labels (default: `6`).
#'
#' @return A `patchwork` object containing a matrix of density plots,
#'   scatterplots, and bivariate maps.
#'
#' @details
#' This function provides an integrated graphical summary of pairwise
#' relationships among all layers of a multi-layer raster.
#'
#' The resulting matrix contains:
#' \itemize{
#'   \item Density plots along the diagonal showing the distribution of values
#'   within each raster layer.
#'   \item Scatterplots in the lower triangle showing pairwise relationships
#'   between raster layers.
#'   \item Bivariate maps in the upper triangle showing the spatial
#'   correspondence between each pair of raster layers.
#' }
#'
#' For each scatterplot, a simple linear regression is fitted and the
#' coefficient of determination (R²) together with the p-value of the slope
#' are displayed in the corresponding panel.
#'
#' Raster cells containing missing values in one or more layers are removed
#' before generating the plots and statistical summaries.
#'
#' If `sample_pixels` is specified, only a random subset of complete raster
#' cells is used for density plots, scatterplots, and regression analyses.
#' Sampling does not affect the bivariate maps.
#'
#' If `map_factor` is greater than `1`, raster layers used in the bivariate
#' maps are aggregated using the mean before visualization. This substantially
#' reduces computation time for large rasters but also decreases spatial
#' resolution.
#'
#' The regression statistics shown in the scatterplots assume independent
#' observations. Because raster cells are often spatially autocorrelated,
#' p-values should be interpreted with caution.
#'
#' @seealso [im.bivariate()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load an example multi-layer raster
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Pairwise visualization
#' im.pairs(r)
#'
#' # Use a random sample of pixels
#' im.pairs(
#'   r,
#'   sample_pixels = 1000,
#'   seed = 42
#' )
#'
#' # Aggregate bivariate maps for faster plotting
#' im.pairs(
#'   r,
#'   color = "darkblue",
#'   sample_pixels = 1000,
#'   map_factor = 2
#' )
#' }
#'
#' @export
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

#' Scatterplot with a LOESS Smooth for Two Raster Layers
#'
#' This function draws a scatterplot of paired pixel values from two
#' single-layer `SpatRaster` objects. It adds a LOESS smooth with a confidence
#' interval and reports the Pearson correlation coefficient and a
#' spatially adjusted p-value.
#'
#' @param x A single-layer `SpatRaster` used for the x-axis.
#' @param y A single-layer `SpatRaster` used for the y-axis. It must have the
#'   same grid and alignment as `x`.
#' @param n The number of valid pixel pairs to sample (default: 1000).
#' @param span The span parameter passed to the LOESS smoother (default: 0.75).
#'   Smaller values produce a more flexible curve.
#' @param seed An optional random seed for reproducible sampling
#'   (default: `NULL`).
#' @param one_to_one_line A logical value indicating whether to add a dashed
#'   1:1 line (default: `FALSE`).
#' @param reg_line A logical value indicating whether to add an OLS regression
#'   line with its confidence interval (default: `FALSE`).
#' @param xlab An optional label for the x-axis. If `NULL`, the name of `x` is
#'   used.
#' @param ylab An optional label for the y-axis. If `NULL`, the name of `y` is
#'   used.
#'
#' @return A `ggplot` object showing the sampled pixel pairs, the LOESS curve,
#'   and the Pearson correlation. Optional 1:1 and OLS regression lines are
#'   included when requested.
#'
#' @details
#' The function randomly samples valid, corresponding pixel pairs from the
#' two raster layers. The Pearson correlation is calculated from the sampled
#' values. Its p-value is obtained using the modified t-test implemented in
#' `SpatialPack::modified.ttest`, which accounts for spatial autocorrelation.
#'
#' The confidence interval around the LOESS curve is calculated by
#' `ggplot2::geom_smooth`. When `reg_line = TRUE`, the OLS regression line is
#' also shown with its confidence interval.
#'
#' @seealso [terra::spatSample()], [SpatialPack::modified.ttest()]
#'
#' @examples
#' \dontrun{
#' im.loess(
#'   band1,
#'   band2,
#'   n = 1000,
#'   seed = 42,
#'   one_to_one_line = TRUE,
#'   reg_line = TRUE,
#'   xlab = "Band 1",
#'   ylab = "Band 2"
#' )
#' }
#'
#' @export
im.loess <- function(x, y, n = 1000, span = 0.75, seed = NULL,
                     one_to_one_line = FALSE, reg_line = FALSE) {
  stopifnot(terra::nlyr(x) == 1, terra::nlyr(y) == 1)

  if (!terra::compareGeom(x, y, stopOnError = FALSE)) {
    stop("The two bands must have the same grid and alignment.")
  }

  if (!is.null(seed)) set.seed(seed)

  data <- terra::spatSample(
    c(x, y),
    size = n,
    method = "random",
    na.rm = TRUE,
    as.df = TRUE,
    xy = TRUE
  )

  names(data) <- c("coord_x", "coord_y", "x", "y")

  spatial_test <- SpatialPack::modified.ttest(
    x = data$x,
    y = data$y,
    coords = as.matrix(data[c("coord_x", "coord_y")])
  )

  r <- spatial_test$corr
  p <- spatial_test$p.value

  plot <- ggplot2::ggplot(data, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(
      color = "#30D5C8",
      alpha = 0.65,
      size = 2
    ) +
    ggplot2::geom_smooth(
      ggplot2::aes(color = "LOESS"),
      method = "loess",
      formula = y ~ x,
      span = span,
      se = TRUE,
      fill = "#FDE725",
      alpha = 0.25,
      linewidth = 1.3
    ) +
    ggplot2::annotate(
      "label",
      x = -Inf,
      y = Inf,
      label = paste0(
        "Pearson r = ", round(r, 3),
        "\nDutilleul p = ",
        format.pval(p, digits = 3, eps = 0.001)
      ),
      hjust = -0.05,
      vjust = 1.2,
      size = 4
    ) +
    ggplot2::labs(
      x = names(x),
      y = names(y),
      title = "Relationship between the two bands",
      subtitle = paste("Random sample of", nrow(data), "pixels"),
      color = NULL
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.direction = "horizontal"
    )

  legend_lines <- character(0)

  if (one_to_one_line) {
    limits <- range(c(data$x, data$y), finite = TRUE)

    one_to_one_segment <- data.frame(
      x = limits[1],
      y = limits[1],
      xend = limits[2],
      yend = limits[2]
    )

    plot <- plot +
      ggplot2::geom_segment(
        data = one_to_one_segment,
        mapping = ggplot2::aes(
          x = x, y = y, xend = xend, yend = yend,
          color = "1:1 line"
        ),
        inherit.aes = FALSE,
        linetype = "dashed",
        linewidth = 1,
        show.legend = TRUE
      )

    legend_lines <- c(legend_lines, "1:1 line")
  }

  if (reg_line) {
    plot <- plot +
      ggplot2::geom_smooth(
        ggplot2::aes(color = "OLS", fill = "OLS"),
        method = "lm",
        formula = y ~ x,
        se = TRUE,
        alpha = 0.20,
        linewidth = 1
      )

    legend_lines <- c(legend_lines, "OLS")
  }

  legend_lines <- c(legend_lines, "LOESS")

  plot +
    ggplot2::scale_color_manual(
      values = c(
        "1:1 line" = "#008C95",
        "OLS" = "#7B2CBF",
        "LOESS" = "#FDE725"
      ),
      breaks = legend_lines
    ) +
    ggplot2::scale_fill_manual(
      values = c("OLS" = "#7B2CBF"),
      guide = "none"
    )
}

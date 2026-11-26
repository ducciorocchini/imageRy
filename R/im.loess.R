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

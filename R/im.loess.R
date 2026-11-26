im.loess <- function(x, y, n = 1000, span = 0.75, seed = NULL,
                     one_to_one_line = FALSE, reg_line = FALSE) {
  stopifnot(terra::nlyr(x) == 1, terra::nlyr(y) == 1)

  if (!terra::compareGeom(x, y, stopOnError = FALSE)) {
    stop("Le due bande devono avere la stessa griglia e lo stesso allineamento.")
  }

  if (!is.null(seed)) set.seed(seed)

  dati <- terra::spatSample(
    c(x, y),
    size = n,
    method = "random",
    na.rm = TRUE,
    as.df = TRUE,
    xy = TRUE
  )

  names(dati) <- c("coord_x", "coord_y", "x", "y")

  test_spaziale <- SpatialPack::modified.ttest(
    x = dati$x,
    y = dati$y,
    coords = as.matrix(dati[c("coord_x", "coord_y")])
  )

  r <- test_spaziale$corr
  p <- test_spaziale$p.value

  grafico <- ggplot2::ggplot(dati, ggplot2::aes(x = x, y = y)) +
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
      title = "Relazione tra le due bande",
      subtitle = paste("Campione casuale di", nrow(dati), "pixel"),
      color = NULL
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.direction = "horizontal"
    )

  linee_legenda <- character(0)

  if (one_to_one_line) {
    limiti <- range(c(dati$x, dati$y), finite = TRUE)

    segmento_1to1 <- data.frame(
      x = limiti[1],
      y = limiti[1],
      xend = limiti[2],
      yend = limiti[2]
    )

    grafico <- grafico +
      ggplot2::geom_segment(
        data = segmento_1to1,
        mapping = ggplot2::aes(
          x = x, y = y, xend = xend, yend = yend,
          color = "1:1 line (dashed)"
        ),
        inherit.aes = FALSE,
        linetype = "dashed",
        linewidth = 1,
        show.legend = TRUE
      )

    linee_legenda <- c(linee_legenda, "1:1 line (dashed)")
  }

  if (reg_line) {
    grafico <- grafico +
      ggplot2::geom_smooth(
        ggplot2::aes(
          color = "regression line",
          fill = "regression line"
        ),
        method = "lm",
        formula = y ~ x,
        se = TRUE,
        alpha = 0.20,
        linewidth = 1
      )

    linee_legenda <- c(linee_legenda, "regression line")
  }

  linee_legenda <- c(linee_legenda, "LOESS")

  grafico +
    ggplot2::scale_color_manual(
      values = c(
        "1:1 line" = "#008C95",
        "OLS" = "#7B2CBF",
        "LOESS" = "#FDE725"
      ),
      breaks = linee_legenda
    ) +
    ggplot2::scale_fill_manual(
      values = c("regression line" = "#7B2CBF"),
      guide = "none"
    )
}

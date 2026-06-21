#' Generate Ridgeline Plots from Raster Data
#'
#' This function generates ridgeline plots from multi-layer raster data.
#' Optional boxplots can be overlaid on each ridgeline to show median,
#' quartiles, whiskers, and outliers.
#'
#' @param im A `SpatRaster` object representing the raster data to be visualized.
#' @param scale A numeric value defining the vertical scale of the ridgelines.
#' @param palette A character string specifying the `viridis` color palette.
#' Available options are `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
#' `"cividis"`, `"mako"`, `"rocket"`, and `"turbo"`.
#' @param direction A numeric value controlling the direction of the color scale.
#' Use `1` for the default direction and `-1` to reverse the palette.
#' @param boxplot Logical. If `TRUE`, a boxplot is overlaid on each ridgeline.
#' @param boxplot_width Numeric value controlling the width of the overlaid boxplots.
#' @param boxplot_alpha Numeric value between 0 and 1 controlling boxplot
#' transparency. Use `0` for fully transparent boxes and `1` for opaque boxes.
#' @param rel_min_height Numeric value passed to
#' `ggridges::geom_density_ridges_gradient()`.
#'
#' @return A `ggplot` object displaying the ridgeline plot.
#'
#' @export
im.ridgeline <- function(
    im,
    scale = 2,
    palette = c(
      "viridis", "magma", "plasma", "inferno",
      "cividis", "mako", "rocket", "turbo"
    ),
    direction = 1,
    boxplot = FALSE,
    boxplot_width = 0.12,
    boxplot_alpha = 0,
    rel_min_height = 0.01
) {

  palette <- palette[1]

  if (!inherits(im, "SpatRaster"))
    stop("im must be a SpatRaster")

  if (!is.numeric(scale))
    stop("scale must be numeric")

  if (!is.numeric(direction))
    stop("direction must be numeric")

  if (!is.logical(boxplot))
    stop("boxplot must be TRUE or FALSE")

  if (!is.numeric(boxplot_width))
    stop("boxplot_width must be numeric")

  if (!is.numeric(boxplot_alpha))
    stop("boxplot_alpha must be numeric")

  if (boxplot_alpha < 0 || boxplot_alpha > 1)
    stop("boxplot_alpha must be between 0 and 1")

  if (!is.numeric(rel_min_height))
    stop("rel_min_height must be numeric")

  allowed_palettes <- c(
    "viridis", "magma", "plasma", "inferno",
    "cividis", "mako", "rocket", "turbo"
  )

  if (!palette %in% allowed_palettes) {
    stop(
      "palette must be one of: ",
      paste(allowed_palettes, collapse = ", ")
    )
  }

  df <- terra::as.data.frame(im, wide = FALSE)
  df <- df[is.finite(df$values), ]

  pl <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = values,
      y = layer,
      fill = ggplot2::after_stat(x)
    )
  ) +
    ggridges::geom_density_ridges_gradient(
      scale = scale,
      rel_min_height = rel_min_height
    ) +
    ggplot2::scale_fill_viridis_c(
      option = palette,
      direction = direction
    )

  if (boxplot) {

    pl <- pl +
      ggplot2::geom_boxplot(
        data = df,
        ggplot2::aes(
          x = values,
          y = layer,
          group = layer
        ),
        inherit.aes = FALSE,
        width = boxplot_width,
        fill = scales::alpha("white", boxplot_alpha),
        colour = "black",
        linewidth = 0.4,
        outlier.size = 0.3
      )
  }

  return(pl)
}

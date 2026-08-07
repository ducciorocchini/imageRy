#' Generate Ridgeline Plots from Raster Data
#'
#' This function generates ridgeline plots from multi-layer raster data.
#' Colors can represent continuous raster values, discrete quartiles, or a
#' smooth quartile-based gradient.
#'
#' @param im A `SpatRaster` object representing the raster data to be visualized.
#' @param scale A numeric value defining the vertical scale of the ridgelines
#'   (default: 2).
#' @param palette A character string specifying the `viridis` color palette.
#'   Available options are `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`,
#'   `"cividis"`, `"mako"`, `"rocket"`, and `"turbo"`.
#' @param direction A numeric value controlling the direction of the color
#'   palette. Use `1` for the default direction and `-1` to reverse it
#'   (default: 1).
#' @param color_by A character string specifying how colors are assigned.
#'   Available options are `"value"`, `"quartile"`, and `"quartile_smooth"`.
#'   `"value"` uses a continuous gradient based on raster values;
#'   `"quartile"` assigns four discrete colors to Q1-Q4;
#'   `"quartile_smooth"` produces a continuous gradient scaled according to
#'   the quartile position of values within each raster layer.
#' @param rel_min_height A numeric value controlling the minimum relative
#'   density height displayed (default: 0.01).
#'
#' @return A `ggplot` object displaying the ridgeline plot.
#'
#' @details
#' Quartiles are calculated independently for each raster layer.
#'
#' When `color_by = "quartile"`, values are divided into four intervals
#' delimited by the first quartile, median, and third quartile.
#'
#' When `color_by = "quartile_smooth"`, colors vary continuously across each
#' distribution while the color scale is normalized so that each quartile
#' occupies one quarter of the palette.
#'
#' @export
im.ridgeline <- function(
    im,
    scale = 2,
    palette = "viridis",
    direction = 1,
    color_by = c(
      "value",
      "quartile",
      "quartile_smooth"
    ),
    rel_min_height = 0.01
) {

  # Check raster input
  if (!inherits(im, "SpatRaster")) {
    stop("im must be a SpatRaster object.")
  }

  if (terra::nlyr(im) < 1) {
    stop("im must contain at least one raster layer.")
  }

  # Check scale
  if (!is.numeric(scale) ||
      length(scale) != 1 ||
      !is.finite(scale) ||
      scale <= 0) {
    stop("scale must be a positive numeric value.")
  }

  # Check direction
  if (!is.numeric(direction) ||
      length(direction) != 1 ||
      is.na(direction) ||
      !direction %in% c(1, -1)) {
    stop("direction must be either 1 or -1.")
  }

  # Check rel_min_height
  if (!is.numeric(rel_min_height) ||
      length(rel_min_height) != 1 ||
      !is.finite(rel_min_height) ||
      rel_min_height < 0) {
    stop(
      "rel_min_height must be a non-negative numeric value."
    )
  }

  # Check color mode
  color_by <- match.arg(color_by)

  # Available viridis palettes
  allowed_palettes <- c(
    "viridis",
    "magma",
    "plasma",
    "inferno",
    "cividis",
    "mako",
    "rocket",
    "turbo"
  )

  # Check palette
  if (!is.character(palette) ||
      length(palette) != 1 ||
      is.na(palette) ||
      !palette %in% allowed_palettes) {

    stop(
      paste0(
        "palette must be one of: ",
        paste(
          allowed_palettes,
          collapse = ", "
        ),
        "."
      )
    )
  }

  # Convert raster to long-format data frame
  df <- terra::as.data.frame(
    im,
    wide = FALSE
  )

  # Remove missing / non-finite values
  df <- df[
    is.finite(df$values),
    ,
    drop = FALSE
  ]

  if (nrow(df) == 0) {
    stop(
      "No finite raster values are available for plotting."
    )
  }

  # ----------------------------------------------------------
  # 1. CONTINUOUS VALUE GRADIENT
  # ----------------------------------------------------------

  if (color_by == "value") {

    # Reverse factor levels so that first raster layer appears on top
    df$layer <- factor(
      df$layer,
      levels = rev(names(im))
    )

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
        direction = direction,
        name = "Value"
      ) +
      ggplot2::labs(
        x = "Value",
        y = "Layer"
      )

    return(pl)
  }

  # ----------------------------------------------------------
  # Build density estimates and layer-specific quartiles
  # ----------------------------------------------------------

  density_list <- lapply(
    names(im),
    function(layer_name) {

      vals <- df$values[
        df$layer == layer_name
      ]

      # Skip layers with too few values
      if (length(vals) < 2) {
        return(NULL)
      }

      dens <- stats::density(vals)

      q <- stats::quantile(
        vals,
        probs = c(
          0.25,
          0.50,
          0.75
        ),
        na.rm = TRUE,
        names = FALSE
      )

      # ------------------------------------------------------
      # Discrete quartile class
      # ------------------------------------------------------

      quartile_class <- cut(
        dens$x,
        breaks = c(
          -Inf,
          q[1],
          q[2],
          q[3],
          Inf
        ),
        labels = c(
          "Q1",
          "Q2",
          "Q3",
          "Q4"
        ),
        include.lowest = TRUE
      )

      # ------------------------------------------------------
      # Smooth quartile position
      # ------------------------------------------------------

      xmin <- min(dens$x)
      xmax <- max(dens$x)

      qpos <- numeric(length(dens$x))

      # Q1
      id1 <- dens$x <= q[1]

      if (q[1] > xmin) {
        qpos[id1] <-
          0.25 *
          (
            dens$x[id1] - xmin
          ) /
          (
            q[1] - xmin
          )
      } else {
        qpos[id1] <- 0.25
      }

      # Q2
      id2 <- dens$x > q[1] &
        dens$x <= q[2]

      if (q[2] > q[1]) {
        qpos[id2] <-
          0.25 +
          0.25 *
          (
            dens$x[id2] - q[1]
          ) /
          (
            q[2] - q[1]
          )
      } else {
        qpos[id2] <- 0.50
      }

      # Q3
      id3 <- dens$x > q[2] &
        dens$x <= q[3]

      if (q[3] > q[2]) {
        qpos[id3] <-
          0.50 +
          0.25 *
          (
            dens$x[id3] - q[2]
          ) /
          (
            q[3] - q[2]
          )
      } else {
        qpos[id3] <- 0.75
      }

      # Q4
      id4 <- dens$x > q[3]

      if (xmax > q[3]) {
        qpos[id4] <-
          0.75 +
          0.25 *
          (
            dens$x[id4] - q[3]
          ) /
          (
            xmax - q[3]
          )
      } else {
        qpos[id4] <- 1
      }

      data.frame(
        x = dens$x,
        density = dens$y,
        layer = layer_name,
        quartile = quartile_class,
        qpos = qpos
      )
    }
  )

  density_list <- density_list[
    !vapply(
      density_list,
      is.null,
      logical(1)
    )
  ]

  if (length(density_list) == 0) {
    stop(
      "Density estimates could not be calculated."
    )
  }

  density_df <- do.call(
    rbind,
    density_list
  )

  # First raster layer on top
  density_df$layer <- factor(
    density_df$layer,
    levels = rev(names(im))
  )

  density_df$quartile <- factor(
    density_df$quartile,
    levels = c(
      "Q1",
      "Q2",
      "Q3",
      "Q4"
    )
  )

  # ----------------------------------------------------------
  # 2. DISCRETE QUARTILE COLORS
  # ----------------------------------------------------------

  if (color_by == "quartile") {

    quartile_colors <- viridisLite::viridis(
      4,
      option = palette,
      direction = direction
    )

    pl <- ggplot2::ggplot(
      density_df,
      ggplot2::aes(
        x = x,
        y = layer,
        height = density,
        group = interaction(
          layer,
          quartile
        ),
        fill = quartile
      )
    ) +
      ggridges::geom_ridgeline(
        stat = "identity",
        scale = scale,
        min_height = 0,
        colour = "white",
        linewidth = 0.15
      ) +
      ggplot2::scale_fill_manual(
        values = quartile_colors,
        name = "Quartile"
      ) +
      ggplot2::labs(
        x = "Value",
        y = "Layer"
      )

    return(pl)
  }

  # ----------------------------------------------------------
  # 3. SMOOTH QUARTILE GRADIENT
  # ----------------------------------------------------------

  if (color_by == "quartile_smooth") {

    pl <- ggplot2::ggplot(
      density_df,
      ggplot2::aes(
        x = x,
        y = layer,
        height = density,
        group = layer,
        fill = qpos
      )
    ) +
      ggridges::geom_ridgeline_gradient(
        stat = "identity",
        scale = scale,
        min_height = 0,
        colour = NA
      ) +
      ggplot2::scale_fill_viridis_c(
        option = palette,
        direction = direction,
        limits = c(0, 1),
        breaks = c(
          0.125,
          0.375,
          0.625,
          0.875
        ),
        labels = c(
          "Q1",
          "Q2",
          "Q3",
          "Q4"
        ),
        name = "Quartile"
      ) +
      ggplot2::labs(
        x = "Value",
        y = "Layer"
      )

    return(pl)
  }
}

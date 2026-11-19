#' Generate Ridgeline Plots from Raster Data
#'
#' This function generates ridgeline plots from multi-layer raster data.
#' Colors can represent continuous raster values, discrete quartiles, or a
#' smooth quartile-based gradient.
#'
#' @param input_image A `SpatRaster` object representing the raster data to be visualized.
#' @param scale A numeric value defining the vertical scale of the ridgelines
#'   (default: 2).
#' @param custom_colors A character string specifying a `viridis` color palette,
#'   or a character vector of custom colors (default: "viridis").
#'   Available viridis options are `"viridis"`, `"magma"`, `"plasma"`,
#'   `"inferno"`, `"cividis"`, `"mako"`, `"rocket"`, and `"turbo"`.
#' @param direction A numeric value controlling the direction of the selected
#'   viridis palette. Use `1` for the default direction and `-1` to reverse it
#'   (default: 1). Only applies to named viridis palettes.
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
#' Custom color vectors must contain at least two valid colors. For discrete
#' quartiles, colors are interpolated if fewer than four are provided;
#' otherwise, the first four colors are used.
#'
#' @export

im.ridgeline <- function(input_image,
                         scale = 2, # vertical scale of the ridgelines
                         custom_colors = "viridis", # custom color palette
                         direction = 1, # direction of the viridis palette
                         color_by = c("value", "quartile", "quartile_smooth"), # color assignment mode
                         rel_min_height = 0.01) { # minimum relative density height
  
  # Check raster input
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image must be a SpatRaster object.")
  }
  
  if (terra::nlyr(input_image) < 1) {
    stop("input_image must contain at least one raster layer.")
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
    stop("rel_min_height must be a non-negative numeric value.")
  }
  
  # Check color mode
  color_by <- match.arg(color_by)
  
  # Handle colors
  viridis_opts <- c(
    "viridis", "magma", "plasma", "inferno",
    "cividis", "mako", "rocket", "turbo"
  )
  
  if (is.character(custom_colors) &&
      length(custom_colors) == 1 &&
      !is.na(custom_colors)) {
    
    if (!custom_colors %in% viridis_opts) {
      stop(
        "If custom_colors is a single string, it must be one of: ",
        paste(viridis_opts, collapse = ", "),
        "."
      )
    }
    
    # Generate viridis palettes
    continuous_colors <- viridisLite::viridis(
      256,
      option = custom_colors,
      direction = direction
    )
    
    quartile_colors <- viridisLite::viridis(
      4,
      option = custom_colors,
      direction = direction
    )
    
  } else if (is.character(custom_colors) &&
             length(custom_colors) >= 2 &&
             !anyNA(custom_colors)) {
    
    # Check custom colors
    tryCatch(
      grDevices::col2rgb(custom_colors),
      error = function(e) {
        stop("custom_colors contains invalid colours.")
      }
    )
    
    # Generate custom palette
    continuous_colors <- custom_colors
    
    if (length(custom_colors) < 4) {
      
      quartile_colors <- grDevices::colorRampPalette(
        custom_colors
      )(4)
      
    } else {
      
      quartile_colors <- custom_colors[seq_len(4)]
    }
    
  } else {
    stop("custom_colors must be a palette name or a character vector of colors.")
  }
  
  # Convert raster to long-format data frame
  df <- terra::as.data.frame(
    input_image,
    wide = FALSE
  )
  
  # Remove missing / non-finite values
  df <- df[
    is.finite(df$values),
    ,
    drop = FALSE
  ]
  
  if (nrow(df) == 0) {
    stop("No finite raster values are available for plotting.")
  }
  
  # ----------------------------------------------------------
  # 1. CONTINUOUS VALUE GRADIENT
  # ----------------------------------------------------------
  
  if (color_by == "value") {
    
    # Reverse factor levels so that first raster layer appears on top
    df$layer <- factor(
      df$layer,
      levels = rev(names(input_image))
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
      ggplot2::scale_fill_gradientn(
        colours = continuous_colors,
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
    names(input_image),
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
    stop("Density estimates could not be calculated.")
  }
  
  density_df <- do.call(
    rbind,
    density_list
  )
  
  # First raster layer on top
  density_df$layer <- factor(
    density_df$layer,
    levels = rev(names(input_image))
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
      ggplot2::scale_fill_gradientn(
        colours = continuous_colors,
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

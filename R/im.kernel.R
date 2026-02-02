#' Compute Moving-Window (Kernel) Statistics on a Single-Layer Raster
#'
#' This function applies a moving window (kernel) operation to a single-layer
#' `SpatRaster` and returns one or more focal statistics (mean, median, sd, var,
#' cv, range).
#'
#' @param input_image A `SpatRaster` object with a single layer.
#' @param mw A positive odd integer specifying the moving window size (default: 3).
#'   The window is square (mw x mw), like in `terra::focal()`. :contentReference[oaicite:1]{index=1}
#' @param stat Character vector of statistics to compute. Options:
#'   `c("mean", "median", "sd", "var", "cv", "range")`.
#'   By default, all statistics are computed.
#'
#' @return A `SpatRaster` with one layer per requested statistic.
#'
#' @details
#' - **cv** is computed as `sd / mean` (returns `NA` where mean is 0 or `NA`).
#' - **range** is computed as `max - min` within the moving window.
#' - `NA` values are ignored when possible (`na.rm = TRUE`).
#'
#' @seealso [terra::focal()]
#'
#' @examples
#' library(terra)
#' r <- rast(nrows = 50, ncols = 50)
#' values(r) <- runif(ncell(r))
#'
#' # All stats (default)
#' k_all <- im.kernel(r)
#'
#' # Only mean and sd with a 5x5 window
#' k_ms <- im.kernel(r, mw = 5, stat = c("mean", "sd"))
#'
#' plot(k_ms)
#' @export
im.kernel <- function(input_image, mw = 3,
                      stat = c("mean", "median", "sd", "var", "cv", "range")) {

  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  if (terra::nlyr(input_image) != 1) {
    stop("input_image must have a single layer (nlyr == 1).")
  }

  if (!inherits(mw, "numeric") || length(mw) != 1 || is.na(mw)) {
    stop("mw must be a single numeric value.")
  }
  mw <- as.integer(mw)
  if (mw < 1 || (mw %% 2) == 0) {
    stop("mw must be a positive odd integer (e.g., 3, 5, 7, ...).")
  }

  stat <- match.arg(
    stat,
    choices = c("mean", "median", "sd", "var", "cv", "range"),
    several.ok = TRUE
  )

  fun_range <- function(v) {
    if (all(is.na(v))) return(NA_real_)
    rng <- range(v, na.rm = TRUE)
    rng[2] - rng[1]
  }

  fun_cv <- function(v) {
    if (all(is.na(v))) return(NA_real_)
    m <- mean(v, na.rm = TRUE)
    if (is.na(m) || m == 0) return(NA_real_)
    stats::sd(v, na.rm = TRUE) / m
  }

  out <- list()

  if ("mean" %in% stat) {
    out[["mean"]] <- terra::focal(input_image, w = mw, fun = mean, na.rm = TRUE)
  }
  if ("median" %in% stat) {
    out[["median"]] <- terra::focal(input_image, w = mw, fun = stats::median, na.rm = TRUE)
  }
  if ("sd" %in% stat) {
    out[["sd"]] <- terra::focal(input_image, w = mw, fun = stats::sd, na.rm = TRUE)
  }
  if ("var" %in% stat) {
    out[["var"]] <- terra::focal(input_image, w = mw, fun = stats::var, na.rm = TRUE)
  }
  if ("cv" %in% stat) {
    out[["cv"]] <- terra::focal(input_image, w = mw, fun = fun_cv)
  }
  if ("range" %in% stat) {
    out[["range"]] <- terra::focal(input_image, w = mw, fun = fun_range)
  }

  # Combine outputs into a multi-layer SpatRaster
  res <- terra::rast(out)

  # Name output layers nicely
  names(res) <- names(out)

  # Plot all layers (explicit terra method)
  terra::plot(res)

  invisible(res)
}

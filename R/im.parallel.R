
#' Visualize Temporal Class Transitions Using Parallel Sets
#'
#' This function generates a parallel sets plot to visualize changes in
#' classification categories across a time series of raster images.
#' It represents temporal trajectories of pixels between classes, allowing
#' the exploration of class persistence and transitions over time.
#'
#' @param input_classification A list representing the output of
#'   [im.classify.timeseries()], containing classified raster images
#'   in the `result` element.
#' @param axis_labels An optional character vector specifying labels for
#'   the temporal axes. If NULL, the names of the classified images are used
#'   (default: NULL).
#' @param custom_colors An optional character vector of colors used to
#'   represent the classes. If NULL, the viridis palette is used
#'   (default: NULL).
#' @param alpha A numeric value controlling the transparency of the
#'   flows between classes (default: 0.7).
#' @param axis.width A numeric value controlling the width of the
#'   vertical category bars (default: 0.13).
#'
#' @return A `ggplot` object representing temporal class transitions
#'   through a parallel sets diagram.
#'
#' @details
#' The function takes the output of [im.classify.timeseries()] and
#' combines the classified raster images into a single raster stack.
#' Pixel values are extracted across all time steps to identify
#' temporal trajectories of class membership.
#'
#' Each unique sequence of classes represents a temporal trajectory,
#' and the number of pixels following that trajectory determines
#' the width of the corresponding flow in the parallel sets plot.
#'
#' The visualization procedure consists of the following steps:
#' \itemize{
#'   \item Combining classified raster images into a single stack.
#'   \item Extracting pixel values across all time steps.
#'   \item Excluding pixels with missing values in any time step.
#'   \item Identifying unique temporal trajectories of class membership.
#'   \item Counting the number of pixels associated with each trajectory.
#'   \item Visualizing class transitions using parallel sets.
#' }
#'
#' Each vertical axis represents a different time step, while the
#' categories along the axes represent the classification classes.
#' The width of each flow is proportional to the number of pixels
#' following a specific temporal trajectory.
#'
#' Flow colors are assigned according to the class of origin at the
#' first time step, allowing the visual identification of subsequent
#' transitions and class persistence.
#'
#' Additional options:
#' \itemize{
#'   \item If `axis_labels` is provided, custom labels are used for
#'   the temporal axes.
#'   \item If `custom_colors` is provided, a custom palette is used
#'   to represent the classes.
#'   \item The `alpha` parameter controls the transparency of flows.
#'   \item The `axis.width` parameter controls the width of the
#'   flow segments at the axes.
#' }
#'
#' This function is particularly useful for investigating land-cover
#' transitions, vegetation dynamics, ecological change, and the
#' persistence of spectral classes through time.
#'
#' Since class labels are derived from a common k-means classification,
#' transitions can be interpreted consistently across different
#' time steps.
#'
#' @seealso [im.classify.timeseries()], [im.classify()], [im.barplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Create three example raster images
#' r1 <- rast(nrows = 50, ncols = 50, nlyrs = 3)
#' values(r1) <- matrix(runif(ncell(r1) * 3), ncol = 3)
#'
#' r2 <- rast(r1)
#' values(r2) <- matrix(runif(ncell(r2) * 3), ncol = 3)
#'
#' r3 <- rast(r1)
#' values(r3) <- matrix(runif(ncell(r3) * 3), ncol = 3)
#'
#' # Organize images into a time series
#' images <- list(time1 = r1, time2 = r2, time3 = r3)
#'
#' # Perform common k-means classification
#' classified <- im.classify.timeseries(
#'   images,
#'   num_clusters = 3,
#'   seed = 42,
#'   do_plot = FALSE
#' )
#'
#' # Visualize temporal class transitions
#' im.parallel(classified)
#'
#' # Use custom axis labels
#' im.parallel(
#'   classified,
#'   axis_labels = c("Year 1", "Year 2", "Year 3")
#' )
#'
#' # Use custom colors
#' im.parallel(
#'   classified,
#'   custom_colors = c("forestgreen", "gold", "firebrick")
#' )
#'
#' # Adjust transparency and axis width
#' im.parallel(
#'   classified,
#'   alpha = 0.5,
#'   axis.width = 0.2
#' )
#' }
#'
#' @export
im.parallel <- function(input_classification, # output of im.classify.timeseries()
                        axis_labels = NULL, # set axis labels
                        custom_colors = NULL, # set custom colors
                        alpha = 0.7, # set the color transparency
                        axis.width = 0.13) { # control the width of vertical category bars
  
  # Check input
  if (!is.list(input_classification)) {
    stop("input_classification should be the output of im.classify.timeseries().")
  }
  
  if (!"result" %in% names(input_classification)) {
    stop("input_classification should contain a 'result' element.")
  }
  
  classified_images <- input_classification$result
  
  if (!is.list(classified_images)) {
    stop("input_classification$result should be a list of classified SpatRaster objects.")
  }
  
  if (length(classified_images) < 2) {
    stop("input_classification$result should contain at least two classified images.")
  }
  
  if (!all(vapply(classified_images, inherits, logical(1), what = "SpatRaster"))) {
    stop("All elements of input_classification$result should be SpatRaster objects.")
  }
  
  # Set axis labels
  if (is.null(axis_labels)) {
    axis_labels <- names(classified_images)
  }
  
  if (length(axis_labels) != length(classified_images)) {
    stop("axis_labels should have the same length as input_classification$result.")
  }
  
  # Create stack of classified rasters
  class_stack <- do.call(
    c,
    classified_images
  )
  
  names(class_stack) <- names(classified_images)
  
  # Convert to data frame
  class_df <- terra::as.data.frame(
    class_stack,
    na.rm = TRUE
  )
  
  names(class_df) <- names(class_stack)
  
  # Count temporal trajectories
  transition_counts <- class_df |>
    dplyr::count(
      dplyr::across(dplyr::everything()),
      name = "count"
    )
  
  # Convert classes to factors
  transition_counts <- transition_counts |>
    dplyr::mutate(
      dplyr::across(
        -count,
        ~ factor(.x, levels = sort(unique(.x)))
      )
    )
  
  # Prepare data for parallel sets
  parallel_data <- ggforce::gather_set_data(
    transition_counts,
    1:(ncol(transition_counts) - 1)
  )
  
  # Order axes
  parallel_data$x <- factor(
    parallel_data$x,
    levels = names(classified_images)
  )
  
  # Set colors
  class_levels <- levels(transition_counts[[1]])
  
  if (is.null(custom_colors)) {
    color_palette <- viridisLite::viridis(length(class_levels))
  } else {
    color_palette <- custom_colors
  }
  
  names(color_palette) <- class_levels
  
  # Plot
  ggplot2::ggplot(
    parallel_data,
    ggplot2::aes(
      x,
      id = id,
      split = y,
      value = count
    )
  ) +
    ggforce::geom_parallel_sets(
      ggplot2::aes(fill = .data[[names(classified_images)[1]]]),
      alpha = alpha,
      axis.width = axis.width
    ) +
    ggforce::geom_parallel_sets_axes(
      axis.width = 0.1,
      fill = "grey80",
      color = "grey80"
    ) +
    ggforce::geom_parallel_sets_labels(
      color = "black",
      size = 3,
      angle = 90
    ) +
    ggplot2::scale_x_discrete(
      name = NULL,
      labels = axis_labels,
      expand = c(0, 0.2)
    ) +
    ggplot2::scale_y_continuous(
      breaks = NULL,
      expand = c(0, 0)
    ) +
    ggplot2::scale_fill_manual(
      values = color_palette,
      guide = "none"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(
        color = "black",
        size = 10
      ),
      plot.margin = ggplot2::margin(14, 1.5, 2, 1.5)
    )
}

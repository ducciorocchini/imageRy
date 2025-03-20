#' Set Up a Multi-Frame Plot Layout
#'
#' This function sets up a multi-frame plotting layout using `par(mfrow = c(x, y))`,
#' allowing multiple plots to be displayed in a grid format.
#'
#' @param x An integer specifying the number of rows in the plot layout.
#' @param y An integer specifying the number of columns in the plot layout.
#'
#' @return No return value. This function modifies the graphical parameters globally.
#'
#' @details
#' This function changes the `mfrow` graphical parameter using `par()`, enabling multiple plots
#' to be displayed in a grid layout within the same plotting window.
#'
#' **Important:** Since `par()` modifies global graphical settings, its effect remains until
#' reset using `par(mfrow = c(1,1))` or restarting the plotting device.
#'
#' @seealso [im.ggplot()], [im.import()]
#'
#' @examples
#' \dontrun{
#' # Set up a 2x2 plotting layout
#' im.multiframe(2, 2)
#'
#' # Example plots
#' plot(1:10, rnorm(10))
#' plot(1:10, runif(10))
#' plot(1:10, rpois(10, lambda = 5))
#' plot(1:10, rbeta(10, shape1 = 2, shape2 = 5))
#'
#' # Reset to single plot layout
#' par(mfrow = c(1,1))
#' }
#'
#' @export
im.multiframe <- function(x,y){
  par(mfrow=c(x,y))
  }

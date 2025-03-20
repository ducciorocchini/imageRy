#' List Available Raster Images in the imageRy Package
#'
#' This function lists all raster images stored in the `imageRy` package.
#'
#' @return A character vector containing the names of available raster image files.
#'
#' @details
#' The function retrieves the names of all files in the "images" directory of the `imageRy` package.
#' These files can be imported using `im.import()`.
#'
#' @seealso [im.import()]
#'
#' @examples
#' \dontrun{
#' library(imageRy)
#'
#' # List available images
#' im.list()
#' }
#'
#' @export
im.list <- function() {
  list.files(system.file("images", package="imageRy"))
}

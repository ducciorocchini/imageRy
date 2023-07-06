#' im.refresh
#' 
#' A function to refresh imageRy
#'
#' @refresh imageRy
#' @export
#'
#' @examples
#' im.refresh()

im.refresh <- function(){
  devtools::install_github("ducciorocchini/imageRy", force=T)
}


#' im_refresh
#' 
#' A function to refresh imageRy
#'
#' @refresh imageRy
#' @export
#'
#' @examples
#' im_refresh()

im_refresh <- function(){
  devtools::install_github("ducciorocchini/imageRy", force=T)
}


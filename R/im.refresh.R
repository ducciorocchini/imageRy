#' Refresh and Reinstall the imageRy Package from GitHub
#'
#' This function installs the latest version of the `imageRy` package from GitHub,
#' forcing an update even if the package is already installed.
#'
#' @return This function does not return an object. It installs `imageRy` and updates it to the latest version.
#'
#' @details
#' - The function uses `devtools::install_github()` to install the package directly from GitHub.
#' - The `force = TRUE` argument ensures that the package is reinstalled even if it is already installed.
#' - This function is useful when testing the latest changes in the package.
#'
#' **Note:** The `devtools` package must be installed for this function to work.
#'
#' @seealso [devtools::install_github()]
#'
#' @examples
#' \dontrun{
#' # Reinstall the latest version of imageRy from GitHub
#' im.refresh()
#' }
#'
#' @export
im.refresh <- function(){
  devtools::install_github("ducciorocchini/imageRy", force=T)
}

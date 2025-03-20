#' Perform Principal Component Analysis (PCA) on a Raster Image
#'
#' This function applies Principal Component Analysis (PCA) to a multispectral raster image,
#' extracting all available principal components. It reduces dimensionality while preserving
#' the most important variance in the dataset.
#'
#' @param input_image A `SpatRaster` object representing the input multispectral image.
#' @param n_samples An integer specifying the number of random samples used for PCA computation (default: 100).
#'
#' @return A `SpatRaster` object containing all computed principal components.
#'
#' @details
#' Principal Component Analysis (PCA) is a statistical technique used to transform correlated
#' raster bands into a set of orthogonal components, capturing the most variance in fewer bands.
#'
#' - The function **automatically determines** the number of components based on the number of bands.
#' - A sample of `n_samples` pixels is used to compute the PCA transformation.
#' - The **full image** is then projected onto the principal component space.
#' - The resulting raster contains **all computed principal components**.
#' - The output is visualized using a `viridis` color scale.
#'
#' @seealso [im.import()], [im.ggplot()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(viridis)
#'
#' # Load a multispectral raster
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Perform PCA on the raster
#' pca_result <- im.pca(r, n_samples = 200)
#'
#' # Plot the first principal component
#' plot(pca_result[[1]])
#' }
#'
#' @export
library(terra)
library(viridis)

im.pca <- function(input_image, n_samples = 100, n_components = 3) {
  
  #Verify that the input is a SpatRaster
  if(!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  # 1.sampling
  sample <- spatSample(input_image, n_samples)
  
  # 2.PCA
  pca <- prcomp(sample)
  
  # Prints the explained variance and correlation with the original bands print(summary(pca))
  print(pca)
  
  # 3.PCA map
  pci <- predict(input_image, pca, index=c(1:n_components))
  
  viridis_palette <- colorRampPalette(viridis(7))(255)
  plot(pci, col=viridis_palette)
  
  return(pci)
}


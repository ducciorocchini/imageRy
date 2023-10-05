library(terra)
library(viridis)

im.pca2 <- function(input_image, n_samples = 100, n_components = 3) {
  
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


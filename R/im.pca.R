im.pca <- function(x){
  
  if(!inherits(x, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  # random sample
  df <- as.data.frame(x)
  set.seed(1)
  sr <- sample(1:nrow(df), 10000)
  
  # principal component
  pca <- prcomp(df[sr,])
  
  # variance explained
  summary(pca)
  
  # pc map
  pci <- predict(x, pca, index = 1:2)
  plot(pci[[1]])
  
  return(pci)
  
}



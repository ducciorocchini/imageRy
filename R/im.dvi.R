im.ndvi <- function(x, nir, red){
  
  if(!inherits(x, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(nir, "numeric") && !inherits(red, "numeric")) {
    stop("NIR and red layers should be indicated with a number")
  }
  
  ndvi <- (x[[nir]] - x[[red]]) / (x[[nir]] + x[[red]])
  print(im.ggplot(ndvi))
  
  return(ndvi)

}


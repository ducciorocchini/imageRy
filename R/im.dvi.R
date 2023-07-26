im.dvi <- function(x,nir,red){
  
  if(!inherits(x, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(nir, "numeric") && !inherits(red, "numeric")) {
    stop("NIR and red layers should be indicated with a number")
  }
  
  dvi <- x[[nir]] - x[[red]]
  print(im.ggplot(dvi))
  
  return(dvi)
}

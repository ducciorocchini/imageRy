# im_plotRGB directly plot any image with the first three bands
im_plotRGB <- function(x){
  library(terra)
  plotRGB(x,1,2,3,stretch="lin")
}

# im.plotRGB.auto directly plot any image with the first three bands
im.plotRGB.auto <- function(x){
  plotRGB(x,1,2,3,stretch="lin")
}

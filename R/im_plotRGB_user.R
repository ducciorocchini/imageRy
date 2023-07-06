# im_plotRGB_user: plotRGB choosing bands

im_plotRGB_user <- function(x,r,g,b){
  library(terra)
  plotRGB(x,r,g,b,stretch="lin")
}

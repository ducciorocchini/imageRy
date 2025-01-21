# im.plotRGB.auto directly plot any image with the first three bands
im.plotRGB.auto <- function(x, title = deparse(substitute(x))){
  plotRGB(x,1,2,3,stretch="lin")
  par(col.axis="white", col.lab = "white", tck = 0)
  title(main = title, cex.main = 1.3, line = 2.5)
}


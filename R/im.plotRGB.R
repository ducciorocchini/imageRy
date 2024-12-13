# im.plotRGB: plotRGB choosing bands
im.plotRGB <- function(x, r, g, b, title = 'Main'){
  par(col.axis="white", col.lab = "white", tck = 0)
  plotRGB(x, r, g, b, stretch = "lin", axes = T, mar = c(1,1,2,1))
  title(main = title, cex.main = 1.3, line = 2.5)
}

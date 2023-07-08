im.ggplot <- function(input_raster, layerfill) {
  # Convert raster to dataframe and create plot directly
  print(
    ggplot(as.data.frame(input_raster, xy=TRUE), 
           aes(x=x, y=y, fill=!!sym(layerfill))) +
      geom_raster(interpolate = TRUE) +
      scale_fill_viridis(option = 'viridis')
  )
}

p <- im.ggplot(input_raster = mato, layerfill = "matogrosso_ast_2006209_lrg_2")




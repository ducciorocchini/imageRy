im.ggplot <- function(input_raster, layerfill = 1) {
  # Convert raster to dataframe and create plot directly
  if(!inherits(input_raster, "SpatRaster")) {
    stop("Input image should be a SpatRaster object.")
  }
  
  if(!inherits(layerfill, "numeric")) {
    stop("Input layer should be indicated with a number")
  }
  
  df <- as.data.frame(input_raster, xy = TRUE)
  layerfill <- colnames(df)[layerfill + 2]
  
  print(
    ggplot(df, 
           aes(x = x, y = y, fill = !!sym(layerfill))) +
      geom_raster(interpolate = TRUE) +
      scale_fill_viridis(option = 'viridis')
  )
}

# p <- im.ggplot(input_raster = mato, layerfill = "matogrosso_ast_2006209_lrg_2")




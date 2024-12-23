im.ridgeline <- function(im, scale, palette = c("viridis", "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo")) {
  
  palette <- palette[1]
  
  #Checking inputs
  if(!is(im, "SpatRaster")) stop("im must be a SpatRaster")
  if(!is.numeric(scale)) stop("scale must be numeric")
  if(!is.character(palette)) stop("palette must be a character")
  if(!palette %in% c("viridis", "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo")) stop("palette must be one of the color options in the viridis package (viridis, magma, plasma, inferno, cividis, mako, rocket, turbo)")
  
  switch(palette, 
         viridis = 'D',
         magma = 'A',
         inferno = 'B',
         plasma = 'C',
         cividis = 'E',
         rocket = 'F',
         mako = 'G',
         turbo = 'H')
  
  #Transforming im in a dataframe
  df <- as.data.frame(im, wide = FALSE)
  
  #Final graph
  pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, fill = after_stat(x))) +
    ggridges::geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
    ggplot2::scale_fill_viridis_c(option = palette)
  
  return(pl)
}

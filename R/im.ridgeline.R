# Original code: Elisa Thouverai
# Arguments of the function: im = image, scale = dimension of the ridges in the final plot, option = viridis type of color ramp palette; to be put in the manual
# Packages needed as dependencies of imageRY: tidyverse

im.ridgeline <- function(im, scale, option) {
  
  #Checking inputs
  if(!is(im, "SpatRaster")) stop("im must be a SpatRaster")
  if(!is.numeric(scale)) stop("scale must be numeric")
  if(!is.character(option)) stop("ooption must be a character")
  if(!option %in% c("A", "B", "C", "D", "E", "F", "G", "H")) stop("option must be one of the color ooptions in the viris pachage (A,B,C,D,E,F,G,H)")
  
  #Transforming im in a dataframe
  df <- as.data.frame(im)
  
  #Dataframe for ggplot 
  dfpl <- df %>%
    flatten_dbl() %>%
    as.data.frame() %>%
    mutate(layer = as.factor(rep(names(im), each = nrow(df))))
  
  colnames(dfpl)[1] <- "value"
  
  #Final graph
  pl <- ggplot(dfpl, aes(x = value, y = layer, fill = after_stat(x))) +
    geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
    scale_fill_viridis_c(option = option) 
  
  return(pl)
  
}

# Example (to be put in the manual):
# library(ggridges)
# library(terra)
# r <- im.import("greenland")
# im.ridgeplot(r, 2, "A") 
# + theme_bw()


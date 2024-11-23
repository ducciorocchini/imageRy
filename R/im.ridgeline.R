im.ridgeline <- function(im, scale, option) {

  #Checking inputs
  if(!is(im, "SpatRaster")) stop("im must be a SpatRaster")
  if(!is.numeric(scale)) stop("scale must be numeric")
  if(!is.character(option)) stop("ooption must be a character")
  if(!option %in% c("A", "B", "C", "D", "E", "F", "G", "H")) stop("option must be one of the color ooptions in the viris pachage (A,B,C,D,E,F,G,H)")

  #Transforming im in a dataframe
  df <- as.data.frame(im, wide = FALSE)

  #Final graph
  pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, fill = after_stat(x))) +
    ggridges::geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
    ggplot2::scale_fill_viridis_c(option = option)

  return(pl)
}

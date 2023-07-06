# Function to plot outputs with ggplot2 and vridis
# requires ggplot2 and viridis packages
im.ggplot <- function(m){
md <- as.data.frame(m, xy=T)
layer <- names(m)[[1]]
ggplot() + geom_raster(md, mapping = aes(x=x, y=y, fill=layer)) + scale_fill_viridis(option='viridis')
}

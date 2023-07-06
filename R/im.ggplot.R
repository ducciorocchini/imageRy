# Function to plot outputs with ggplot2 and vridis
# requires ggplot2 and viridis packages
im.ggplot <- function(m, layerfill){
md <- as.data.frame(m, xy=T)
ggplot() + geom_raster(md, mapping = aes(x=x, y=y, fill=layerfill)) + scale_fill_viridis(option='viridis')
}

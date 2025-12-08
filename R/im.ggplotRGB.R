# OPriginal code by:
# https://github.com/irisnanaobeng

## Enhanced ggplot-style imageRy function (im.ggplotRGB)
im.ggplotRGB <- function(rgb_stack, r = 1, g = 2, b = 3, 
                        stretch = "lin", title = "", downsample = 1) {
  
  # Downsample the raster first to reduce memory
  rgb_small <- aggregate(rgb_stack, fact = downsample)
  
  # Convert only the downsampled version to data frame
  rgb_df <- as.data.frame(rgb_small, xy = TRUE)
  rgb_df <- na.omit(rgb_df)
  
  band_names <- names(rgb_df)[3:5]
  
  # Create ggplot
  p <- ggplot() +
    geom_raster(data = rgb_df, 
                aes(x = x, y = y, 
                    fill = rgb(
                      get(band_names[r]), 
                      get(band_names[g]), 
                      get(band_names[b]),
                      maxColorValue = max(c(get(band_names[r]), 
                                          get(band_names[g]), 
                                          get(band_names[b])), na.rm = TRUE)
                    ))) +
    scale_fill_identity() +
    coord_equal() +
    labs(title = title) +
    # theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
          axis.text = element_text(size = 8),
          panel.grid = element_blank())
  
  return(p)
}

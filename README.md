# imageRy

Manipulate and share raster images in R.

## Rapid manual available!

> **Note**
[Rapid manual here](https://htmlpreview.github.io/?https://github.com/ducciorocchini/imageRy/blob/main/imageRy_rapid_manual.html)


## Packages needed

> **Warning**
> Packages needed to properly run imageRY:
+ library(terra)

## Ongoing

> Check greenland data import

> horizontal and vertical coloring in im.ridgeline() (optional)

<details>
<summary>R code click here </summary>
 
``` r
#' Generate Ridgeline Plots from Satellite Raster Data
#'
#' This function generates ridgeline plots from stacked satellite imagery data.
#'
#' @param im A `SpatRaster` object representing the raster data to be visualized.
#' @param scale A numeric value that defines the vertical scale of the ridgeline plot.
#' @param palette A character string specifying the `viridis` color palette option to use.
#' Available options: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, `"cividis"`, `"mako"`, `"rocket"`, `"turbo"`.
#'
#' @return A `ggplot` object displaying the ridgeline plot.
#'
#' @details
#' Ridgeline plots are useful for analyzing temporal variations in raster-based satellite imagery.
#' This function extracts raster values and visualizes their distribution across layers.
#'
#' @references
#' See also `im.import()`, `im.ggplot()`.
#'
#' @seealso [GitHub Repository](https://github.com/ducciorocchini/imageRy/)
#'
#' @examples
#' library(terra)
#' library(ggridges)
#' library(ggplot2)
#'
#' # Create a 5-layer raster
#' r <- rast(nrows = 10, ncols = 10, nlyrs = 5)
#' values(r) <- runif(ncell(r) * 5)
#'
#' # Generate ridgeline plot
#' im.ridgeline(r, scale = 2, palette = "viridis") + theme_minimal()
#' @export
im.ridgeline22 <- function(im, scale, dir = c("h", "v"), palette = c("viridis", "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo")) {
  
  palette <- palette[1]
  
  #Checking inputs
  if(!is(im, "SpatRaster")) stop("im must be a SpatRaster")
  if(!is.numeric(scale)) stop("scale must be numeric")
  if(!is.character(palette)) stop("palette must be a character")
  if(!palette %in% c("viridis", "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo")) stop("palette must be one of the color options in the viridis package (viridis, magma, plasma, inferno, cividis, mako, rocket, turbo)")
  if(!dir %in% c("h", "v")) stop("dir must be horizontal (h) or vertical (v)")
  
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
  if(dir == "h") {
    pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, fill = after_stat(x))) +
      ggridges::geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
      ggplot2::scale_fill_viridis_c(option = palette)
  } else {
    pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, fill = after_stat(y))) +
      ggridges::geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
      ggplot2::scale_fill_viridis_c(option = palette)
  }
  
  return(pl)
 
}
```
 </details>

> Fuzzy classification
``` r
im.fuzzyclass()
```

> Avoid alphabetical order and use elements
``` r 
im.ridgeline()
```

> In PCA, retain the whole set
``` r
im.pca()
```

> im.flip()
``` r
im.flip <- function(a){
a = flip(a)
plot(a)
return(a)
}
```

> im.export()

> im.ggplpotRGB()

> im.ggplot() # insert different color ramp palettes

## Secretized link:
https://anonymous.4open.science/r/imageRy-5083/README.md

## Ongoing in the CRAN version

+ insert import vignette
+ im.list() to list data from Zenodo
+ im.import() to import several layers
+ im.classify(): check output



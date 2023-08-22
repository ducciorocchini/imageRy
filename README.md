# imageRy

Manipulate and share raster images in R.
Original code by Duccio Rocchini, Giovanni Nocera, Ludovico Chieffallo, and Elisa Thouverai.

[Guide here](https://htmlpreview.github.io/?https://github.com/ducciorocchini/imageRy/blob/main/imageRy.html)
to be update with im.import()

[Data to be uploaded can be seen here](https://htmlpreview.github.io/?https://github.com/ducciorocchini/imageRy/blob/main/data/descxription.md)

> **Warning**
> Packages needed to properly run imageRY:
+ library(imageRy)
+ library(terra)
+ library(ggplot2)
+ library(viridis)
+ library(fields)

> **Note**
> How to import data without im.import()

# example:

devtools::install_github("ducciorocchini/imageRy")

library(terra)

mato <- system.file("images/matogrosso_ast_2006209_lrg.jpg", package="imageRy")

mato <- rast(mato)

plot(mato)

# directly import data with the im.import function: 

> **Warning** Things to be checked:
+ import of sentinel data and plotRGB
+ im.pca(): to be tested
+ im.dvi(): to be tested
+ im.ndvi(): to be tested
+ im.ggplot(): automatically import first layer, grey background
+ im.ggplotRGB(): grey background
+ im.import(): also import several layers via pattern=""
+ Manuals under implementation



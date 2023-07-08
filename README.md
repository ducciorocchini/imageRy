# imageRy

Manipulate and share raster images in R.
Original code by Duccio Rocchini, Giovanni Nocera, Ludovico Chieffallo, and Elisa Thouverai.

[Guide here](https://htmlpreview.github.io/?https://github.com/ducciorocchini/imageRy/blob/main/imageRy.html)

[Data to be uploaded can be seen here](https://htmlpreview.github.io/?https://github.com/ducciorocchini/imageRy/blob/main/data/descxription.md)

> **Note**
> How to import data without im.import()

> **Warning**
> Packages needed to properly run imageRY:
+ terra
+ ggplot2
+ fields
+ viridis

# example:

library(terra)

mato <- system.file("data/matogrosso_ast_2006209_lrg.jpg", package="imageRy")

mato <- rast(mato)

plot(mato)

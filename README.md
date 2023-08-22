# imageRy

Manipulate and share raster images in R.
Original code by Duccio Rocchini, Giovanni Nocera, Ludovico Chieffallo, and Elisa Thouverai.

## NEW: Rapid guide available!

> **Note**
[Rapid guide here](https://htmlpreview.github.io/?https://github.com/ducciorocchini/imageRy/blob/main/imageRy_rapid_manual.html)
to be update with im.import()

## Packages needed

> **Warning**
> Packages needed to properly run imageRY:
+ library(imageRy)
+ library(terra)
+ library(ggplot2)
+ library(viridis)
+ library(fields)

## Directly import data with the im.import function

im.list()

mato2 <- im.import("matogrosso_ast_2006209_lrg.jpg")

## Things we are checking

> **Warning** Things to be checked:
+ import of sentinel data and plotRGB
+ im.pca(): to be tested
+ im.dvi(): to be tested
+ im.ndvi(): to be tested
+ im.ggplot(): automatically import first layer, grey background
+ im.ggplotRGB(): grey background
+ im.import(): also import several layers via pattern=""
+ Manuals under implementation



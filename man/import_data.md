## import data

# example:

library(terra)

mato <- system.file("data/matogrosso_ast_2006209_lrg.jpg", package="imageRy")

mato <- rast(mato)

plot(mato)

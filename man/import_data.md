## import data

# example:

library(terra)

mato <- system.file("data/matogrosso_ast_2006209_lrg.jpg", package="imageRy")

mato

# [1] "/usr/local/lib/R/site-library/imageRy/data/matogrosso_ast_2006209_lrg.jpg"

mato <- rast(mato)

plot(mato)

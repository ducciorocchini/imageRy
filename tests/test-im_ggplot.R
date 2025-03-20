test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)
library(terra)
library(ggplot2)

test_that("im.ggplot correctly generates a ggplot object", {
  # Create a raster with two layers (simulating satellite bands)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 2)
  values(r) <- runif(200)  # Assign random values

  # Generate ggplot visualization
  ggplot_raster <- im.ggplot(r, layerfill = 1)

  # Ensure that the result is a ggplot object
  expect_s3_class(ggplot_raster, "ggplot")

  # Check that the plot contains a raster (geom_raster)
  plot_layers <- lapply(ggplot_raster$layers, function(layer) class(layer$geom)[1])
  expect_true("GeomRaster" %in% plot_layers)
})


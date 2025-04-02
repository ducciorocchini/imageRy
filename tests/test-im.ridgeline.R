test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

library(testthat)
library(imageRy)
library(terra)
library(ggplot2)
library(ggridges)

test_that("im.ridgeline generates a valid ridgeline plot", {
  # Create a raster with three bands (simulating a time series)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 3)
  values(r) <- runif(300)  # Assign random values to simulate image data

  # Generate ridgeline plot (correcting argument name)
  ridgeline_plot <- im.ridgeline(r, scale = 2, palette = "viridis")

  # Ensure that the result is a ggplot object
  expect_s3_class(ridgeline_plot, "ggplot")

  # Check that the plot contains a ridgeline element
  plot_layers <- lapply(ridgeline_plot$layers, function(layer) class(layer$geom)[1])
  expect_true("GeomDensityRidgesGradient" %in% plot_layers)
})


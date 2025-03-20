test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

library(testthat)
library(imageRy)
library(terra)

test_that("im.classify correctly performs k-means classification", {
  # Create a raster with three bands (simulating multispectral data)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 3)
  values(r) <- runif(300)  # Assign random values to simulate image data

  # Perform k-means classification with 3 clusters
  classified_raster <- im.classify(r, num_clusters = 3, seed = 42, do_plot = FALSE)

  # Expected number of unique classes (should be 3)
  unique_classes <- unique(values(classified_raster))

  # Check that classification produced exactly 3 unique classes
  expect_length(unique_classes, 3)

  # Ensure that the result is a `SpatRaster` (S4 class)
  expect_s4_class(classified_raster, "SpatRaster")
})

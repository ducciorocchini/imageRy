test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)
library(terra)

test_that("im.ndvi correctly computes NDVI values", {
  # Create a raster with two bands (NIR and Red)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 2)
  values(r) <- c(rep(0.8, 100), rep(0.2, 100))  # NIR = 0.8, Red = 0.2

  # Compute NDVI
  ndvi_result <- im.ndvi(r, nir = 1, red = 2)

  # Expected NDVI value for all pixels
  expected_ndvi <- (0.8 - 0.2) / (0.8 + 0.2)

  # Verify that all pixel values match the expected NDVI value
  expect_equal(as.numeric(values(ndvi_result)), rep(expected_ndvi, 100))
})


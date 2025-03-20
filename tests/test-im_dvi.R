test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

library(testthat)
library(imageRy)
library(terra)

test_that("im.dvi correctly computes the Difference Vegetation Index (DVI)", {
  # Create a raster with two bands (NIR and Red)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 2)
  values(r) <- c(rep(0.8, 100), rep(0.2, 100))  # NIR = 0.8, Red = 0.2

  # Compute DVI
  dvi_result <- im.dvi(r, nir = 1, red = 2)

  # Expected DVI value
  expected_dvi <- 0.8 - 0.2

  # Check that all pixels have the correct DVI value
  expect_equal(as.numeric(values(dvi_result)), rep(expected_dvi, 100))
})

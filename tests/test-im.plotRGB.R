test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)
library(terra)

test_that("im.plotRGB correctly plots an RGB image with specified bands", {
  # Create a raster with at least 3 bands (for RGB)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 3)
  values(r) <- runif(300)  # Assign random values

  # Expect the function to run without errors
  expect_silent(im.plotRGB(r, r = 1, g = 2, b = 3, title = "Test RGB Plot"))
})

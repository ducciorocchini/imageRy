test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

library(testthat)
library(imageRy)
library(terra)

test_that("im.pca correctly performs Principal Component Analysis (PCA)", {
  # Create a raster with three bands (simulating multispectral data)
  r <- rast(nrows = 10, ncols = 10, nlyrs = 3)
  values(r) <- runif(300)  # Assign random values to simulate image data

  # Perform PCA
  pca_result <- im.pca(r, n_samples = 100)

  # Ensure that the result is a `SpatRaster`
  expect_s4_class(pca_result, "SpatRaster")

  # Ensure that the number of layers in the result matches the number of input bands
  expect_equal(nlyr(pca_result), nlyr(r))

  # Check that the values are not NULL
  expect_false(any(is.na(values(pca_result))))
})

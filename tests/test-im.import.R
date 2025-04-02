test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)
library(terra)

test_that("im.import correctly loads a raster", {
  # List available images in the package
  available_images <- im.list()

  # Check that the function returns a valid list of images
  expect_type(available_images, "character")
  expect_true(length(available_images) > 0)

  # Pick the first available image (if any)
  if (length(available_images) > 0) {
    test_image <- available_images[3]

    # Try to import the image
    imported_raster <- im.import(test_image)

    # Ensure that the result is a SpatRaster object
    expect_s4_class(imported_raster, "SpatRaster")

    # Check that the raster has at least one layer
    expect_gte(nlyr(imported_raster), 1)
  }
})

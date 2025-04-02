test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)
library(terra)

test_that("im.export correctly saves a GeoTIFF", {
  r <- rast(nrows = 10, ncols = 10)
  values(r) <- runif(ncell(r))
  
  temp_file <- tempfile(fileext = ".tif")
  im.export(r, temp_file)
  
  expect_true(file.exists(temp_file))  # Check file was created
  # Load the saved raster
  exported_raster <- terra::rast(temp_file)
  
  # Ensure dimensions match
  expect_equal(dim(exported_raster), dim(r))
  
  # Compare pixel values instead of full object equality
  expect_equal(values(exported_raster), values(r), tolerance = 1e-5)  # Check raster is unchanged
})

test_that("im.export rejects invalid file extensions", {
  r <- rast(nrows = 10, ncols = 10)
  values(r) <- runif(ncell(r))
  
  expect_error(im.export(r, "output.txt"), "Unsupported file format")
})

test_that("im.export correctly saves a PNG", {
  r <- rast(nrows = 10, ncols = 10)
  values(r) <- runif(ncell(r))
  
  temp_file <- tempfile(fileext = ".png")
  im.export(r, temp_file)
  
  expect_true(file.exists(temp_file))  # PNG file exists
})

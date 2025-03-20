test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)
library(grDevices)

test_that("im.multiframe correctly sets up a multi-panel layout", {
  # Set up a multi-frame layout
  expect_silent(im.multiframe(2, 2))

  # Check if the graphical parameters have been set correctly
  par_settings <- par("mfrow")

  # Ensure the layout is correctly applied
  expect_equal(par_settings, c(2, 2))
})

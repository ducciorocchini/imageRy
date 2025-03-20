test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

library(testthat)
library(imageRy)

test_that("im.list correctly retrieves available images", {
  # Get the list of available images
  available_images <- im.list()

  # Ensure the result is a character vector
  expect_type(available_images, "character")

  # Ensure the list is not empty (assuming the package includes images)
  expect_true(length(available_images) > 0)
})

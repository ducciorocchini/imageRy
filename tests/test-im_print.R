test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)

test_that("im.print prints the expected message", {
  # Capture printed output
  output <- capture.output(im.print())

  # Expected message
  expect_true(any(grepl("I am imageRy", output)))
})

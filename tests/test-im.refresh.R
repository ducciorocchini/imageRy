test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
library(testthat)
library(imageRy)

test_that("im.refresh correctly runs without installing", {
  # Capture messages
  output <- capture_messages(im.refresh(dry_run = TRUE))

  # Clean output: rimuove spazi bianchi e caratteri di nuova riga
  output <- trimws(output)

  # Ensure the function executed correctly
  expect_true(any(grepl("^im.refresh\\(\\) executed$", output)))
})

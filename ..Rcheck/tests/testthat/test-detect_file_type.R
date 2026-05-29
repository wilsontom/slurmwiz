test_that("detect_file_type returns the most frequent extension", {
  input <- withr::local_tempdir()
  file.create(file.path(input, c("a.raw", "b.raw", "c.mzML")))

  expect_equal(slurmwiz::detect_file_type(input), "raw")
})

test_that("detect_file_type handles a single extension type", {
  input <- withr::local_tempdir()
  file.create(file.path(input, c("sample1.mzML", "sample2.mzML")))

  expect_equal(slurmwiz::detect_file_type(input), "mzML")
})

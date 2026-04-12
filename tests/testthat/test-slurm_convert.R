test_that("slurm_convert errors when the input directory is missing", {
  output <- withr::local_tempdir()

  expect_error(
    slurmwiz::slurm_convert(
      input = file.path(tempdir(), "missing-input"),
      output = output,
      format_out = "mzML",
      conversion_args = "peakPicking true 1-"
    ),
    "input directory does not exist"
  )
})

test_that("slurm_convert errors when the forbidden filter is supplied", {
  input <- withr::local_tempdir()
  output <- withr::local_tempdir()
  file.create(file.path(input, "sample.raw"))

  expect_error(
    slurmwiz::slurm_convert(
      input = input,
      output = output,
      format_out = "mzML",
      conversion_args = "peakPicking true -1"
    ),
    "Incorrect filter argument detected"
  )
})

test_that("slurm_convert creates output, writes script and submits the job", {
  input <- withr::local_tempdir()
  parent <- withr::local_tempdir()
  output <- file.path(parent, "converted")
  file.create(file.path(input, c("a.raw", "b.raw")))

  fake_script <- file.path(tempdir(), "fake-job.slurm")
  captured <- list(
    create = NULL,
    submit = NULL
  )

  local_mocked_bindings(
    read_system_params = function() {
      list(
        JOB_NAME = "test-job",
        IMAGE = "/images/pwiz.sif",
        TMPMYWINEPREFIX = "/tmp/wineprefix",
        TMPDIR = tempdir()
      )
    },
    create_slurm_script = function(slurm_preamble, singularity_command, tmp_dir) {
      captured$create <<- list(
        slurm_preamble = slurm_preamble,
        singularity_command = singularity_command,
        tmp_dir = tmp_dir
      )
      fake_script
    },
    submit_slurm_job = function(script_path) {
      captured$submit <<- script_path
      0
    },
    .package = "slurmwiz"
  )

  expect_message(
    result <- slurmwiz::slurm_convert(
      input = input,
      output = output,
      format_out = "mzML",
      conversion_args = c("peakPicking true 1-", "msLevel 1")
    ),
    "creating now"
  )

  expect_null(result)
  expect_true(dir.exists(output))
  expect_match(captured$create$slurm_preamble, "#SBATCH --job-name=test-job", fixed = TRUE)
  expect_match(captured$create$singularity_command, "/images/pwiz.sif mywine msconvert", fixed = TRUE)
  expect_match(captured$create$singularity_command, '--filter "peakPicking true 1-"', fixed = TRUE)
  expect_match(captured$create$singularity_command, '--filter "msLevel 1"', fixed = TRUE)
  expect_match(captured$create$singularity_command, "/data/*.raw -o /outpath", fixed = TRUE)
  expect_equal(captured$create$tmp_dir, tempdir())
  expect_equal(captured$submit, fake_script)
})

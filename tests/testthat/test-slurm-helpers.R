test_that("read_system_params returns expected config values", {
  params <- slurmwiz:::read_system_params()

  expect_named(
    params,
    c("JOB_NAME", "IMAGE", "TMPMYWINEPREFIX", "TMPDIR")
  )
  expect_equal(params$JOB_NAME, "msconvert")
})

test_that("validate_input_directory errors for a missing directory", {
  expect_error(
    slurmwiz:::validate_input_directory(file.path(tempdir(), "missing-input")),
    "input directory does not exist"
  )
})

test_that("validate_input_directory succeeds for an existing directory", {
  input <- withr::local_tempdir()

  expect_true(slurmwiz:::validate_input_directory(input))
})

test_that("ensure_output_directory creates a missing directory", {
  parent <- withr::local_tempdir()
  output <- file.path(parent, "converted")

  expect_message(
    expect_true(slurmwiz:::ensure_output_directory(output)),
    "creating now"
  )
  expect_true(dir.exists(output))
})

test_that("ensure_output_directory is silent when directory exists", {
  output <- withr::local_tempdir()

  expect_no_message(expect_true(slurmwiz:::ensure_output_directory(output)))
})

test_that("validate_conversion_args rejects the forbidden filter", {
  expect_error(
    slurmwiz:::validate_conversion_args("peakPicking true -1"),
    "Incorrect filter argument detected"
  )
})

test_that("validate_conversion_args accepts valid filters", {
  expect_true(
    slurmwiz:::validate_conversion_args(c("peakPicking true 1-", "msLevel 1"))
  )
})

test_that("format_conversion_args assembles the msconvert flags", {
  args <- slurmwiz:::format_conversion_args(
    format_out = "mzML",
    conversion_args = c("peakPicking true 1-", "msLevel 1")
  )

  expect_equal(
    args,
    paste0(
      " --ignoreUnknownInstrumentError  --mzML ",
      '--filter "peakPicking true 1-" --filter "msLevel 1"'
    )
  )
})

test_that("build_slurm_preamble includes the configured job name", {
  preamble <- slurmwiz:::build_slurm_preamble("demo-job")

  expect_match(preamble, "#!/bin/bash --login", fixed = TRUE)
  expect_match(preamble, "#SBATCH --job-name=demo-job", fixed = TRUE)
  expect_match(preamble, "module load apptainer", fixed = TRUE)
})

test_that("build_singularity_command includes all bound paths and arguments", {
  command <- slurmwiz:::build_singularity_command(
    input = "/data/in",
    output = "/data/out",
    tmp_my_wine_prefix = "/tmp/wine",
    image = "/images/pwiz.sif",
    conversion_args = ' --ignoreUnknownInstrumentError  --mzML --filter "peakPicking true 1-"',
    file_ext = "raw"
  )

  expect_match(command, "singularity exec --cleanenv -B /data/in:/data", fixed = TRUE)
  expect_match(command, "-B /data/out:/outpath", fixed = TRUE)
  expect_match(command, "-B /tmp/wine:/mywineprefix", fixed = TRUE)
  expect_match(command, "/images/pwiz.sif mywine msconvert", fixed = TRUE)
  expect_match(command, '--filter "peakPicking true 1-"', fixed = TRUE)
  expect_match(command, "/data/*.raw -o /outpath", fixed = TRUE)
})

test_that("create_slurm_script writes the expected content", {
  tmp_dir <- withr::local_tempdir()
  script_path <- slurmwiz:::create_slurm_script(
    slurm_preamble = "line-one",
    singularity_command = "line-two",
    tmp_dir = tmp_dir
  )

  expect_true(file.exists(script_path))
  expect_match(script_path, "\\.slurm$")
  expect_equal(readLines(script_path), c("line-one", "", "", "line-two"))
})

test_that("submit_slurm_job calls system with sbatch", {
  captured_command <- NULL

  local_mocked_bindings(
    run_system_command = function(cmd) {
      captured_command <<- cmd
      0
    },
    .package = "slurmwiz"
  )

  expect_equal(slurmwiz:::submit_slurm_job("/tmp/example.slurm"), 0)
  expect_equal(captured_command, "sbatch /tmp/example.slurm")
})

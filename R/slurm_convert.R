#' Convert Raw Files using msconvert and SLURM
#'
#' Convert raw mass spectrometry files using a combination of singularity, t
#'
#' @param input the absolute file path of the directory of raw files for conversion
#' @param output the absolute file path where converted data files will be saved to
#' @param format_out a character string of `msconvert` format for conversioin.
#' @param conversion_args a character string of `msconvert` arguments without the `--filter` prefix (ie, `peakPicking true 1-`)
#' @examples
#' \dontrun{
#' slurm_convert(input = 'hpc/storage/my_raw_data', output = 'hpc/home/my_converted_data', format_out = 'mzML', conversion_args = c('peakPicking true 1-'))
#' }
#' @export

read_system_params <- function() {
  yaml::read_yaml(
    system.file("extdata", "system_config_file.yml", package = "slurmwiz")
  )
}

validate_input_directory <- function(input) {
  if (!dir.exists(input)) {
    stop("input directory does not exist")
  }

  invisible(TRUE)
}

ensure_output_directory <- function(output) {
  if (!dir.exists(output)) {
    message("input directory does not exist......creating now")
    dir.create(output)
  }

  invisible(TRUE)
}

validate_conversion_args <- function(conversion_args) {
  if ("peakPicking true -1" %in% conversion_args) {
    stop("Incorrect filter argument detected")
  }

  invisible(TRUE)
}

format_conversion_args <- function(format_out, conversion_args) {
  output_string <- paste0(" --ignoreUnknownInstrumentError  --", format_out, " ")

  conversion_args_format <- vapply(
    conversion_args,
    function(x) {
      paste0('--filter "', x, '"')
    },
    character(1)
  )

  paste0(output_string, paste(conversion_args_format, collapse = " "))
}

build_slurm_preamble <- function(job_name) {
  glue::glue(
    "#!/bin/bash --login",
    "\n",
    "#SBATCH --account=hpcuser",
    "\n",
    "#SBATCH --job-name={job_name}",
    "\n",
    "#SBATCH --ntasks=1",
    "\n",
    "#SBATCH --partition=cpu",
    "\n",
    "#SBATCH --mem=20G",
    "\n",
    "#SBATCH --output=myScript.o%J",
    "\n",
    "#SBATCH --error=myScript.e%J",
    "\n",
    "\n",
    "\n",
    "module load apptainer"
  )
}

build_singularity_command <- function(input,
                                      output,
                                      tmp_my_wine_prefix,
                                      image,
                                      conversion_args,
                                      file_ext) {
  glue::glue(
    "singularity exec --cleanenv -B ",
    {
      input
    },
    ":/data -B ",
    {
      output
    },
    ":/outpath -B ",
    {
      tmp_my_wine_prefix
    },
    ":/mywineprefix --writable-tmpfs ",
    {
      image
    },
    " mywine msconvert",
    {
      conversion_args
    },
    " /data/*.",
    {
      file_ext
    },
    " -o /outpath"
  )
}

create_slurm_script <- function(slurm_preamble, singularity_command, tmp_dir) {
  tmpfilepath <- tempfile(tmpdir = tmp_dir, fileext = ".slurm")
  writeLines(c(slurm_preamble, "\n", singularity_command), tmpfilepath)
  tmpfilepath
}

run_system_command <- function(command) {
  system(command)
}

submit_slurm_job <- function(script_path) {
  run_system_command(glue::glue("sbatch {script_path}"))
}

slurm_convert <-
  function(input, output, format_out, conversion_args) {
    # Reading in the system config file that should have been edited before the package was built
    system_params <- read_system_params()

    validate_input_directory(input)
    ensure_output_directory(output)
    validate_conversion_args(conversion_args)

    file_ext <- detect_file_type(input)
    formatted_args <- format_conversion_args(format_out, conversion_args)
    slurm_preamble <- build_slurm_preamble(system_params$JOB_NAME)
    singularity_command <- build_singularity_command(
      input = input,
      output = output,
      tmp_my_wine_prefix = system_params$TMPMYWINEPREFIX,
      image = system_params$IMAGE,
      conversion_args = formatted_args,
      file_ext = file_ext
    )
    tmpfilepath <- create_slurm_script(
      slurm_preamble = slurm_preamble,
      singularity_command = singularity_command,
      tmp_dir = system_params$TMPDIR
    )

    submit_slurm_job(tmpfilepath)

    return(invisible(NULL))
  }

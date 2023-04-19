#' Convert Raw Files using msconvert and SLURM
#'
#' Convert raw mass spectrometry files using a combination of singularity, t
#'
#' @param data_in the absolute file path of the directory of raw files for conversion
#' @param save_path the absolute file path where converted data files will be saved to
#' @param file_ext the file extension of the raw files to convert (ie, `raw`, `lcd`, `wiff`)
#' @param conversion_args a character string of `msconvert` arguments (ie, `--filter peakPicking true 1-`)
#'#' @example
#' \dontrun{
#' slurm_convert(data_in = 'hpc/storage/my_raw_data', save_path = 'hpc/home/my_converted_data',
#' file_ext = 'raw', conversion_args = c('--filter peakPicking true 1-'))'
#' }
#'
#' @export


slurm_convert <-
  function(data_in,
           save_path,
           file_ext,
           conversion_args) {
    # Reading in the system config file that should have been edited before the package was built
    system_params <-
      yaml::read_yaml(system.file('extdata', 'system_config_file.yml', package = 'slurmwiz'))

    list2env(system_params, globalenv())



    if (!dir.exists(data_in)) {
      stop('data_in directory does not exist')
    }

    slurm_preamble <- glue::glue(
      '#!/bin/bash --login',
      '\n',
      '#SBATCH --account=hpcuser',
      '\n',
      '#SBATCH --job-name={JOB_NAME}',
      '\n',
      '#SBATCH --ntasks=1',
      '\n',
      '#SBATCH --partition=amd,intel',
      '\n',
      '#SBATCH --mem=10G',
      '\n',
      '#SBATCH --output=myScript.o%J',
      '\n',
      '#SBATCH --error=myScript.e%J',
      '\n',
      '\n',
      '\n',
      'module load apptainer'
    )


    singularity_command <- glue::glue(
      'singularity exec --cleanenv -B',
      {
        data_in
      },
      ':/data -B',
      {
        save_path
      },
      ':/outpath -B',
      {
        TMPMYWINEPREFIX
      },
      ':/mywineprefix --writable-tmpfs',
      {
        IMAGE
      },
      'mywine msconvert',
      {
        conversion_args
      },
      '/data/*.',
      {
        file_ext
      },
      '-o /outpath'
    )


    tmpfilepath <- tempfile(tmpdir = TMPDIR, fileext = '.slurm')

    writeLines(c(slurm_preamble, '\n', singularity_command),
               tmpfilepath)

    system(glue::glue('sbatch {tmpfilepath}'))


    return(invisible(NULL))


  }

# slurmwiz

[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) ![License](https://img.shields.io/badge/license-GNU%20GPL%20v3.0-blue.svg "GNU GPL v3.0")


### Getting Started

Before installing the `slurmwiz` R package, the pwiz singularity sandbox needs creating. To do this, you need to be using a linux filesystem which has `docker` and `singularity` installed. 

```sh
singularity build --sandbox pwiz_sandbox docker://chambm/pwiz-skyline-i-agree-to-the-vendor-licenses
```

Run the following command to make sure that the sandbox is working coorrectly

```sh
singularity exec -w pwiz_sandbox wine msconvert 
```

The sandbox than then be archived, transfered onto your HPC.

```sh
tar --create --file pwiz_sandbox.tar pwiz_sandbox 
scp pwiz_sandbox.tar user@hpc
```

### Converting Files

Load the `slurmwiz` library and run the `slurm_convert` function to submit your msconvert job to the SLURM workload manager.

```r
library(slurmwiz)

slurm_convert(data_in = '/scratch/my_raw_files', save_path = '/scratch/my_mzml_data', file_ext = 'raw', conversion_args = NULL)

```





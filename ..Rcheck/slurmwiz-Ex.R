pkgname <- "slurmwiz"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('slurmwiz')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("slurm_convert")
### * slurm_convert

flush(stderr()); flush(stdout())

### Name: slurm_convert
### Title: Convert Raw Files using msconvert and SLURM
### Aliases: slurm_convert

### ** Examples

## Not run: 
##D slurm_convert(input = 'hpc/storage/my_raw_data', output = 'hpc/home/my_converted_data', format_out = 'mzML', conversion_args = c('peakPicking true 1-'))
## End(Not run)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')

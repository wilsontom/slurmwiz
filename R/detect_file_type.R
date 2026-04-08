#' Detect File Type
#'
#' Detect the main file type in a directory of raw files
#'
#' @param input the absolute file path of the directory of raw files for conversion
#' @return a character string of the file type for conversion
#'
#' @export

detect_file_type <- function(input)
{
  file_extensions <- tools::file_ext(list.files(input))

  file_extensions_count <- table(file_extensions)

  freq_max <- names(file_extensions_count[which.max(file_extensions_count)])


  return(freq_max)


}

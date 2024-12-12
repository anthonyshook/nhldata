
#' Any code used to help basic parsing can go here.

# Replace NULLS with NA in lists, helps with forming
replace_null_in_list <- function(x) {
  x <- purrr::map(x, ~ replace(.x, is.null(.x), NA))
  purrr::map(x, ~ if(is.list(.x)) {replace_null_in_list(.x)} else {.x})
}

# Convert 00:00 time to seconds
convert_clock_to_seconds <- function(clocktime) {
  splittime <- strsplit(clocktime,':')
  new_times <- sapply(lapply(splittime, 'as.numeric'), function(st){st[1] * 60 + st[2]})
  return(new_times)
}

# NA if NULL (JUST TO HAVE SHAPE IN CONVERSION)
null_to_na <- function(x) {
  data.table::fifelse(is.null(x), NA, x)
}

null_to_na_2 <- function(x) {
  if (is.null(x)) {NA} else {x}
}

is_empty_list <- function(x) {
  class(x)[1] == 'list' && length(x)==0
}

extract_numerator <- function(x) {
  split_x <- strsplit(x, '/')
  values <- sapply(lapply(split_x, 'as.numeric'), function(st){st[1]})
  return(values)
}

extract_denominator <- function(x) {
  split_x <- strsplit(x, '/')
  values <- sapply(lapply(split_x, 'as.numeric'), function(st){st[2]})
  return(values)
}

parse_situtation_code <- function(sitcode, periodType, eventOwnerId) {
  # code is [away skater count][home goalie count][home goalie count][home skater count]

  # Couple of obvious cases
  if (sitcode == '1551') {
    return('ev')
  } else if (sitcode %in% c('0101', '1010')) {
    if (periodType == 'SO') {return('shootout')} else {return('penalty_shot')}
  }
  # Split the values for parsing
  ag <- as.numeric(substr(sitcode, 1, 1))
  as <- as.numeric(substr(sitcode, 2, 2))
  hs <- as.numeric(substr(sitcode, 3, 3))
  hg <- as.numeric(substr(sitcode, 4, 4))


}

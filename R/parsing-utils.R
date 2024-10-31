
#' Any code used to help basic parsing can go here.

# Replace NULLS with NA in lists, helps with forming
replace_null_in_list <- function(x) {
  x <- purrr::map(x, ~ replace(.x, is.null(.x), NA))
  purrr::map(x, ~ if(is.list(.x)) {replace_null_in_list(.x)} else {.x})
}

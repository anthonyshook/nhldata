#' Apply a feature mask
#'
#' @param mask_names A Vector of mask names to apply
#' @param dat The data set to apply them to.
#'
#' @description Internal function. Applies a 'mask' to a table to ensure it has
#' the appropriate column values, in an effort to avoid explosions.
#' How this works is that it rbinds the mask and the dat, with fill = TRUE,
#' then removes the masked row, leaving only the original data, plus whatever columns were missing
#' but expected, behind and with NA
#'
#' @keywords internal
apply_mask <- function(mask_names, dat) {

  datcopy <- data.table::copy(dat)
  # Takes the vector, makes a list, adds names...
  stupid_mask <- as.list(rep(NA, length(mask_names)))
  names(stupid_mask) <- mask_names

  # bind it, then get rid of the empty row
  datcopy <- data.table::rbindlist(list(stupid_mask, datcopy), fill = TRUE)
  datcopy <- datcopy[-1, ]

  return(datcopy)

}

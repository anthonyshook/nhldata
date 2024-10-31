#' Fetch the draft data
#'
#' @param year Draft Year - If not provided, it will just return every draft ever
#'
#' @details Automatically grabs all historical draft data back to the 1960s.
#'
#' @export
fetch_draft_data <- function(year = NULL) {

  if (is.null(year)) {
    draft_api <- draft_api
  } else {
    draft_api <- draft_api |> paste0('?cayenneExp=draftYear={YEAR}') |> format_uri(list(YEAR=year))
  }
  draft_data <- draft_api |> get_api_call()

  return(draft_data$data)

}


#' Convert Draft data into a table
#' @param dd draft data from `fetch_draft_data()`
parse_draft_data <- function(dd) {
  tbl <- data.table::rbindlist(lapply(dd, function(z) {data.frame(t(unlist(z)))}), fill=T)
  tbl <- tbl[order(draftYear, as.numeric(overallPickNumber))]
  return(tbl)
}

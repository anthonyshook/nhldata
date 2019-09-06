#' Update schedule table
#'
#' @param dat A data set for updating. Can be NULL.
#' @param conn a DB connection (required)
#' @param ... additional arguments passed to 'build_schedule_table'
#'
#' @export
update_schedule_table <- function(dat = NULL, conn, ...) {

  table_name <- 'schedule'
  wherecol   <- 'gameid'

  # If dat is NULL, grab some data
  if (is.null(dat)) {
    dat <- fetch_schedule(...)
  }

  # Upsert time
  dbx::dbxUpsert(conn = conn, table = table_name, records = dat, where_cols = wherecol)

  return(TRUE)

}

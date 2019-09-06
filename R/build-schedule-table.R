#' Build schedule table
#'
#' @param seasons A vector of seasons (format: 20182019)
#' @param conn A connection to a database - defaults to creating a new one
#' @param return_vals Logical. If true, the tables are returned
#'
#' @description The internals here are hard-coded, as this is not meant to be
#' something used outside of the current process, at the moment.
#' In the future, perhaps something config-based could be created
#' This is meant to create the table brand new, not update it. If the table already
#' exists, it will be re-written by running this function.
#'
#' @export
#'
build_schedule_table <- function(seasons, conn = connect_to_db(), return_vals = FALSE) {

  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Fetch the schedules
  infotbls <- lapply(seasons, fetch_schedule)

  # combine
  infotbls <- data.table::rbindlist(infotbls, fill = TRUE)

  # Write out to table, based on conn
  tbl_name <- "schedule"
  DBI::dbWriteTable(conn, tbl_name, infotbls, overwrite = TRUE, row.names = FALSE)

  # add an index
  statement <- "CREATE UNIQUE INDEX schedIndex ON schedule(gameid);"
  DBI::dbExecute(conn, statement)

  if (return_vals){
    return(infotbls)
  } else {
    return(invisible(TRUE))
  }
}

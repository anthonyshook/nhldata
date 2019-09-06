#' Build prospects table
#'
#' @param conn A connection to a database - defaults to creating a new one
#'
#' @description The internals here are hard-coded, as this is not meant to be
#' something used outside of the current process, at the moment.
#' In the future, perhaps something config-based could be created
#' This is meant to create the table brand new, not update it. If the table already
#' exists, it will be re-written by running this function.
#'
#' @export
#'
build_prospects_table <- function(conn = connect_to_db()) {

  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Fetch the prospect data
  prospies <- fetch_prospect_info()

  # Write out to tables, based on conn
  DBI::dbWriteTable(conn = conn, name = "current_prospects", prospies, overwrite = TRUE, row.names = FALSE)

  # Add an index
  statement <- "CREATE UNIQUE INDEX prospectIndex ON current_prospects(prospectid);"
  DBI::dbExecute(conn, statement)

  return(invisible(TRUE))
}

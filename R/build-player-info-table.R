#' Build player_info table
#'
#' @param playerIDs a vector of playerIDs to process and add to the database
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
build_player_info_table <- function(playerIDs, conn = connect_to_db()) {

  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Fetch the player info
  infotbls <- lapply(playerIDs, fetch_player_info)

  # combine
  infotbls <- data.table::rbindlist(infotbls, fill = TRUE)

  # Write out to table, based on conn
  tbl_name <- "players"
  DBI::dbWriteTable(conn, tbl_name, infotbls, overwrite = TRUE, row.names = FALSE)

  # For the players table, add an index
  statement <- "CREATE UNIQUE INDEX playerIndex ON players(playerid);"
  DBI::dbExecute(conn, statement)

}

#' Build teams tables
#'
#' @param seasons A vector of seasons (format: 20182019)
#' @param return_playerids If TRUE, will return all the player IDs (Default = True)
#' @param conn A connection to a database - defaults to creating a new one
#'
#' @description The internals here are hard-coded, as this is not meant to be
#' something used outside of the current process, at the moment.
#' In the future, perhaps something config-based could be created
#' This is meant to create the table brand new, not update it. If the table already
#' exists, it will be re-written by running this function.
#' Builds Roster and Teams tables
#'
#' @export
#'
build_teams_tables <- function(seasons, conn = connect_to_db()) {

  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Fetch the team info
  infotbls <- lapply(seasons, fetch_team_data)

  # combine
  teams   <- data.table::rbindlist(lapply(infotbls, '[[', 'team'), fill = TRUE)
  rosters <- data.table::rbindlist(lapply(infotbls, '[[', 'roster'), fill = TRUE)

  # Write out to tables, based on conn
  DBI::dbWriteTable(conn = conn, name = "teams", teams, overwrite = TRUE, row.names = FALSE)
  DBI::dbWriteTable(conn = conn, name = "rosters", rosters, overwrite = TRUE, row.names = FALSE)

  # Add indeces
  statement <- list("CREATE UNIQUE INDEX teamIndex ON teams(teamid);",
                    "CREATE INDEX rosterIndex ON rosters(playerid);",
                    "CREATE INDEX rosterTeamIndex ON rosters(teamid);")
  lapply(statement, DBI::dbExecute, conn = conn)

  return(invisible(TRUE))
}

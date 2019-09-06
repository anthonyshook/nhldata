#' Build player_info table
#'
#' @param gameIDs a vector of gameIDs to process and add to the database
#' @param conn A connection to a database - defaults to creating a new one
#' @param return_vals Logical. If true, the tables are returned
#' @param num_cores Number of cores to use - defaults to 1.
#'
#' @description The internals here are hard-coded, as this is not meant to be
#' something used outside of the current process, at the moment.
#' In the future, perhaps something config-based could be created
#' This is meant to create the table brand new, not update it. If the table already
#' exists, it will be re-written by running this function.
#'
#' @export
#'
build_boxscore_tables <- function(gameIDs, conn = connect_to_db(), return_vals = FALSE, num_cores = 1) {

  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Fetch the game info
  if (num_cores == 1) {
    infotbls <- lapply(gameIDs, fetch_boxscore_stats)
  } else if (num_cores > 1) {
    cl <- parallel::makeCluster(num_cores)
    parallel::clusterExport(cl = cl, varlist = ls(name = 'package:nhldata'),
                            envir = environment())
    infotbls <- parallel::parLapply(cl = cl, X = gameIDs, fetch_boxscore_stats)
    parallel::stopCluster(cl)
  } else {
    stop("num_cores cannot be negative")
  }

  # combine
  team_table   <- data.table::rbindlist(lapply(infotbls, '[[', 'team_stats'), fill = TRUE)
  skater_table <- data.table::rbindlist(lapply(infotbls, '[[', 'skater_stats'), fill = TRUE)
  goalie_table <- data.table::rbindlist(lapply(infotbls, '[[', 'goalie_stats'), fill = TRUE)

  # Write out to tables, based on conn
  DBI::dbWriteTable(conn, "team_games", team_table, overwrite = TRUE, row.names = FALSE)
  DBI::dbWriteTable(conn, "skater_games", skater_table, overwrite = TRUE, row.names = FALSE)
  DBI::dbWriteTable(conn, "goalie_games", goalie_table, overwrite = TRUE, row.names = FALSE)

  # Create Indeces
  statements <- list("CREATE UNIQUE INDEX bsTeamIndex ON team_games(gameid, teamid);",
                     "CREATE UNIQUE INDEX bsSkaterIndex ON skater_games(playerid, gameid);",
                     "CREATE UNIQUE INDEX bsGoalieIndex ON goalie_games(playerid, gameid);")

  # apply statements
  lapply(statements, DBI::dbExecute, conn = conn)

  # Return values if necessary
  if (return_vals) {
    return(list(team_table = team_table,
                skater_table = skater_table,
                goalie_table = goalie_table))
  } else {
    return(invisible(TRUE))
  }

}

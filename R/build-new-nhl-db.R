#' Function to build NHL database from scratch
#'
#' @param seasons Which seasons to build
#' @param dbname A Database name to put the tables.
#' @param schema A schema within that database to put the tables.
#' @param num_cores The number of cores, if choosing to parallelize (default = 1)
#' @param conn String, takes value 'sqlite' or -- a default one is generated if not provided.  Defaults to 'postgres'
#'
#' @description This is a wrapper for the ordered running of a specific set of functions
#' aimed at generating a brand new database.
#' However!  That database and schema need to _already_ exist, or this will fail (or will it?).
#'
#' @export
#'
build_new_nhl_db <- function(seasons,
                             dbname = "hockey",
                             schema = "nhl",
                             num_cores = 1,
                             conn = connect_to_db()) {

  # On.exit call
  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )


  start_time <- Sys.time()

  ## Schedules first!
  message(Sys.time(), " -- Building Schedule Table")
  sch_res <- build_schedule_table(seasons = seasons, conn = conn, return_vals = TRUE)
  gameIDs <- unique(sch_res[detailed_state=="Final"]$gameid)

  # From here, Boxscore Stats
  message(Sys.time(), " -- Building Boxscore Tables")
  bs_res  <- build_boxscore_tables(gameIDs = gameIDs, conn = conn, return_vals = TRUE, num_cores = num_cores)

  # Now we have gameIDs, and PlayerIDs
  playerIDs <- unique(c(bs_res$skater_table$playerid, bs_res$goalie_table$playerid))

  # Here comes the long-pole -- play by play data
  # Game IDs
  message(Sys.time(), " -- Building Play by Play tables")
  build_plays_table(gameIDs = gameIDs, conn = conn, num_cores = num_cores)

  # Let's get some player info
  message(Sys.time(), " -- Building Player Info")
  build_player_info_table(playerIDs, conn = conn)

  # Add the current team data
  message(Sys.time(), " -- Building Team and Roster Tables")
  highest_season <- max(sch_res$season)
  build_teams_tables(seasons = highest_season, conn = conn)

  # Add the Draft Table
  message(Sys.time(), " -- Building Historical Draft Table")
  build_draft_results(conn = conn)

  # Add the Prospects table
  message(Sys.time(), " -- Building Prospect Table")
  build_prospects_table(conn = conn)

  # Final
  message("Finished!  Total Elapsed Time: ", round(difftime(Sys.time(), start_time, units = "sec"), 2), " seconds")

  return(TRUE)

}

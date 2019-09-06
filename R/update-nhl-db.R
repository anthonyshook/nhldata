#' Update the existing tables
#'
#' @param look_back_days The number of days to look backwards for updating (Default = 3)
#' @param conn A database connection (one is created if not provided)
#'
#' @description We are going to try to use the dbx package to do an upsert.
#' We can grab all the data we need for the last three days (assuming any gameIDs exist in that time period, otherwise exit gracefully)
#' pull all the data in, and upsert into the appropriate tables.
#' This way, data in the last three days will be updated, and new data will be added.
#'
#' we can rely upon a staging process where we get the GAMEIDs that have completed since the last time we ran, OR
#' Just go back three days from today, get all the gameIDs that could have happened, run those, and upsert.
#' No need to bother seeing what is or isn't "done."
#'
#' @export
#'
update_nhl_database <- function(look_back_days = 3, conn = connect_to_db()) {

  # On.exit call
  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Set timer
  start_time <- Sys.time()

  # It's very fast to just update the schedule table,
  # First, let's just go ahead and fetch that data
  schedule <- fetch_schedule(start_date = Sys.Date() - look_back_days, end_date = Sys.Date())

  # Check if we even found anything
  if (nrow(schedule) == 0) {
    message("No games to process, thank you!")
    return(TRUE)
  }

  # Get game IDs
  gameIDs <- schedule$gameid

  # From here, we start the UPDATE process ()
  # With the gameIDs, we update
  ## THINGS WE'RE UPSERTING
  # schedule
  message(Sys.time(), " -- Updating the schedule table")
  update_schedule_table(dat = schedule, conn = conn)

  # boxscores
  message(Sys.time(), " -- Updating Boxscore tables (team_games, skater_games, goalie_games)")
  update_boxscore_tables(conn = conn, gameIDs = gameIDs)

  # play by play
  message(Sys.time(), " -- Updating play-by-play tables")
  update_plays_tables(conn = conn, gameIDs = gameIDs)

  # player info
  message(Sys.time(), " -- Updating Player info table")
  update_player_info_table(conn = conn, gameIDs = gameIDs)

  ## THINGS WE'RE JUST REMAKING
  # Update current team data
  message(Sys.time(), " -- Updating Team and Roster Tables (rebuild)")
  highest_season <- max(schedule$season)
  build_teams_tables(seasons = highest_season, conn = conn)

  # Update the Draft Table
  message(Sys.time(), " -- Updating Historical Draft Table (rebuild)")
  build_draft_results(conn = conn)

  # Update the Prospects table
  message(Sys.time(), " -- Updating Prospect Table (rebuild)")
  build_prospects_table(conn = conn)

  # Final
  message("Finished!  Total Elapsed Time: ", round(difftime(Sys.time(), start_time, units = "sec"), 2), " seconds")

  return(TRUE)

}

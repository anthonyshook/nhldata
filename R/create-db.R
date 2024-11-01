#' Create Database from Archive
#'
#' @param archive_path Path to existing data archive
#' @param database_connection Connection to Database
#' @param local_path If no database connection is passed, we'll build a local one in 'csv' format in this path
#'
#' @description
#' This function uses a data archive, built using `archive_data` function
#' calls and NHL API calls, to generate a relational database.  That means
#' the database will contain as many years as are present in your data
#' archive path. It also means the database building process involves a clean build every
#' time, not incremental. So, to update the database, you first update the
#' archive, then run this script again.
#'
#' @export
create_db_from_archive <- function(archive_path, database_connection=NULL, local_path='.') {
  # If no Database, then make a spot for local and set flag to TRUE
  if (is.null(database_connection)) {
    dir.create(paste(local_path,'/nhl_db/'), showWarnings = FALSE)
    LOCAL_ONLY <- TRUE
  } else {
    LOCAL_ONLY <- FALSE
  }

  ### Get a full list of every file.
  flist <- list.files(archive_path, full.names = TRUE, recursive = TRUE)
  # individual file types for parsing.
  pbp_list <- grep('*play-by-play.json', flist, value=TRUE)
  box_list <- grep('*boxscore.json', flist, value=TRUE)
  game_summary_list <- grep('*-summary.json', flist, value=TRUE)
  roster_list <- grep('*-roster.json', flist, value=TRUE)
  draft_list  <- grep('draft-data.json', flist, value=TRUE)
  player_list <- grep('all_players.csv', flist, value=TRUE)


  ##### Here are the tables we want -- consider changing some names...
  ### Parsed from Raw
  # draft_results
  # historical_rosters (this will only kind of work, as we won't be storing rosters by date; might need to be calculated)
  # rosters (these are just current - we could pull them )
  # plays
  # players (sort of, we want to add draft data)
  # schedule
  # teams

  # Play-by-Play



  ### Calculated, or parsed from pbp (less immediately necessary)
  # assists
  # blocked_shots
  # current_prospects
  # faceoffs
  # franchises (just a simple API call)
  # giveaways
  # goalie_games
  # goals
  # hits
  # missed_shots
  # penalties
  # shootout_results
  # shots
  # skater_games (note, this is like, game-level stat lines, pulled from landing data)
  # takeaways
  # team_games


}

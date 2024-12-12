#' Process Archive ()
#'
#' @param archive_path Path to existing data archive
#' @param process_path Where to save the processed data (defaults to subfolder in archive_path)
#'
#' @description
#' This function uses a data archive, built using `archive_data` function
#' calls and NHL API calls, to create a set of files (current in CSV) that
#' can easily be converted into a relational database of your choosing. It is run
#' at the SEASON level (so, archive/20242025/ as an example)
#'
#' @export
process_archive <- function(archive_path, process_path=NULL) {

  # Try to see if this is an actual archive
  # benefit of a state file
  if (file.exists(paste0(archive_path,'/state.json'))) {
    state <- jsonlite::read_json(paste0(archive_path,'/state.json'))
    if (state$status != 'SUCCESS'){
      stop('Something appears to be wrong with the data archive!')
    }
  } else {
    stop(paste(archive_path,'- does not appear to be an NHLDATA season-level data archive.'))
  }

  ## Create space for processed data
  if (is.null(process_path)) {
    process_path <- paste0(archive_path, '/processed_data/')
  }

  # Create directory
  dir.create(process_path, showWarnings = FALSE)

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
  #x plays
  # draft_results [[we don't have to do this here, it's actually better to do it later]]
  # historical_rosters (this will only kind of work, as we won't be storing rosters by date; might need to be calculated)

  # rosters (these are just current - we could pull them?  or we could pull from the game-summary/boxscore kind of data)
  # players (sort of, we want to add draft data) [[but only sort of doable later]]

  # schedule
  # teams



  # Play-by-Play
  pb_pbp <- progress_bar$new(
    format = "> Processing Play-by-Play [:bar] :current/:total :percent (eta: :eta) ",
    clear = FALSE,
    total = length(pbp_list),
    width = 150)

  # pb_pbp$message('Test Message')
  pbp_parsed <- lapply(pbp_list, function(Z) {
    pb_pbp$tick()
    parse_pbp_json(Z)
  })
  pbp_combined <- data.table::rbindlist(pbp_parsed, fill=TRUE, use.names = TRUE)[order(gameId, sortOrder)]
  pbp_cleaned <- clean_pbp_data(pbp_combined)

  # Getting individual events from PBP
  list_of_events <- list(goals = 'goal',
                         shots_on_goal = 'shot-on-goal',
                         missed_shots = 'missed-shot',
                         blocked_shots = 'blocked-shot',
                         faceoffs = 'faceoff',
                         hits = 'hit',
                         giveaways = 'giveaway',
                         takeaways = 'takeaway',
                         penalties = 'penalty')
  split_events <- list()
  for (evnt in names(list_of_events)) {
    split_events[[evnt]] <- split_pbp_data(pbp_cleaned, list_of_events[[evnt]])
  }

  # pull assists specifically from goals, just to be clear
  # Assist has a smaller column size, in this case, just to make life simpler and less likely to explode
  split_events[['assist']] <- split_events$goal[, list(gameId, eventId, periodNumber, periodType, assist1PlayerId, assist2PlayerId)]

  # The PBP will help us get all the intermediary ones, but also, we should clean up the table
  # by saving only critical columns, and removing the 'details' prefix

  browser()
  # Game Level Box Score Data
  pb_box <- progress_bar$new(
    format = "> Processing Box-Scores [:bar] :current/:total :percent (eta: :eta) ",
    clear = FALSE,
    total = length(box_list),
    width = 150)

  box_parsed <- lapply(box_list, function(Z) {
    pb_box$tick()
    parse_boxscore_json(Z)
  })
  skaters_combined <- data.table::rbindlist(lapply(box_parsed,'[[','skaters'), fill=TRUE, use.names = TRUE)
  goalies_combined <- data.table::rbindlist(lapply(box_parsed,'[[','goalies'), fill=TRUE, use.names = TRUE)

  ## Game Level Penalty and Team Level data
  # note - also a good place to pull game-roster data, if we want it, but maybe isn't necessary
  browser()


  ### Calculated, or parsed from pbp (less immediately necessary)
  #x  assists
  #x  blocked_shots
  #x  faceoffs
  #x  giveaways
  #x  goals
  #x  hits
  #x  missed_shots
  #x  penalties
  #x shots
  #x takeaways

  # current_prospects
  # x goalie_games
  # x skater_games (note, this is like, game-level stat lines, pulled from landing data)
  # franchises (just a simple API call)
  # team_games
  # shootout_results ??


}

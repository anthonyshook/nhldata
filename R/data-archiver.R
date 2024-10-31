#' Create or maintain a data archive structure
#'
#' @param path Where to generate the data archive
#' @param season Which season to generate data for (e.g., 20242025)
#' @param clean_build Whether to create or overwrite existing data, defaults to FALSE
#' @param verbose Get chatty? Defaults to TRUE
#'
#' @description
#' This function will generate a set of season-level data, in CSV and JSON format
#' This will include things like teams, franchises, boxscores, play-by-play data, and rosters
#'
#' @export
archive_data <- function(path, season, clean_build=FALSE, verbose=TRUE) {

  # create the tree structure to start with
  if (verbose) futile.logger::flog.info('> Building Archive Structure')
  BOXSCORE_PATH  <- paste0(path,'/', season, '/boxscores/')
  GAME_DATA_PATH <- paste0(path,'/', season, '/game-summary/')
  PBP_PATH       <- paste0(path,'/', season, '/play-by-play/')
  ROSTER_PATH    <- paste0(path,'/', season, '/rosters/')
  SHIFT_PATH     <- paste0(path,'/', season, '/shifts/')

  dir.create(path = BOXSCORE_PATH, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = GAME_DATA_PATH, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = PBP_PATH, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = ROSTER_PATH, showWarnings = FALSE, recursive = TRUE)
  # dir.create(path = SHIFT_PATH, showWarnings = FALSE, recursive = TRUE) -- not currently supporting shifts

  # Get the Game IDs
  if (verbose) futile.logger::flog.info('> Fetching Game IDs (Simple)')
  games <- fetch_game_ids(season=season, season_type = 2)
  playoff_games <- fetch_game_ids(season=season, season_type = 3)

  if (nrow(playoff_games) > 0) {
    # Remove un-completed games (i.e., scheduled, but not played because it wasn't necessary)
    playoff_games <- playoff_games[gameStateId == 7]
    games <- rbind(games, playoff_games)
  }

  # Get rid of games that haven't been played yet.
  # simply by date, for now
  games <- games[gameDate < Sys.Date()]

  # Write gameIDs to file
  data.table::fwrite(games, paste0(path,'/', season, '/game_ids.csv'))

  # TODO -- add functionality to remove the games already processed, if clean_build isn't true
  # we could probably generate a state document, for now we just manually check.
  complete_ids <- check_state(paste0(path, '/', season, '/'))
  games <- games[!(id %in% complete_ids)]

  ### BOXSCORES AND PLAY-BY-PLAY
  if (nrow(games) == 0) {
    futile.logger::flog.info('> No New Games to Process!  Moving on to Rosters')
  } else {
    futile.logger::flog.info(paste0('> Found ', nrow(games), ' Games to Process'))
    if (verbose) futile.logger::flog.info('> Getting BoxScore, Game-Level, and Play-by-Play Data')
    pb <- progress_bar$new(
      format = "> Processing Game-Id :gm [:bar] :current/:total :percent (eta: :eta) :what ",
      clear = FALSE,
      total = nrow(games),
      width = 150)

    for (GM in games$id) {
      # Generate File Names first -- that way we can check for them
      box_fname   <- paste0(BOXSCORE_PATH, GM, '-boxscore.json')
      pbp_fname   <- paste0(PBP_PATH, GM, '-play-by-play.json')
      gs_fname    <- paste0(GAME_DATA_PATH, GM, '-summary.json')
      shift_fname <- paste0(SHIFT_PATH, GM, '-shift.json')

      # Boxscore
      if (file.exists(box_fname) && !clean_build) {
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Existing Boxscore Found     '))
        Sys.sleep(.001)
      } else {
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Fetching Boxscore           '))
        boxscore <- fetch_boxscores(GM, verbose=FALSE)
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Writing Boxscore to JSON    '))
        jsonlite::write_json(boxscore[[1]], box_fname, auto_unbox=TRUE, pretty=TRUE)
      }

      # PBP
      if (file.exists(pbp_fname) && !clean_build) {
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Existing Play-by-Play Found '))
        Sys.sleep(.001)
      } else {
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Fetching play-by-play       '))
        pbp_data <- fetch_play_by_play(GM, verbose=F)
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Writing play-by-play to JSON'))
        jsonlite::write_json(pbp_data[[1]], pbp_fname, auto_unbox=TRUE, pretty=TRUE)
      }

      # Game Summaries
      if (file.exists(gs_fname) && !clean_build) {
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Existing Game Summary Found '))
        Sys.sleep(.001)
      } else {
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Fetching Game Summary       '))
        gs_data <- fetch_game_data(GM, verbose=F)
        if (verbose) pb$tick(0, tokens=list(gm=GM, what='Writing Game Summary to JSON'))
        jsonlite::write_json(gs_data[[1]], gs_fname, auto_unbox=TRUE, pretty=TRUE)
      }

      # # Shift Data commented out for now, no need for this
      # if (file.exists(shift_fname) && !clean_build) {
      #   if (verbose) pb$tick(0, tokens=list(gm=GM, what='Existing Shift Data Found   '))
      #   Sys.sleep(.001)
      # } else {
      #   if (verbose) pb$tick(0, tokens=list(gm=GM, what='Fetching Shift Data         '))
      #   shift_data <- fetch_shift_data(GM)
      #   if (verbose) pb$tick(0, tokens=list(gm=GM, what='Writing Shift Data to JSON  '))
      #   jsonlite::write_json(shift_data[[1]]$data, shift_fname, auto_unbox=TRUE, pretty=TRUE)
      # }

      # finally, tick along 1
      if (verbose) pb$tick(1, tokens=list(gm=GM, what='Processing Complete         '))
    }
  }

  # Option - Create a STATE file, but probably not necessary

  ## Rosters
  # First have to get all the _teams_
  # Use this to get season dates
  if (verbose) futile.logger::flog.info('> Getting Standings and Roster Info')
  season_info <- season_api |> format_uri(list(SEASON = season)) |> get_api_call()
  search_date <- min(lubridate::as_date(season_info$data[[1]]$regularSeasonEndDate), Sys.Date())
  standings   <- standings_api |> format_uri(list(DATE=search_date)) |> get_api_call()
  teams_for_the_season <- as.character(sapply(standings$standings,'[[', 'teamAbbrev'))

  # Do we want to save the standings?  May as well.
  light_parsed_standings <- data.table::rbindlist(lapply(standings$standings, function(z) {data.frame(t(unlist(z)))} ), fill=T)
  data.table::fwrite(light_parsed_standings, file=paste0(path,'/', season, '/standings.csv'))

  # We will ALWAYS overwrite this because it's mutable
  roster_pb <- progress_bar$new(
    format = "> Fetching Roster for :tm [:bar] :current/:total :percent (eta: :eta)",
    clear = FALSE,
    total = length(teams_for_the_season),
    width = 150)

  ROSTER_LIST <- list()
  for (tm in teams_for_the_season) {
    roster_pb$tick(tokens=list(tm=tm))
    Sys.sleep(runif(1, .1, .3))
    roster <- fetch_roster_data(season=season, team=tm)
    roster_fname <- paste0(ROSTER_PATH, season, '-', tm, '-roster.json')
    jsonlite::write_json(x=roster, path=roster_fname, auto_unbox=TRUE, pretty=TRUE)
    # Also append to list
    ROSTER_LIST[[length(ROSTER_LIST) + 1]] <- parse_roster_data(roster)
  }

  # Convert ROSTER into a quick player set
  all_players <- data.table::rbindlist(ROSTER_LIST, fill=TRUE)
  # deduplicate, in case rosters get repeated
  all_players <- all_players[!duplicated(all_players$id), ]
  data.table::fwrite(all_players, paste0(path,'/', season, '/all_players.csv'))

  # Draft Class
  if (verbose) futile.logger::flog.info('> Getting Draft Data')
  draft_data <- fetch_draft_data(year=substr(season,1,4))
  jsonlite::write_json(x = draft_data, path = paste0(path,'/', season, '/draft-data.json'), auto_unbox=TRUE, pretty=TRUE)

  if (verbose) futile.logger::flog.info('Data Archiving Complete!')
  return(invisible(NULL))

}


# State file generator
check_state <- function(path) {
  # checking if things exist -- here's what we'll want to do
  # Get every GAME_ID that exists in scores, summaries, and play-by-play
  # If that game ID exists, go ahead and remove it from the list of games to process
  extract_game_id_from_file <- function(fn) {strsplit(fn,'-')[[1]][1]}

  # game-summary
  gs_ids  <- sapply(list.files(paste0(path, '/game-summary/')), extract_game_id_from_file)
  # boxscores
  bs_ids  <- sapply(list.files(paste0(path, '/boxscores/')), extract_game_id_from_file)
  # pbp
  pbp_ids <-sapply(list.files(paste0(path, '/play-by-play/')), extract_game_id_from_file)

  shared_ids <- Reduce(intersect, list(gs_ids, bs_ids, pbp_ids))

  return(shared_ids)
}

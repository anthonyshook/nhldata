#' Function to fetch play-by-play data
#'
#' @param gameID an NHL gameID
#' @param verbose Defaults to FALSE
#'
#' @details Returns the raw list-formatted JSON of play-by-play data
#'
#' @export
fetch_play_by_play <- function(gameID, verbose=FALSE) {

  # Set up progress bar
  pb <- progress_bar$new(
    format = "> downloading Play-by-Play GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  pbp_data <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .5))
    if (verbose) pb$tick(tokens = list(what = G))
    out <- pbp_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
  })
  return(pbp_data)
}


#' Parse the PBP data
#' @param x Play by Play data
#' @export
parse_pbp_json <- function(pbp_file) {
  # Gets a big table with everything in it
  # might fail if an actual _value_ is NULL...
  pbp_data <- jsonlite::fromJSON(pbp_file)

  if (is.null(pbp_data$plays) || is_empty_list(pbp_data$plays)) {
    return(NULL)
  }
  # Add Game ID to start, see what happens next.
  DT <- cbind(
    data.table::data.table(gameId = rep(pbp_data$id, nrow(pbp_data$plays))),
    pbp_data$plays
  )

  DT <- data.table::as.data.table(pbp_data$plays)
  DT[, gameId := pbp_data$id]
  DT[, homeTeamId := pbp_data$homeTeam$id]
  DT[, awayTeamId := pbp_data$awayTeam$id]

  data.table::setcolorder(DT, c('gameId','homeTeamId','awayTeamId'))
  return(DT)
}


#' Clean pbp data
#' @details
#' Cleans up some column names, converts a few things
#' @param d pbp_data
#' @export
clean_pbp_data <- function(d) {
  # convert time data
  d$timeRemaining <- convert_clock_to_seconds(d$timeRemaining)
  d$timeInPeriod <- convert_clock_to_seconds(d$timeInPeriod)
  # drop pre-period column names
  #colnames(d) <- sapply(strsplit(colnames(d), '.', fixed = T), function(Z){Z[length(Z)]})
  colnames(d) <- gsub('details.','', colnames(d), fixed=TRUE)
  data.table::setnames(d, 'periodDescriptor.number','periodNumber')
  colnames(d) <- gsub('periodDescriptor.','', colnames(d), fixed=TRUE)
  # Dropping unnecessary highlight columns, because who needs 'em
  cols_to_remove <- grep(pattern = 'highlightClip|discreteClip|pptReplayUrl', colnames(d), value = T)
  d[, (cols_to_remove):=NULL]
  # Parsing the situation code for PBP?  something to consider
  # browser() -- MOSTLY we just want to do this for goals and assists, tbh.
  return(d)
}

#' Returns a split set of pbp data based on events
#' @param d data
#' @param event event type (e.g., 'goal' or 'blocked-shot')
#' @details
#' Uses some logic to split on `details`, which basically says if column for a given event type
#' is entirely NAs, then don't include it in the output.  This is less type-safe than specifying
#' the columns of interest from the details set, but also automatic.  Let's see if it bites me
#' in the ass later.
#' @noRd
split_pbp_data <- function(d, event) {
  d[typeDescKey==event, !sapply(d[typeDescKey==event], function(z) {(sum(is.na(z))==length(z))}), with=F]
}

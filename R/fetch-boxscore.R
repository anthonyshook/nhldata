#' Function to fetch game boxcores
#'
#' @param gameID A vector of gameIDs
#' @param verbose Default FALSE
#'
#' @details Returns the raw list-formatted JSON of boxscore data
#'
#' @export
fetch_boxscores <- function(gameID, verbose=FALSE){

  # Set up progress bar
  pb <- progress_bar$new(
    format = "> downloading Boxscore GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  boxscores <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .5))
    if (verbose) pb$tick(tokens = list(what = G))
    out <- game_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
  })
  return(boxscores)
}

#' Parse the basic boxscore data
#' @param box_file JSON file containing boxscore data
#' @export
parse_boxscore_json <- function(box_file) {
  box_data <- jsonlite::fromJSON(box_file)

  # To all tables, we should add columns for gameID, teamID, and home/away
  home_data <- lapply(box_data$playerByGameStats$homeTeam, function(ht) {
    ht$gameId <- box_data$id
    ht$homeAway <- 'H'
    ht$homeFlag <- TRUE
    ht$teamId <- box_data$homeTeam$id
    ht$teamName <- box_data$homeTeam$abbrev
    return(ht)
  })
  away_data <- lapply(box_data$playerByGameStats$awayTeam, function(ht) {
    ht$gameId <- box_data$id
    ht$homeAway <- 'A'
    ht$homeFlag <- FALSE
    ht$teamId <- box_data$awayTeam$id
    ht$teamName <- box_data$awayTeam$abbrev
    return(ht)
  })

  ## Skaters
  # browser()
  skaters_list <- list(
    data.table::as.data.table(home_data$forwards),
    data.table::as.data.table(home_data$defense),
    data.table::as.data.table(away_data$forwards),
    data.table::as.data.table(away_data$defense)
  )

  # little fix for names
  skaters_list <- lapply(skaters_list, function(skl) {
    data.table::setnames(skl, 'name.default','name', skip_absent = TRUE)
    dropnames <- grep(pattern='name.', x=colnames(skl), fixed = TRUE)
    if (length(dropnames) > 0) skl[, (dropnames) := NULL]
    return(skl)
  })

  skaters <- data.table::rbindlist(
    skaters_list,
    fill=TRUE,
    use.names = TRUE
  )

  # Convert skaters toi
  skaters$toi <- convert_clock_to_seconds(skaters$toi)

  ## Goalies
  goalie_list <- list(
    data.table::as.data.table(home_data$goalies),
    data.table::as.data.table(away_data$goalies)
  )

  # little fix for names
  goalie_list <- lapply(goalie_list, function(gl) {
    data.table::setnames(gl, 'name.default','name', skip_absent = TRUE)
    dropnames <- grep(pattern='name.', x=colnames(gl), fixed = TRUE)
    if (length(dropnames) > 0) gl[, (dropnames) := NULL]
    return(gl)
  })

  goalies <- data.table::rbindlist(
    goalie_list,
    fill=TRUE,
    use.names = TRUE
  )

  # Convert a few things for goalies
  goalies$toi <- convert_clock_to_seconds(goalies$toi)
  goalies$evenStrengthShotsAgainst <- extract_numerator(goalies$evenStrengthShotsAgainst)
  goalies$powerPlayShotsAgainst <- extract_numerator(goalies$powerPlayShotsAgainst)
  goalies$shorthandedShotsAgainst  <- extract_numerator(goalies$shorthandedShotsAgainst)
  goalies$saveShotsAgainst  <- NULL # Don't need this one

  # Reorder
  data.table::setcolorder(skaters, c('gameId','homeAway','homeFlag','teamId','teamName'))
  data.table::setcolorder(goalies, c('gameId','homeAway','homeFlag','teamId','teamName'))

  return(list(skaters=skaters, goalies=goalies))
}

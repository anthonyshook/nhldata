#' Function to fetch game data
#'
#' @param gameID A vector of gameIDs
#' @param verbose Default FALSE
#'
#' @details Returns game data. Involves hitting two endpoints to get high level scoring, penalty, and team-stat data
#'
#' @export
fetch_game_data <- function(gameID, verbose=FALSE){

  # Set up progress bar
  pb <- progress_bar$new(
    format = "> Fetching GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  game_data <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .3))
    if (verbose) pb$tick(tokens = list(what = G))
    out  <- game_story_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
    Sys.sleep(runif(1, .1, .3))
    out2 <- landing_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
    out$summary$penalties <- out2$summary$penalties
    return(out)
  })

  return(game_data)
}


#' Parse Game Data JSON
#' @param game_json Path to a JSON file containing the Game-Summary data
#' @export
parse_game_json <- function(game_json) {
  game_data <- jsonlite::fromJSON(game_json)
  if (any(sapply(game_data$summary$penalties$penalties, function(z){nrow(z)>0}))) {
    penalties <- lapply(1:nrow(game_data$summary$penalties), function(x) {
      DT <- data.table::as.data.table(game_data$summary$penalties[x,]$penalties)
      if (nrow(DT) > 0) {
        DT[, period := game_data$summary$penalties$periodDescriptor$number[x]]
        DT[, gameId := game_data$id]
      }
      return(DT)
    })
    penalties <- data.table::rbindlist(penalties, fill=T, use.names=TRUE)
    # Some quick fixing
    penalties$timeInPeriod <- convert_clock_to_seconds(penalties$timeInPeriod)
    data.table::setcolorder(penalties, c('gameId','period'))
  } else {
    penalties <- NULL
  }

  # Now to do the game level data
  team_game_stats <- data.table::data.table(game_data$summary$teamGameStats)
  home_values <- data.table::dcast(team_game_stats, 1 ~ category, value.var='homeValue')
  away_values <- data.table::dcast(team_game_stats, 1 ~ category, value.var='awayValue')
  # Add some data
  home_values[, home_away := 'home']
  home_values[, teamId := game_data$homeTeam$id]
  home_values[, team := game_data$homeTeam$abbrev]
  home_values[, goals := game_data$homeTeam$score]
  away_values[, home_away := 'away']
  away_values[, teamId := game_data$awayTeam$id]
  away_values[, team := game_data$awayTeam$abbrev]
  away_values[, goals := game_data$awayTeam$score]
  all_values <- rbind(home_values, away_values)
  # Augmenting
  all_values[, gameId := game_data$id]
  data.table::setcolorder(all_values, c('gameId','teamId','team','home_away','goals'))
  # removes the leftover from dcasting
  all_values$`.` <- NULL

  # Now for some recalculating
  all_values$pp_goals <- extract_numerator(all_values$powerPlay)
  all_values$pp_opps  <- extract_denominator(all_values$powerPlay)
  all_values$powerPlay <- NULL


  # tgs_cast <- data.table::dcast(data.table::melt(data.table::as.data.table(team_game_stats), id.vars=c('category')), '1 ~ variable + category')
  # tgs_cast <- tgs_cast[, 2:ncol(tgs_cast)]
  browser()

  return(
    list(
      penalties = penalties,
      game_info = game_info
    )
  )
}

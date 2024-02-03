#' Function to fetch player info for ALL players
#'
#' @description
#' This function takes no arguments. It provides a method of grabbing basic data about every player in the NHL database.
#'
#' @returns Data.table containing all players of all time
#'
fetch_all_players <- function() {
  # Get players
  player_data <- get_api_call(all_players_api)
  # Parse gently
  playerdf = data.table::rbindlist(lapply(players, function(dd) {data.frame(dd[!sapply(dd, is.null)])}), fill=TRUE)
  # we MAYBE want to update some names
  playerdf[, height := convert_ftinch(height)]
  data.table::setnames(playerdf,
                       new = c('player_id', 'full_name', 'pos', 'last_season', 'jersey_number', 'active',
                               'height_inches','weight_lbs','height_cm','weight_kg','birth_city',
                               'birth_state_province','birth_country','last_team_id', 'last_team_abbr',
                               'team_id', 'team_abbr'))
  return(playerdf)
}



#' Function to fetch player info for a single player
#'
#' @param playerID A player ID to fetch
#'
#' @export
fetch_player_info <- function(playerID) {

  # Get API
  api_string <- gsub(pattern='{{PLAYER_ID}}', replacement=playerID, x=single_player_api, fixed=TRUE)
  pd <- get_api_call(api_string)

  # finalize
  final_pdata <- data.table::data.table(playerid = pd$playerId,
                                        fname = pd$firstName$default,
                                        lname = pd$lastName$default,
                                        jersey_number = pd$sweaterNumber,
                                        birth_date = pd$birthDate,
                                        birth_city = pd$birthCity$default,
                                        birth_state_province = pd$birthStateProvince$default,
                                        birth_country = pd$birthCountry,
                                        height_inches = pd$heightInInches,
                                        weight_lbs = pd$weightInPounds,
                                        handedness = pd$shootsCatches,
                                        on_roster = pd$isActive,
                                        current_teamid = ifelse(pd$isActive, pd$currentTeamId, NA),
                                        pos = pd$position)

  return(final_pdata)
}


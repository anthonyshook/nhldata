#' Function to fetch player info
#'
#' @param playerID A player ID to fetch
#'
#' @export
fetch_player_info <- function(playerID) {

  # Get API
  player_api <- paste0('https://statsapi.web.nhl.com/api/v1/people/', playerID)
  player_data <- get_api_call(player_api)

  # Transform to data.table
  player_data <- data.table::data.table(data.frame(player_data$people, stringsAsFactors = FALSE), stringsAsFactors = FALSE)

  # Apply a mask to ensure consistency
  player_data <- apply_mask(player_mask, player_data)

  # finalize
  final_pdata <- player_data[, .(playerid = id,
                                 fname = firstName,
                                 lname = lastName,
                                 jersey_number = primaryNumber,
                                 birth_date = birthDate,
                                 birth_city = birthCity,
                                 birth_state_province = birthStateProvince ,
                                 birth_country = birthCountry,
                                 nationality = nationality,
                                 height_inches = convert_ftinch(height),
                                 weight_lbs = weight,
                                 active = active,
                                 captain = captain,
                                 alt_captain = alternateCaptain,
                                 rookie = rookie,
                                 handedness = shootsCatches,
                                 on_roster = rosterStatus,
                                 current_teamid = currentTeam.id,
                                 pos = primaryPosition.abbreviation,
                                 pos_name = primaryPosition.name,
                                 pos_type = primaryPosition.type,
                                 pos_broad = primaryPosition.code
  )]

  return(final_pdata)

}



#' Function to get all teams data, including rosters!
#'
#' @param season Season to pull roster data for, accepts one (format '20182019')
#'
#' @export
fetch_team_data <- function(season = NULL) {

  team_call <- "https://statsapi.web.nhl.com/api/v1/teams?expand=team.roster"
  if(!is.null(season)){
    team_call <- paste0(team_call, "&season=", season)
  } else {
    season <- 'current'
  }

  resp <- get_api_call(team_call)

  team_info <- lapply(resp$teams, function(X) {

    team_data <- data.frame(X[-which(names(X)=="roster")])
    roster_data <- data.table::rbindlist(lapply(X$roster$roster, data.frame), fill = TRUE)

    return(list(
      team = data.table::data.table(team_data, season = season),
      roster = data.table::data.table(teamID = team_data$id, season = season, roster_data)
    ))
  })

  final_team_data <- data.table::rbindlist(lapply(team_info, '[[', 'team'), fill = TRUE)
  final_roster_data <- data.table::rbindlist(lapply(team_info, '[[', 'roster'), fill = TRUE)

  ## Cleaning up the data
  final_team_data <- final_team_data[, .(teamid = id,
                                         team_name = name,
                                         abbr_name = abbreviation,
                                         franchiseid = franchiseId,
                                         franchise_name = franchise.teamName,
                                         season = season,
                                         venueid = venue.id,
                                         venue_name = venue.name,
                                         venue_city = venue.city,
                                         venue_timezone = venue.timeZone.tz,
                                         first_active_year = firstYearOfPlay,
                                         division  = division.name,
                                         divisionid = division.id,
                                         conference = conference.name,
                                         conferenceid = conference.id,
                                         currently_active = active)][order(teamid)]

  final_roster_data <- final_roster_data[, .(playerid = person.id,
                                             teamid = teamID,
                                             season = season,
                                             player_name = person.fullName,
                                             jersey_number = jerseyNumber,
                                             pos = position.abbreviation,
                                             pos_code = position.code,
                                             pos_name = position.name,
                                             pos_type = position.type)][order(playerid)]

  return(list(team = final_team_data,
              roster = final_roster_data))

}

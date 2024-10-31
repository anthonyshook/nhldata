#' Function to get List of Teams
#'
#' @param nhl_only Defaults to TRUE, wherein the function returns only NHL teams
#' If FALSE, you'll teams in other leagues (AHL, OHL, etc.)
#' @param active_only Defaults to TRUE, wherein you'll only get active teams.
#'
#' @export
fetch_all_teams <- function(nhl_only=TRUE, active_only=TRUE) {
  resp <- get_api_call(teams_api)

  out <- lapply(resp$data, function(z) {
    data.frame(z[!sapply(z, is.null)])
  })

  df <- data.table::rbindlist(out, fill=TRUE)
  if (nhl_only) {
    df <- df[leagueId==133,]
  }

  if (active_only) {
  df <- df[active=='Y',]
  }

  return(df)
}

#' Parse Team Data
#' @noRd
parse_team_metadata <- function(teamdata) {
  teamdata[, list(
    teamid = id,
    team_name = fullName,
    abbr_name = triCode,

  )]
}


#' Function to fetch Roster Data
#'
#' @param season Season (e.g., 20242025)
#' @param team Team Abbreviation (e.g., PIT)
#'
#' @details Simply provides rosters for a given season
#'
#' @export
fetch_roster_data <- function(season, team) {
  return(
    roster_api |> format_uri(list(TEAM_ABBR = team, SEASON = season)) |> get_api_call()
  )
}


parse_roster_data <- function(roster_json) {
  # quick internal function
  extract_as_data_frame <- function(x) {
    data.frame(
      id = x$id,
      firstname = x$firstName$default,
      lastname = x$lastName$default,
      position = x$positionCode,
      hand = x$shootsCatches,
      height_inches = x$heightInInches,
      weight_pounds = x$weightInPounds,
      dob = x$birthDate,
      birth_country = x$birthCountry,
      birth_city = ifelse(is.null(x$birthCity$default), NA, x$birthCity$default),
      birth_state_province = ifelse(is.null(x$birthStateProvince$default), NA, x$birthStateProvince$default)
    )
  }

  # Fowards
  forwards <- data.table::rbindlist(
    lapply(roster_json$forwards, extract_as_data_frame),
    fill = TRUE
  )

  defensemen <- data.table::rbindlist(
    lapply(roster_json$defensemen, extract_as_data_frame),
    fill = TRUE
  )

  goalies <- data.table::rbindlist(
    lapply(roster_json$goalies, extract_as_data_frame),
    fill = TRUE
  )

  return(
    data.table::rbindlist(
      list(forwards, defensemen, goalies),
      fill=TRUE
    )
  )

}


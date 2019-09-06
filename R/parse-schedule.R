#' Function to parse schedule data
#'
#' @param schedule_json The JSON output from NHL Schedule API
#'
#' @export
#'
parse_schedule <- function(schedule_json) {

  # From the scheduled JSON, it's honestly VERY easy to just unlist everything
  unlisted_games <- unlist(lapply(schedule_json$dates, function(Z) {
    individual_games <- lapply(Z$games, function(Y){

      # Compile
      out <- data.frame(Y, stringsAsFactors = FALSE)

    })
  }), recursive = FALSE)

  # Compile everything
  games_table <- data.table::rbindlist(unlisted_games, fill = TRUE)

  # translate table
  col_trans <- data.frame(
    matrix(c(
      "gameid","gamePk",
      "game_type","gameType",
      "season", "season",
      "game_datetime_utc", "gameDate",
      "abstract_state", "status.abstractGameState",
      "abstract_state_code", "status.codedGameState",
      "detailed_state", "status.detailedState",
      "detailed_state_code", "status.statusCode",
      "away_team_id", "teams.away.team.id",
      "away_team_name", "teams.away.team.name",
      "away_team_wins", "teams.away.leagueRecord.wins",
      "away_team_losses", "teams.away.leagueRecord.losses",
      "away_team_ot_losses", "teams.away.leagueRecord.ot",
      "away_team_score", "teams.away.score",
      "home_team_id", "teams.home.team.id",
      "home_team_name", "teams.home.team.name",
      "home_team_wins", "teams.home.leagueRecord.wins",
      "home_team_losses", "teams.home.leagueRecord.losses",
      "home_team_ot_losses", "teams.home.leagueRecord.ot",
      "home_team_score", "teams.home.score",
      "venueid", "venue.id",
      "venue_name", "venue.name"),
      ncol = 2, byrow = TRUE), stringsAsFactors = FALSE
    )

  # change names, remove a few columns
  col_trans <- col_trans[col_trans$X2 %in% colnames(games_table), ]

  # Set new names
  data.table::setnames(games_table, old = col_trans$X2, new = col_trans$X1)

  # Get only the columns we care about
  games_table <- games_table[, .SD, .SDcols = col_trans$X1]

  # Lastly, make sure game_datetime is actually time
  games_table$game_datetime_utc <- lubridate::as_datetime(games_table$game_datetime_utc)


  return(games_table)

}

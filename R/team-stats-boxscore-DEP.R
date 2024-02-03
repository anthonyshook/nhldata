
#' function to parse game boxscore data for team stats
#'
#' @param boxscore Parsed content from an NHL api call to boxscore for a single game
#' @param gid the game ID, used to keep track of what's going on.
#'
#' @export
team_stats_from_boxscore <- function(boxscore){

  # Separate home/away stats
  home_stats <- data.frame(c(boxscore$teams$home$team[c(1,2)],
                             boxscore$teams$home$teamStats),
                           stringsAsFactors = FALSE)
  away_stats <- data.frame(c(boxscore$teams$away$team[c(1,2)],
                             boxscore$teams$away$teamStats),
                           stringsAsFactors = FALSE)

  # Put them together, and return
  final <- data.table::rbindlist(list(home = home_stats, away = away_stats), idcol = "home_away")

  # Fix some column names
  colnames(final) <- gsub(pattern = "teamSkaterStats\\.", replacement = "", colnames(final))

  # Rename some columns
  data.table::setnames(final,
                       old = c("id", "name", "powerPlayPercentage", "powerPlayGoals", "powerPlayOpportunities", "faceOffWinPercentage"),
                       new = c("teamid", "team_name", "pp_pct", "pp_goals", "pp_opps", "faceoff_win_pct"))

  # Reorder some columns
  data.table::setcolorder(final, c("teamid", "team_name"))

  return(final)

}

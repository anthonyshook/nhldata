#' Clean player data
#'
#' @param players Data.table containing skater info
#'
#' @description The purpose of this function is to clean player data.  This includes removing unwanted columns,
#' renaming wanted columns, and replacing NAs with 0.
#'
#' @keywords internal
clean_player_data <- function(players) {

  # List of positive columns
  cols_to_keep <- c("gameId", "person.id", "person.fullName", "person.rookie",
                    "person.currentAge", "person.shootsCatches", "person.currentTeam.id",
                    "person.currentTeam.name", "position.abbreviation",
                    colnames(players)[grep(x=colnames(players), pattern = "^stats.")])

  out <- players[, which(colnames(players) %in% cols_to_keep), with = FALSE]

  # better column names
  colnames(out) <- clean_colnames(colnames(out))

  out[is.na(out)] <- 0

  return(out)

}

clean_skater_data <- function(skaters) {

  # Just to make life easier...
  colnames(skaters) <- clean_colnames(colnames(skaters))

  # If a value isn't in the template, add it
  skaters <- apply_mask(skater_template, skaters)

  cleaned <- skaters[, .(playerid = id,
                         gameid = gameID,
                         goals = goals,
                         assists = assists,
                         shots = shots,
                         shot_pct = ifelse(shots>0, goals/shots, NA),
                         hits = hits,
                         pp_goals = powerPlayGoals,
                         pp_assists = powerPlayAssists,
                         pim = penaltyMinutes,
                         fow = faceOffWins,
                         fot = faceoffTaken,
                         fo_pct = faceOffPct,
                         takeaways = takeaways,
                         giveaways = giveaways,
                         sh_goals = shortHandedGoals,
                         sh_assists = shortHandedAssists,
                         blocked_shots = blocked,
                         plus_minus = plusMinus,
                         toi = convert_time(timeOnIce),
                         toi_even = convert_time(evenTimeOnIce),
                         toi_pp = convert_time(powerPlayTimeOnIce),
                         toi_sh = convert_time(shortHandedTimeOnIce)
  )]

  return(cleaned)

}

#' Clean Goalie Data
clean_goalie_data <- function(goalies) {

  # Just to make life easier...
  colnames(goalies) <- clean_colnames(colnames(goalies))

  # If a value isn't in the template, add it
  goalies <- apply_mask(goalie_template, goalies)

  cleaned <- goalies[, .(playerid = id,
                         gameid = gameID,
                         goals = goals,
                         toi = convert_time(timeOnIce),
                         assists = assists,
                         pim = pim,
                         saves = saves,
                         shots_against = shots,
                         saves_pp = powerPlaySaves,
                         shots_against_pp = powerPlayShotsAgainst,
                         saves_sh = shortHandedSaves,
                         shots_against_sh = shortHandedShotsAgainst,
                         saves_even = evenSaves,
                         shots_against_even = evenShotsAgainst,
                         decision = decision,
                         save_pct = savePercentage,
                         save_pct_pp = powerPlaySavePercentage,
                         save_pct_sh = shortHandedSavePercentage,
                         save_pct_even = evenStrengthSavePercentage,
                         goals_against = shots - saves,
                         goals_against_pp = powerPlayShotsAgainst - powerPlaySaves,
                         goals_against_sh = shortHandedShotsAgainst - shortHandedSaves,
                         gaa = ((shots-saves) * 60) / (convert_time(timeOnIce)/60),
                         shutout = (shots-saves) == 0
  )]

  return(cleaned)

}



#' Clean team stat data
#'
#' @param team_stats Data.table containing team stats at the game level
#'
clean_team_stat_data <- function(team_stats){

  # We will keep ALL columns but rename things
  colnames(team_stats) <- tolower(gsub(pattern = "teamSkaterStats.", replacement = "", x = colnames(team_stats), fixed = TRUE))

  data.table::setnames(team_stats, "team_name", "team_name")

  # return
  return(team_stats)

}


#' clean colnames
#'
#' @param column_names Names of columns to clean
#'
clean_colnames <- function(column_names){

  # Remove PERSON
  column_names <- gsub(pattern = "person.", replacement = "",
                       x = column_names, fixed = TRUE)

  # Remove skater stats
  column_names <- gsub(pattern = "stats.skaterStats.", replacement = "",
                       x = column_names, fixed = TRUE)

  # Remove goalie stats
  column_names <- gsub(pattern = "stats.goalieStats.", replacement = "",
                       x = column_names, fixed = TRUE)

  # Hardcoded
  column_names <- gsub(pattern = "currentTeam.id", replacement = "teamID",
                       x = column_names, fixed = TRUE)
  column_names <- gsub(pattern = "currentTeam.name", replacement = "team_name",
                       x = column_names, fixed = TRUE)
  column_names <- gsub(pattern = ".abbreviation", replacement = "",
                       x = column_names, fixed = TRUE)

  return(column_names)

}


#' Convert time
#'
#' @param time_col Column containing "MM:SS" formatted data, as is typically provided by NHL api
#'
convert_time <- function(time_col) {

  # convert time using lubridate
  time_col <- lubridate::period_to_seconds(lubridate::hms(paste0("00:", time_col)))

  return(time_col)

}

#' Convert feet/inches to inches
#'
#' @param ftinch string of format `ft' in"`
#'
convert_ftinch <- Vectorize(function(ftinch) {

  if (all(is.na(ftinch))) {
    return(NA)
  } else if (any(is.na(ftinch))) {
    ftinch <- ftinch[!is.na(ftinch)]
  }

  vec <- gsub("\"| ", "", unlist(strsplit(ftinch, "'")))

  return(
    (as.numeric(vec[1]) * 12) + as.numeric(vec[2])
  )

})

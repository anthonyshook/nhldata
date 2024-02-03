#' function to parse game boxscore data for player stats
#'
#' @param boxscore Parsed content from an NHL api call to boxscore for a single game
#' @param gid GameId -- comes along for safekeeping!
#'
#' @export
player_stats_from_boxscore <- function(boxscore, gid){

  # Once for home, and once for away
  home_players <- lapply(boxscore$teams$home$players, function(Z){
    tryCatch(data.frame(Z, stringsAsFactors = FALSE), error = function(e){NULL})
  })
  away_players <- lapply(boxscore$teams$away$players, function(Z){
    tryCatch(data.frame(Z, stringsAsFactors = FALSE), error = function(e){NULL})
  })

  all_players <- c(home_players, away_players)
  all_players <- all_players[!sapply(all_players, is.null)]

  # Separate goalies/skaters
  goalie_index <- sapply(all_players, function(Z){
    if (is.null(Z$person.primaryPosition.abbreviation)) {
      Z$position.abbreviation == "G"
    } else {
      Z$person.primaryPosition.abbreviation == "G"
    }
  })

  if (length(all_players) == 0) {
    return(list(
      skaters = NULL,
      goalies = NULL
    )
    )
  }

  skaters <- data.table::rbindlist(all_players[!goalie_index], fill = TRUE)
  goalies <- data.table::rbindlist(all_players[goalie_index], fill = TRUE)

  # Remove scratches (they should be gone already, but it's for safety)
  scratch_list <- c(unlist(boxscore$teams$away$scratches), unlist(boxscore$teams$home$scratches))

  skaters <- skaters[!(skaters$person.id %in% scratch_list), ]
  goalies <- goalies[!(goalies$person.id %in% scratch_list), ]

  # Return a list of skaters and goalies
  return(
    list(
      skaters = data.table::data.table(gameID = gid, skaters),
      goalies = data.table::data.table(gameID = gid, goalies)
    )
  )

}

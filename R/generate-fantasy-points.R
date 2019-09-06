#' Generate fantasy points
#'
#' @param players List of players with stats.
#' @param site Currently only "draftkings" is supported
#' @param type Either 'goalie' or 'skater'; if not provided, we'll try to guess.
#'
generate_fantasy_points <- function(players, site = 'draftkings', type = NULL){

  # checks
  if (site != 'draftkings') {
    stop("ERROR in 'site' definition:: Only 'draftkings' is supported.")
  }

  if (!is.null(type) && !(type %in% c('skater','goalie'))){
    stop("ERROR in argument 'type':: If provided, must be one of 'skater' or 'goalie'")
  }

  # Guess type if null
  if (is.null(type)){
    if (all(players$position == "G")) {
      type = 'goalie'
    } else {
      type = 'skater'
    }
  }

  # Make copy of data
  d <- data.table::copy(players)

  # Skater points
  # NOTE THAT THIS CURRENTLY IGNORES THE SHOOTOUT GOAL BONUS OF +.2
  # However, as of Feb. 21st, 2018, the person with the highest number of shootout goals is Artemi Panarin with 6,
  # accounting for only 1.2 points over 60 games (or 0.02 pt/gm), so we probably don't _need_ it
  if (type == 'skater'){
    d[, fpts_dk :=
        (goals * 3) +
        (assists * 2) +
        (shots * .5) +
        (blocked_shots * .5) +
        (sh_goals * 1) +
        (sh_assists * 1) +
        (ifelse(goals >= 3, 1.5, 0))
      ]
  } else {
    d[, fpts_dk :=
        ifelse(decision == "W", 3, 0) +
        (saves * .2) -
        ((shots_against-saves) * 1) +
        ifelse(shots_against == saves, 2, 0)
      ]
  }

  return(d)
}

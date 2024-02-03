#' Function to fetch game boxcores
#'
#' @param gameID A vector of gameIDs from NHL API
#'
#' @return A list containing three elements
#' \describe{
#'   \item{team_stats}{Data about team performance (goals, shots, etc).}
#'   \item{skater_stats}{Data about skaters.}
#'   \item{goalie_stats}{Data about goaltender performance.}
#' }
#'
#' @export
fetch_boxscore_stats <- function(gameID){

  boxscores <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .5))
    out <- list()
    boxscore_api <- build_boxscore_api(G)
    bs_data      <- get_api_call(boxscore_api)

    # Get Team Stats from Boxscore
    #out$team_stats   <- data.table::data.table(gameID = G, team_stats_from_boxscore(bs_data))
    #out$player_stats <- player_stats_from_boxscore(bs_data, G)

    out$player_stats$forwards <- data.table::rbindlist(lapply(bs_data$boxscore$playerByGameStats$homeTeam$forwards, 'data.frame'), fill=TRUE)
    out$player_stats$defense <- data.table::rbindlist(lapply(bs_data$boxscore$playerByGameStats$homeTeam$defense, 'data.frame'), fill=TRUE)
    out$player_stats$goalies <- data.table::rbindlist(lapply(bs_data$boxscore$playerByGameStats$homeTeam$goalies, 'data.frame'), fill=TRUE)

    return(out)
  })
#
#   # Get all the player stats out
#   pstats <- lapply(boxscores, '[[', 'player_stats')
#
#   final <- list(
#     team_stats   = data.table::rbindlist(lapply(boxscores, '[[', 'team_stats'), fill = TRUE),
#     skater_stats = data.table::rbindlist(lapply(pstats, '[[', 'skaters'), fill = TRUE),
#     goalie_stats = data.table::rbindlist(lapply(pstats, '[[', 'goalies'), fill = TRUE)
#   )
#
#   # Teams are resilient to issues, so keep these aside
#   final$team_stats <- clean_team_stat_data(final$team_stats)
#
#   if (nrow(final$skater_stats) > 0) {
#     # some quick reordering, which will break when we change the name...
#     data.table::setcolorder(final$skater_stats, 'person.id')
#
#     # fix the column names etc.
#     final$skater_stats <- clean_skater_data(final$skater_stats)
#
#     # Add fantasy points to players
#     final$skater_stats <- generate_fantasy_points(final$skater_stats, type = 'skater')
#   }
#
#   if (nrow(final$goalie_stats) > 0) {
#     # Reorder columns
#     data.table::setcolorder(final$goalie_stats, 'person.id')
#
#     # Fix column names
#     final$goalie_stats <- clean_goalie_data(final$goalie_stats)
#
#     # Enrich with fantasy points
#     final$goalie_stats <- generate_fantasy_points(final$goalie_stats, type = 'goalie')
#   }

  return(boxscores)

}

# Helper function
build_boxscore_api <- function(gameID) {
  return(gsub(pattern = '{{GAME_ID}}', replacement = gameID, x= game_api, fixed = TRUE))
}

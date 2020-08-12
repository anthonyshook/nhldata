#' Update boxscore tables
#'
#' @param dat A data set for updating. Can be NULL, otherwise, should be the output of lapply(gameIDs, fetch_boxscore_stats)
#' @param conn a DB connection (required)
#' @param gameIDs if dat is null, the function will try to use "gameIDs" -- a vector of game ids!
#'
#' @description One of either dat or gameIDs MUST be provided.
#'
#' @export
#'
update_boxscore_tables <- function(dat = NULL, conn, gameIDs = NULL) {

  # If dat is NULL, grab some data
  if (is.null(dat)) {
    dat <- lapply(gameIDs, fetch_boxscore_stats)
  }

  # combine the data
  team_table   <- data.table::rbindlist(lapply(dat, '[[', 'team_stats'), fill = TRUE)
  skater_table <- data.table::rbindlist(lapply(dat, '[[', 'skater_stats'), fill = TRUE)
  goalie_table <- data.table::rbindlist(lapply(dat, '[[', 'goalie_stats'), fill = TRUE)

  # Upsert time
  dbx::dbxUpsert(conn = conn, table = 'team_games', records = team_table, where_cols = c('gameid','teamid'))
  dbx::dbxUpsert(conn = conn, table = 'skater_games', records = skater_table, where_cols = c('playerid', 'gameid'))
  dbx::dbxUpsert(conn = conn, table = 'goalie_games',
                 records = goalie_table[toi > 0],
                 where_cols = c('playerid', 'gameid'))

  return(TRUE)

}

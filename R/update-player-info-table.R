#' Update the player_info table
#'
#' @param gameIDs Game IDs from which to grab playerids (Optional, used to limit scope)
#' @param conn A db connection. There is no default.
#'
#' @description only necessary due to possible additions to the table.
#' Relies on calling existing tables.
#'
#' @export
#'
update_player_info_table <- function(gameIDs = NULL, conn) {

  # Check if player_info table exists
  pit_exists <- DBI::dbExistsTable(conn, "players")

  # Check if the skater_games table exists
  sgt_exists <- DBI::dbExistsTable(conn, "players")

  # Check if the goalie_games table exists
  ggt_exists <- DBI::dbExistsTable(conn, "players")

  if (!all(pit_exists, sgt_exists, ggt_exists)) {
    stop(paste("Missing one of: players, skater_games, or goalie_games in DB"))
  }

  # LOGIC
  # pull in the players table
  # current_players_table <- data.table::data.table(DBI::dbReadTable(conn = conn, name = "players"))

  # get distinct skater and goalie games
  if (!is.null(gameIDs)) {
    games_in <- paste(gameIDs, collapse = ", ")
    statement <- paste("SELECT DISTINCT playerid FROM skater_games",
                       "WHERE gameid IN (", games_in,")",
                       "UNION",
                       "SELECT DISTINCT playerid FROM goalie_games",
                       "WHERE gameid IN (", games_in,")")
  } else {
    statement <- paste("SELECT DISTINCT playerid FROM skater_games",
                       "UNION",
                       "SELECT DISTINCT playerid FROM goalie_games")
  }

  # Getting the new player ids
  playerids <- DBI::dbGetQuery(conn = conn, statement = statement)$playerid

  # Get the updated version
  new_players_table <- data.table::rbindlist(lapply(playerids, fetch_player_info))

  # The comparison can be done with fsetdiff, but only if the column values are equal.
  # Which they aren't
  # data.table::fsetdiff(new_players_table, current_players_table)

  # Just upsert the new ones
  dbx::dbxUpsert(conn = conn, table = "players", records = new_players_table, where_cols = 'playerid')

  return(TRUE)

}

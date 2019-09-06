#' Update plays tables
#'
#' @param dat A data set for updating. Can be NULL, otherwise, should be the output of lapply(gameIDs, fetch_boxscore_stats)
#' @param conn a DB connection (required)
#' @param gameIDs if dat is null, the function will try to use "gameIDs" -- a vector of game ids!
#'
#' @description One of either dat or gameIDs MUST be provided.
#'
#' @export
#'
update_plays_tables <- function(dat = NULL, conn, gameIDs = NULL) {

  # If dat is NULL, grab some data
  if (is.null(dat)) {
    dat <- lapply(gameIDs, fetch_play_by_play)
  }

  # combine
  tbl_names <- unique(unlist(lapply(dat,names)))

  coll_tables <- lapply(tbl_names, function(Ns){
    data.table::rbindlist(lapply(dat, '[[', Ns))
  })

  names(coll_tables) <- tbl_names

  # Lapply and upsert everything
  lapply(tbl_names, function(TBL){
    if (TBL == "assists") {
      dbx::dbxUpsert(conn = conn, table = TBL, records = coll_tables[[TBL]], where_cols = c('eventid', 'playerid'))
    } else {
      dbx::dbxUpsert(conn = conn, table = TBL, records = coll_tables[[TBL]], where_cols = 'eventid')
    }
  })

  return(TRUE)

}

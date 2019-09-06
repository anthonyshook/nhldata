#' Build play_by_play table
#'
#' @param gameIDs a vector of gameIDs to process and add to the database
#' @param conn A connection to a database - defaults to creating a new one
#' @param num_cores Number of cores to use when processing.
#'
#' @description The internals here are hard-coded, as this is not meant to be
#' something used outside of the current process, at the moment.
#' In the future, perhaps something config-based could be created
#' This is meant to create the table brand new, not update it. If the table already
#' exists, it will be re-written by running this function.
#'
#' @export
#'
build_plays_table <- function(gameIDs, conn = connect_to_db(), num_cores = 1) {

  on.exit(
    if(substitute(conn) == 'connect_to_db()') {
      DBI::dbDisconnect(conn)
    }
  )

  # Fetch the play-by-play
  if (num_cores == 1) {
    infotbls <- lapply(gameIDs, fetch_play_by_play)
  } else if (num_cores > 1) {
    cl <- parallel::makeCluster(num_cores)
    parallel::clusterExport(cl = cl, varlist = ls(name = 'package:nhldata'),
                            envir = environment())
    infotbls <- parallel::parLapply(cl = cl, X = gameIDs, fetch_play_by_play)
    parallel::stopCluster(cl)
  } else {
    stop("num_cores cannot be negative")
  }


  # combine
  tbl_names <- unique(unlist(lapply(infotbls, names)))

  coll_tables <- lapply(tbl_names, function(Ns){
    data.table::rbindlist(lapply(infotbls, '[[', Ns))
  })

  names(coll_tables) <- tbl_names

  # Write out to table, based on conn
  lapply(tbl_names, function(TBL){
    DBI::dbWriteTable(conn = conn,
                      name = TBL,
                      value = coll_tables[[TBL]],
                      overwrite = TRUE,
                      row.names = FALSE)

    # Make some indeces
    if (TBL == "assists") {
      statement <- list(paste0("CREATE UNIQUE INDEX ", TBL, round(runif(1,10000,99999)),"events ON ", TBL, "(eventid, playerid); "),
                        paste0("CREATE INDEX ", TBL, round(runif(1,10000,99999)),"games ON ", TBL, "(gameid);"))
    } else {
      statement <- list(paste0("CREATE UNIQUE INDEX ", TBL, round(runif(1,10000,99999)),"events ON ", TBL, "(eventid); "),
                        paste0("CREATE INDEX ", TBL, round(runif(1,10000,99999)),"games ON ", TBL, "(gameid);"))
    }
    lapply(statement, DBI::dbExecute, conn = conn)
  })

  return(invisible(TRUE))

}

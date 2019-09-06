#' Connect to DB
#'
#' @param type One of "sqlite" or "postgres" (defaults to "sqlite" as an internal test)
#' @param dbname The database name. If type = 'sqlite', it will be created. If type = 'postgres', it must be an existing database. Defaults to "hockey"
#' @param schema Only used if type = 'postgres'. Defaults to 'nhl'
#' @param host Defaults to "localhost"
#' @param port Defaults to 5432
#' @param user Defaults to 'postgres'
#' @param password Defaults to getPass::getPass()
#'
#' @description  Currently a shell for a SQLite connection
#'
#' @return an active connection to a db called "tempdb"
#'
#' @export
connect_to_db <- function(type = "sqlite",
                          dbname = 'hockey',
                          schema = 'nhl',
                          host = 'localhost',
                          port = 5432,
                          user = 'postgres',
                          password = getPass::getPass()) {

  # SQL LITE connection
  if (type == 'sqlite') {
    con <- DBI::dbConnect(RSQLite::SQLite(), "tempdb")
  } else if (type == 'postgres') {
    con <- DBI::dbConnect(
      DBI::dbDriver("PostgreSQL"),
      dbname = dbname,
      host = host,
      port = 5432, # fill in from somewhere
      user = user, # fill in from somewhere
      password = password # fill in from somewhere
    )
  }

  return(con)
}

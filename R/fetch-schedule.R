#' Function to get game IDs for a given time period
#'
#' @param season Season to query (e.g., '20152016'). Passing nothing will return the current day
#' @param start_date A beginning date to start (format - '2019-03-04')
#' @param end_date A last date of the range (format - '2019-03-04')
#' @param season_type The season type, where 1 = preseason, 2 = regular season, 3 = playoffs, 4 = all-star (Default 2)
#'
#' @details If season, start_date, and end_date are NOT provided, the default will be the current date
#'
#' @export
fetch_schedule <- function(season = NULL,
                          start_date = NULL,
                          end_date = NULL,
                          season_type = 2) {

  # Check error
  if (!(season_type %in% c(1,2,3,4))) {
    stop("ERROR: season_type must be one of 1, 2, 3, or 4")
  }

  # Get season_type
  ssn <- switch(season_type,
                "1" = "PR",
                "2" = "R",
                "3" = "A",
                "4" = "P")

  # build the API call
  api_call <- build_schedule_api(start_date)

  # Now we can grab the query
  games_json <- get_api_call(api_call)

  # Get unlisted stats for games
  parsed_games <- parse_schedule(games_json)

  return(parsed_games)

}


# Helper for building schedule API
build_schedule_api <- function(start_date) {

  # if (!is.null(season)) {
  #   season_api <- paste0(schedule_api, "/", start_date)
  # }

  if (!is.null(start_date)){
    #season_api <- paste0(schedule_api, "&startDate=", start_date)
  }

  # if (!is.null(end_date)) {
  #   season_api <- paste0(schedule_api, "&endDate=", end_date)
  # }

  return(season_api)

}

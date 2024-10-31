#' Function to get game IDs for a given time period
#'
#' @param season Season to query (e.g., '20152016'). Passing nothing will return the current day
#' @param season_type The season type, where 1 = preseason, 2 = regular season, 3 = playoffs, 4 = all-star (Default 2)
#'
#' @details If season, start_date, and end_date are NOT provided, the default will be the current date
#'
#' @export
fetch_game_ids <- function(season = NULL,
                           season_type = 2) {

  # Check error
  if (!(season_type %in% c(1,2,3,4))) {
    stop("ERROR: season_type must be one of 1, 2, 3, or 4")
  }

  # build the API call
  target_api <- all_game_ids |> format_uri(list(SEASON=season, GAMETYPE=season_type))
  sched <- get_api_call(target_api)

  sched <- replace_null_in_list(sched)

  # sched <- data.table::rbindlist(lapply(sched$data, function(Z) {
  #   data.frame(replace(Z, lengths(Z)== 0, NA))
  # }), fill = TRUE)
  sched <- data.table::rbindlist(lapply(sched$data, 'data.frame'))
  return(sched)
}

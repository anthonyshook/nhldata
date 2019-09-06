#' Function to fetch play-by-play data
#'
#' @param gameID an NHL gameID
#'
#' @export
fetch_play_by_play <- function(gameID) {

  # Get the API call
  api_call <- paste0('https://statsapi.web.nhl.com/api/v1/game/', gameID,'/feed/live')

  # Fetch the data
  counter <- 0
  parsed <- NULL
  while (counter <= 5 && is.null(parsed)) {

    # Wait to asynchronize
    Sys.sleep(runif(1,0.1,.5))

    # Add to the counter
    counter <- counter + 1

    # Get the data
    pbp_data <- get_api_call(api_call)

    # parse the data
    parsed <- try(parse_pbp(pbp_data))
  }

  return(parsed)

}

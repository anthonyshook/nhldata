#' Function to fetch play-by-play data
#'
#' @param gameID an NHL gameID
#'
#' @export
fetch_play_by_play <- function(gameID) {

  # Get the API call
  api_call <- gsub(pattern="{{GAME_ID}}", replacement=gameID, x=pbp_api, fixed = TRUE)
  print(api_call)

  # Fetch the data
  counter <- 0
  parsed <- NULL
  while (counter <= 1) {
  # while (counter <= 5 && is.null(parsed)) {

    # Wait to asynchronize
    Sys.sleep(runif(1,0.1,.5))

    # Add to the counter
    counter <- counter + 1

    # Get the data
    pbp_data <- get_api_call(api_call)

    # parse the data
    #parsed <- try(parse_pbp(pbp_data))
  }

  return(pbp_data)

}

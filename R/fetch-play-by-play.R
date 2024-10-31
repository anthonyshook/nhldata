#' Function to fetch play-by-play data
#'
#' @param gameID an NHL gameID
#' @param verbose Defaults to FALSE
#'
#' @details Returns the raw list-formatted JSON of play-by-play data
#'
#' @export
fetch_play_by_play <- function(gameID, verbose=FALSE) {

  # Set up progress bar
  pb <- progress_bar$new(
    format = "> downloading Play-by-Play GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  pbp_data <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .5))
    if (verbose) pb$tick(tokens = list(what = G))
    out <- pbp_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
  })
  return(pbp_data)
}

#' Function to fetch game boxcores
#'
#' @param gameID A vector of gameIDs
#' @param verbose Default FALSE
#'
#' @details Returns the raw list-formatted JSON of boxscore data
#'
#' @export
fetch_boxscores <- function(gameID, verbose=FALSE){

  # Set up progress bar
  pb <- progress_bar$new(
    format = "> downloading Boxscore GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  boxscores <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .5))
    if (verbose) pb$tick(tokens = list(what = G))
    out <- game_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
  })
  return(boxscores)
}

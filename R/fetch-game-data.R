#' Function to fetch game data
#'
#' @param gameID A vector of gameIDs
#' @param verbose Default FALSE
#'
#' @details Returns game data. Involves hitting two endpoints to get high level scoring, penalty, and team-stat data
#'
#' @export
fetch_game_data <- function(gameID, verbose=FALSE){

  # Set up progress bar
  pb <- progress_bar$new(
    format = "> Fetching GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  game_data <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .3))
    if (verbose) pb$tick(tokens = list(what = G))
    out  <- game_story_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
    Sys.sleep(runif(1, .1, .3))
    out2 <- landing_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
    out$summary$penalties <- out2$summary$penalties
    return(out)
  })

  return(game_data)
}

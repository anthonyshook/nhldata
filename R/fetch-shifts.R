#' Fetch Shift level information
#'
#' @param gameID Game ID for shift data
#' @param verbose Defaults to FALSE
#'
#' @export
fetch_shift_data <- function(gameID, verbose=FALSE) {

  pb <- progress_bar$new(
    format = "> downloading Shifts for GameID :what [:bar] :current/:total :percent eta: :eta",
    clear = FALSE, total = length(gameID), width = 150)

  shifts <- lapply(gameID, function(G){
    Sys.sleep(runif(1, .1, .5))
    if (verbose) pb$tick(tokens = list(what = G))
    out <- shifts_api |> format_uri(list(GAME_ID = G)) |> get_api_call()
  })

  return(shifts)
}

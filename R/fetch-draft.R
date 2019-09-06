#' Fetch the draft data
#'
#' @param verbose Whether to be verbose. Default is FALSE
#'
#' @details Automatically grabs all historical draft data back to the 1960s.
#'
#' @export
fetch_draft_data <- function(verbose = FALSE) {

  # API
  api_call <- "https://records.nhl.com/site/api/draft/"

  # Get the data
  if (verbose){cat("Grabbing data from NHL API\n")}
  raw_draft_data <- get_api_call(api_call)

  if (verbose){
    # Set up progress bar
    cat("Parsing Draft Data\n")
    pb <- txtProgressBar(min = 0, max = raw_draft_data$total, style = 3)
  }

  # Parsing the draft data
  draft_data <- lapply(1:raw_draft_data$total, function(Dt){

    D <- raw_draft_data$data[[Dt]]

    if (verbose){
      setTxtProgressBar(pb = get("pb", environment()), Dt)
    }

    # Replace all NULL with NA
    D[sapply(D,is.null)]<-NA

    out <- data.frame(D, stringsAsFactors = FALSE)
  })

  final_draft_data <- data.table::rbindlist(draft_data, fill = TRUE)

  final_draft_data <- final_draft_data[order(draftYear, overallPickNumber)]

  # Changing column names
  data.table::setnames(final_draft_data,
                       old = colnames(final_draft_data),
                       new = c("draftid", "amateur_club", "amateur_league", "birth_date", "birth_place", "country", "cs_playerid",
                               "draft_year", "draft_teamid", "fname", "height", "lname", "overall_pick",
                               "pick_in_round", "playerid", "player_name", "pos", "remove_outright", "removed_reason", "round",
                               "handedness", "supplemental_draft", "pick_history", "team_tricode", "weight"))

  # Changing column ORDER
  data.table::setcolorder(final_draft_data,
                          neworder = c(
                            "draftid",
                            "draft_year",
                            "overall_pick",
                            "pick_in_round",
                            "round",
                            "draft_teamid",
                            "team_tricode",
                            "cs_playerid",
                            "playerid",
                            "fname",
                            "lname",
                            "player_name",
                            "pos",
                            "birth_date",
                            "birth_place",
                            "country",
                            "height",
                            "weight",
                            "handedness",
                            "amateur_club",
                            "amateur_league",
                            "remove_outright",
                            "removed_reason",
                            "supplemental_draft",
                            "pick_history"
                          ))

  return(final_draft_data)

}

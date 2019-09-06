#' Function to fetch prospect data
#'
#' @param verbose whether to provide messaging, default FALSE
#'
#' @details only provides most recent crop of prospects, not historical data
#'
#' @export
fetch_prospect_info <- function(verbose = FALSE) {

  # Get all the recent prospect data
  if (verbose) {cat("Fetching Prosect data from NHL API")}
  raw_prospect_data <- get_api_call('https://statsapi.web.nhl.com/api/v1/draft/prospects')

  if (verbose){
    # Set up progress bar
    cat("Parsing Draft Data\n")
    pb <- txtProgressBar(min = 0, max = length(raw_prospect_data$prospects), style = 3)
  }

  prospect_data <- lapply(1:length(raw_prospect_data$prospects), function(pI){

    if (verbose){
      setTxtProgressBar(pb = get("pb", environment()), pI)
    }

    # single prospect
    P <- raw_prospect_data$prospects[[pI]]

    # Replace all NULL with NA
    P[sapply(P,is.null)]<-NA

    # Do the same with empty lists
    P[sapply(P, function(Z){is.list(Z) & length(Z) == 0})] <- NA

    out <- data.frame(P, stringsAsFactors = FALSE)
    return(out)

  })

  prospect_data_comb <- data.table::rbindlist(prospect_data, fill = TRUE)

  # Make a final set
  prospects_final <- prospect_data_comb[, .(
    prospectid = id,
    fullname = fullName,
    fname = firstName,
    lname = lastName,
    birth_date = birthDate,
    city = birthCity,
    state_province = birthStateProvince,
    country = birthCountry,
    nationality = nationality,
    height = convert_ftinch(height),
    weight = weight,
    handedness = shootsCatches,
    pos = primaryPosition.abbreviation,
    pos_type = primaryPosition.type,
    eligible_for_draft = draftStatus == 'Elig',
    prospect_catid = prospectCategory.id,
    prospect_cat_name = prospectCategory.name,
    ranks = ranks,
    amateur_team = amateurTeam.name,
    amateur_league = amateurLeague.name,
    nhl_playerid = nhlPlayerId
  )]


  return(prospects_final)
}

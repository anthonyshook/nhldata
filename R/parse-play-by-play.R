#' Function to parse play-by-play data
#'
#' @param pbp Play by play data from NHL api
#'
#' @export
parse_pbp <- function(pbp) {

  # Pull out the data
  allPlays <- pbp$liveData$plays$allPlays
  scoringPlays <- unlist(pbp$liveData$plays$scoringPlays)
  penaltyPlays <- unlist(pbp$liveData$plays$penaltyPlays)

  # Things get sticky here.
  parsed_plays <- lapply(allPlays, function(AP){

    # But, some things we don't care about, primary start/stop times.
    if (AP$result$eventTypeId %in% c("GAME_SCHEDULED", "PERIOD_READY", "PERIOD_START",
                                     "PERIOD_END", "PERIOD_OFFICIAL", "SHOOTOUT_COMPLETE", "GAME_END")) {
      return(NULL)
    }

    # Get the unique play ID
    unique_AP_id <- (pbp$gameData$game$pk * 10000) + AP$about$eventIdx

    out <- data.table::data.table(eventid = unique_AP_id,
                                  gameid = pbp$gameData$game$pk,
                                  event_category = AP$result$eventTypeId,
                                  event_code = AP$result$eventCode,
                                  event_shortdesc = AP$result$event,
                                  event_longdesc = AP$result$description,
                                  event_idx = AP$about$eventIdx,
                                  period = AP$about$period,
                                  period_type = AP$about$periodType,
                                  period_time = convert_time(AP$about$periodTime),
                                  period_time_remaining = convert_time(AP$about$periodTimeRemaining),
                                  event_time = lubridate::as_datetime(AP$about$dateTime)
    )

    # Not everything has coordinates, so let's check here to be safe.
    if (is.null(AP$coordinates$x)) {
      AP$coordinates$x <- NA
    }
    if (is.null(AP$coordinates$y)) {
      AP$coordinates$y <- NA
    }

    # Goddamn it, sometimes the secondaryType isn't a thing _either_
    # Which I knew for goals, but not for shots
    # So let's just ADD it if it's not there.
    secondary_type = if (is.null(AP$result$secondaryType)) {NA} else {AP$result$secondaryType}

    # Getting Individual Tables
    if (out$period_type != "SHOOTOUT") {
      ## Checking for goals
      if (AP$result$eventTypeId == "GOAL") {
        # Definitely will have one
        goal_scorer <- AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Scorer')]]

        # Empty net issue... in which case, we return NA
        if (is.null(AP$result$emptyNet)) {
          empty_net <- NA
        } else {
          empty_net <- AP$result$emptyNet
        }

        # Same for 'gameWinning'
        if (is.null(AP$result$gameWinningGoal)) {
          gwg <- NA
        } else {
          gwg <- AP$result$gameWinningGoal
        }

        # May not have a goalie... in which case, we return NAs
        opp_goalie <- tryCatch(AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Goalie')]],
                               error = function(e){list(player = list(id = NA, fullName = NA))})

        # May not have assists... in which case, this is empty
        assist_pl   <- AP$players[which(sapply(AP$players,'[[', 'playerType')=='Assist')]

        # Tables
        goals <- data.table::data.table(eventid = unique_AP_id,
                                        gameid = pbp$gameData$game$pk,
                                        playerid = goal_scorer$player$id,
                                        player_name = goal_scorer$player$fullName,
                                        opp_goalieid = opp_goalie$player$id,
                                        opp_goalie_name = opp_goalie$player$fullName,
                                        shot_type = secondary_type,
                                        situation = AP$result$strength$code,
                                        game_winning_goal = gwg,
                                        empty_net = empty_net,
                                        x_coord = AP$coordinates$x,
                                        y_coord = AP$coordinates$y)

        assists_comb <- data.table::rbindlist(lapply(assist_pl, data.frame), fill = TRUE)
        if (nrow(assists_comb) == 0) {
          assists = NULL
        } else {

          assists <- assists_comb[, .(eventid = unique_AP_id,
                                      gameid = pbp$gameData$game$pk,
                                      playerid = player.id,
                                      player_name = player.fullName,
                                      assist_order = 1:.N)]
        }
      } else {
        goals = NULL
        assists = NULL
      }

      ## Now checking for FACEOFF
      if (AP$result$eventTypeId == "FACEOFF") {
        player_winner <- AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Winner')]]
        player_loser  <- AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Loser')]]

        faceoffs <- data.table::data.table(eventid = unique_AP_id,
                                           gameid = pbp$gameData$game$pk,
                                           winnerid = player_winner$player$id,
                                           loserid = player_loser$player$id)
      } else {
        faceoffs = NULL
      }

      ## BLOCKED SHOTS
      if (AP$result$eventTypeId == "BLOCKED_SHOT") {
        blocked_shots <- data.table::data.table(eventid = unique_AP_id,
                                                gameid = pbp$gameData$game$pk,
                                                blocking_player = AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Blocker')]]$player$id,
                                                shooting_player = AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Shooter')]]$player$id,
                                                x_coord = AP$coordinates$x,
                                                y_coord = AP$coordinates$y)
      } else {
        blocked_shots = NULL
      }


      ## SHOTS
      if (AP$result$eventTypeId == "SHOT") {
        # tryCatch(AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Goalie')]]$player$id, error = function(e){print(AP)})
        shot_goalie <- tryCatch(AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Goalie')]]$player$id, error = function(e){return(0)})

        shots <- data.table::data.table(eventid = unique_AP_id,
                                        gameid = pbp$gameData$game$pk,
                                        shooter = AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Shooter')]]$player$id,
                                        goalie  = shot_goalie,
                                        shot_type = secondary_type,
                                        x_coord = AP$coordinates$x,
                                        y_coord = AP$coordinates$y)
      } else {
        shots <- NULL
      }


      ## MISSED SHOTS
      if (AP$result$eventTypeId == "MISSED_SHOT") {
        missed_shots <- data.table::data.table(eventid = unique_AP_id,
                                               gameid = pbp$gameData$game$pk,
                                               shooter = AP$players[[1]]$player$id,
                                               desc = gsub(paste0(AP$players[[1]]$player$fullName, " - "), "", AP$result$description),
                                               x_coord = AP$coordinates$x,
                                               y_coord = AP$coordinates$y)
      } else {
        missed_shots = NULL
      }


      ## TAKEAWAYS
      if (AP$result$eventTypeId == "TAKEAWAY") {
        takeaways <- data.table::data.table(eventid = unique_AP_id,
                                            gameid = pbp$gameData$game$pk,
                                            playerid = AP$players[[1]]$player$id,
                                            x_coord = AP$coordinates$x,
                                            y_coord = AP$coordinates$y)
      } else {
        takeaways = NULL
      }


      ## GIVEAWAYS
      if (AP$result$eventTypeId == "GIVEAWAY") {
        giveaways <- data.table::data.table(eventid = unique_AP_id,
                                            gameid = pbp$gameData$game$pk,
                                            playerid = AP$players[[1]]$player$id,
                                            x_coord = AP$coordinates$x,
                                            y_coord = AP$coordinates$y)
      } else {
        giveaways = NULL
      }


      ## HITS
      if (AP$result$eventTypeId == "HIT") {
        hits <- data.table::data.table(eventid = unique_AP_id,
                                       gameid = pbp$gameData$game$pk,
                                       hitter = AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Hitter')]]$player$id,
                                       hittee  = AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Hittee')]]$player$id,
                                       x_coord = AP$coordinates$x,
                                       y_coord = AP$coordinates$y)
      } else {
        hits = NULL
      }


      ## PENALTIES

      if (AP$result$eventTypeId == "PENALTY") {

        # This if for cases where the penalty doesn't have ANY players
        # like a TOO MANY MEN call
        if (is.null(AP$players)) {
          AP$players <- list(list(player = list(id = NA)),
                             list(player = list(id = NA)))
        }

        penalty_on_player <- tryCatch(AP$players[[1]]$player$id, error = function(e) {NA})
        penalty_drawn_by  <- tryCatch(AP$players[[2]]$player$id, error = function(e) {NA})

        penalties <- data.table::data.table(eventid = unique_AP_id,
                                            gameid = pbp$gameData$game$pk,
                                            penalty_on_player = penalty_on_player,
                                            penalty_drawn_by  = penalty_drawn_by,
                                            penalty_type = secondary_type,
                                            severity = AP$result$penaltySeverity,
                                            pim = AP$result$penaltyMinutes,
                                            x_coord = AP$coordinates$x,
                                            y_coord = AP$coordinates$y)
      } else {
        penalties = NULL
      }

      # Putting it all together
      final <- list(plays = out,
                    goals = goals,
                    assists = assists,
                    faceoffs = faceoffs,
                    shots = shots,
                    blocked_shots = blocked_shots,
                    missed_shots = missed_shots,
                    penalties = penalties,
                    takeaways = takeaways,
                    giveaways = giveaways,
                    hits = hits)
    } else {

      if (AP$result$eventTypeId %in% c("GOAL", "SHOT", "MISSED_SHOT")) {

        # May not have a goalie... in which case, we return NAs
        opp_goalie <- tryCatch(AP$players[[which(sapply(AP$players,'[[', 'playerType')=='Goalie')]],
                               error = function(e){list(player = list(id = NA, fullName = NA))})

        shooter <- tryCatch(AP$players[[1]], error = function(e) {list(player = list(id = NA, fullName = NA, success = NA))})

        res <- switch(AP$result$eventTypeId,
                      GOAL = "goal",
                      SHOT = "save",
                      MISSED_SHOT = "miss")

        # Result
        so_result <- data.table::data.table(eventid = unique_AP_id,
                                            gameid = pbp$gameData$game$pk,
                                            shooterid = shooter$player$id,
                                            shooter_name = shooter$player$fullName,
                                            success = ifelse(shooter$playerType == "Scorer", TRUE, FALSE),
                                            result = res,
                                            goalieid = opp_goalie$player$id,
                                            goalie_name = opp_goalie$player$fullName,
                                            x_coord = AP$coordinates$x,
                                            y_coord = AP$coordinates$y,
                                            team = AP$team$triCode)

      } else {
        so_result = NULL
      }

      final = list(shootout_results = so_result)

    }
    # Send FINAL back
    return(final)

  })

  # Here we'll need to split/combine everything in the parsed_plays
  # using of rbindlist(lapply(parsed_plays, '[[', 'INSERT-NAME-HERE'), fill = TRUE)
  game_data_to_grab <- unlist(unique(sapply(parsed_plays, names)))

  game_data <- lapply(game_data_to_grab, function(Z){
    return(
      data.table::rbindlist(lapply(parsed_plays, '[[', Z))
    )
  })

  # Add the names to the output
  names(game_data) <- game_data_to_grab

  # Slightly enrich shootout data
  if ("shootout_results" %in% game_data_to_grab) {
    # Add round and cumulative goals
    game_data$shootout_results[, c("round", "score") := list(1:.N, cumsum(success)),
                               by = "team"]

  }

  return(game_data)

}

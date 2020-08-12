#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(data.table)
library(lme4)

# Data Loading
p <- readRDS('data/active_players.RDS')
gl <- readRDS('data/goal_locations.RDS')
mod <- readRDS('data/model.RDS')
source('nhl-rink-plot.R')

#* @apiTitle Tiny NHL Data API
#* @apiDescription API that services select players, player stats, a plot for locations of goals for a given player, and the results of a predictive model for predicting fantasy points for the players next game.

#* Plot the goal locations of an individual skater (only 20182019 season)
#* @png
#*
#* @get /goalLocations/<pid>
function(pid) {
  glim <- gl[playerid == pid & season == '20182019']

  G <- viz_draw_rink() + ggplot2::geom_point(data =
                                               glim,
                                             ggplot2::aes(x = abs(x_coord), y = y_coord),
                                             size = 3,
                                             alpha = .75) +
    ggplot2::scale_x_continuous(limits = c(15,100))
  return(print(G))
}

#* Return Information about the Players.
#* @description Can be used to get playerids for other end points, or to provide data about specific players
#* @param playerid a player's ID
#* @param position player positions
#* @get /players
function(playerId, position) {

  # data P is loaded above and shared

  if (missing('playerId')) {
    playerId <- unique(p$playerid)
  }

  if (missing('position')) {
    position <- unique(p$pos)
  }


  return(
    p[playerid %in% playerId & pos %in% position]
  )


}


#* Get a Prediction of fantasy points for a given player
#*
#* playerid
#* @param meanGoals Mean goals over last three games
#* @param meanAssts Mean assists over last three games
#* @param meanShots Mean shots over last three games
#* @param meanFpts Mean fantasy points over last three games
#* @param meanToi Mean time-on-ice over last three games
#* @get /predFpts
function(playerid = '8471675',
         meanGoals = .66666,
         meanAssts = .66666,
         meanShots = 2.66666,
         meanFpts = 4.8333333,
         meanToi = 1074) {

  df <- data.frame(playerid = playerid,
                   mGoals = meanGoals,
                   mAssts = meanAssts,
                   mshots = meanShots,
                   mFpts = meanFpts,
                   mToi = meanToi)

  out <- data.frame(playerid = playerid,
                    predictedPts = predict(mod,df))

  return(out)

}

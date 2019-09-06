# ### NOTES
#
# # For player statistics
# 1. Rolling windows of mean, median, sd, mad on fantasy points with several windows (last 5 games, last 10 games, season-long)
# 2. simple slope of fit line for last 5/10 games fantasy points?
# 3. Breakdown of points by home-away
# 4. Points typically allowed to position by opposing team up to that points.
# 5. Team overall FPTS against
# 6. Days rest (0 == back-to-back situation)
# 7. Average time on powerplay
# 8. Average time on penalty kill

## Possible additions later
# 1. Change of time-zone?
# 2. player-specific matchups?
# 3. Time of game (afternoon, evening)

#############
## TODO::
# Change the connection to rely on a PSQL connection instead of a SQLite connection

#############
# BUGS

#############

## Functions for generating tables!
# Each will need --
  # connection, database name, schema name, and whatever is necessary for the function to work
    # That might be a list of playerIDs or gameIDs or years, whatever.

#'xxxxxxxxxxxxxxx player_info -- playerIDs
#'xxxxxxxxxxxxxxx boxscore_stats -- gameIDs
#'xxxxxxxxxxxxxxx schedule -- season, start-date, end-date
#'xxxxxxxxxxxxxxx play-by-play -- gameIDs
#'xxxxxxxxxxxxxxx team info -- season (fine to only pull current team and roster info, historical can be done later if needed)
#'xxxxxxxxxxxxxxx draft -- nothing
#'xxxxxxxxxxxxxxx prospects -- nothing


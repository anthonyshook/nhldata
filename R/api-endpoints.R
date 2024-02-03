
#'  API endpoints

# Game API takes a GAME ID and returns data
game_api <-  "https://api-web.nhle.com/v1/gamecenter/{{GAME_ID}}/boxscore"
pbp_api  <-  "https://api-web.nhle.com/v1/gamecenter/{{GAME_ID}}/play-by-play"

# Schedule API.  Endpoints are "NOW" or a specific DATE in YYYY-MM-DD format
# e.g., https://api-web.nhle.com/v1/schedule/2024-01-23
schedule_api <- 'https://api-web.nhle.com/v1/schedule/{{DATE}}'

# Teams (list of all available teams)
teams_api <- "https://api.nhle.com/stats/rest/en/team?"

# Expanded Rosters, YR to YR
## Note -- includes everybody who was on the team, even if not for a full year. (see Nick Bonino)
roster_api <- 'https://api-web.nhle.com/v1/roster/{{TEAMABBR}}/{{SEASON}}' # https://api-web.nhle.com/v1/roster/PIT/20222023

# General Player Data, this is pretty much everybody ever.
all_players_api <- 'https://search.d3.nhle.com/api/v1/search/player?culture=en-us&q=*&limit=100000'
single_player_api <- 'https://api-web.nhle.com/v1/player/{{PLAYER_ID}}/landing'

# player modifiers - add a season, like 20172018
# https://statsapi.web.nhl.com/api/v1/people/ID/stats Complex endpoint with
# lots of append options to change what kind of stats you wish to obtain
# We don't realyl use these right now, primarily because they're not necessary for compiling data
# HOWEVER, goalie stat API is probably GREAT for some critical goalie related stuff
skater_stat_api <- 'https://api.nhle.com/stats/rest/en/skater'
goalie_stat_api <- "https://api.nhle.com/stats/rest/en/goalie"

# This is a player level Game Log API.
# Better method might be _boxscore_ data, because that's slightly more reasonable to gather,
# and you can recreate gamelog from there.
game_log_api <-

## Shifts API
shifts_api <- 'https://api.nhle.com/stats/rest/en/shiftcharts?cayenneExp=gameId='

## Draft Data
# You can add YEAR with cayenneExp=draftYear=2023 like this:
### https://records.nhl.com/site/api/draft?cayenneExp=draftYear=2023
### This goes all the way back to 1963!!
draft_api = 'https://records.nhl.com/site/api/draft?'


#'  API endpoints

# Game API takes a GAME ID and returns data
game_api <-  "https://api-web.nhle.com/v1/gamecenter/{GAME_ID}/boxscore"
pbp_api  <-  "https://api-web.nhle.com/v1/gamecenter/{GAME_ID}/play-by-play"
game_story_api <- "https://api-web.nhle.com/v1/wsc/game-story/{GAME_ID}"
landing_api    <- "https://api-web.nhle.com/v1/gamecenter/{GAME_ID}/landing"

# Schedule API.  Endpoints are "NOW" or a specific DATE in YYYY-MM-DD format
# e.g., https://api-web.nhle.com/v1/schedule/2024-01-23
all_game_ids      <- 'https://api.nhle.com/stats/rest/en/game?cayenneExp=season={SEASON}%20and%20gameType={GAMETYPE}'
date_schedule_api <- 'https://api-web.nhle.com/v1/schedule/{{DATE}}'
club_schedule_api <- 'https://api-web.nhle.com/v1/club-schedule-season/{{TEAM}}/{{SEASON}}'

# Teams (list of all available teams) -- Can take some report framework stuff
teams_api <- "https://records.nhl.com/site/api/team"
franchise_api <-"https://records.nhl.com/site/api/franchise"

# Expanded Rosters, YR to YR
## Note -- includes everybody who was on the team, even if not for a full year. (see Nick Bonino)
roster_api <- 'https://api-web.nhle.com/v1/roster/{TEAM_ABBR}/{SEASON}' # https://api-web.nhle.com/v1/roster/PIT/20222023

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

## Shifts API
shifts_api <- "https://api.nhle.com/stats/rest/en/shiftcharts?cayenneExp=gameId={GAME_ID}"

## Draft Data
# You can add YEAR with cayenneExp=draftYear=2023 like this:
### https://records.nhl.com/site/api/draft?cayenneExp=draftYear=2023
### This goes all the way back to 1963!!
draft_api <- "https://records.nhl.com/site/api/draft"

## Season / Standings API
# Gives season start/end dates
season_api <- "https://api.nhle.com/stats/rest/en/season?cayenneExp=id={SEASON}"
standings_api <- "https://api-web.nhle.com/v1/standings/{DATE}"

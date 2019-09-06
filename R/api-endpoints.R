
#'  API endpoints

# Game API takes a GAME ID and returns data
game_api <-  "https://statsapi.web.nhl.com/api/v1/game/"

# Season level API takes season, and optionally "type" where
# 1 = preseason, 2 = regular season, 3 = playoffs, 4 = all-star
season_api <- 'https://statsapi.web.nhl.com/api/v1/schedule?&season='


# Teams
teams_api <- "https://statsapi.web.nhl.com/api/v1/teams"

# Expanded Rosters
# appending '&season=20092010' would give the roster at that seasons end
roster_api <- "https://statsapi.web.nhl.com/api/v1/teams?expand=team.roster"
ytd_stats  <- "https://statsapi.web.nhl.com/api/v1/teams?expand=team.stats"


# In this case, you append a player ID,
# like Kaspari Kapanen = 8477953
player_api <- "https://statsapi.web.nhl.com/api/v1/people/"

# player modifiers - add a season, like 20172018
# https://statsapi.web.nhl.com/api/v1/people/ID/stats Complex endpoint with
# lots of append options to change what kind of stats you wish to obtain
#
# Modifiers
player_stat_mod <- "/stats/?stats=homeAndAway&season="
gamelog_mod     <- "/stats/?stats=gameLog&season="

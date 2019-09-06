
# Script for generating the list masks, using specific games as guides
# JSONS won't work without making individuals for every repeated form
# That is -- a boxscore has an unknown number of players, thus,
# we can't do a json level relist, we'd have to one per player (so the bottom of
# each list structure, where no more lists occur.)
# Instead, we can make parsed-level masks.

player_mask <- c("id",
                "firstName",
                "lastName",
                "primaryNumber",
                "birthDate",
                "birthCity",
                "birthStateProvince",
                "birthCountry",
                "nationality",
                "height",
                "weight",
                "active",
                "captain",
                "alternateCaptain",
                "rookie",
                "shootsCatches",
                "rosterStatus",
                "currentTeam.id",
                "primaryPosition.abbreviation",
                "primaryPosition.name",
                "primaryPosition.type",
                "primaryPosition.code")

#Skater Template
skater_template<-c(
  "id",
  "gameID",
  "goals",
  "assists",
  "shots",
  "hits",
  "powerPlayGoals",
  "powerPlayAssists",
  "penaltyMinutes",
  "faceOffWins",
  "faceoffTaken",
  "faceOffPct",
  "takeaways",
  "giveaways",
  "shortHandedGoals",
  "shortHandedAssists",
  "blocked",
  "plusMinus",
  "timeOnIce",
  "evenTimeOnIce",
  "powerPlayTimeOnIce",
  "shortHandedTimeOnIce"
)

#Goalie Template
goalie_template<-c(
  "id",
  "gameID",
  "goals",
  "timeOnIce",
  "assists",
  "shots",
  "pim",
  "saves",
  "shots",
  "powerPlaySaves",
  "powerPlayShotsAgainst",
  "shortHandedSaves",
  "shortHandedShotsAgainst",
  "evenSaves",
  "evenShotsAgainst",
  "decision",
  "savePercentage",
  "powerPlaySavePercentage",
  "shortHandedSavePercentage",
  "evenStrengthSavePercentage"
)


usethis::use_data(player_mask, goalie_template, skater_template, internal = TRUE, overwrite = TRUE)

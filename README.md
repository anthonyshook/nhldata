README
================

# nhldata Package 

This package can be used to interact with the NHL.com API to pull hockey statistics.

## Installation

The package is not on CRAN, but can be installed from github via
``` r
install.packages("devtools")
library(devtools)
install_github("anthonyshook/nhldata")
```

## Building a database

The easiest way to interact with the data is to build a local database, and use DBI to connect to it.

The following code will build a brand new database:

``` r
# Set up a connection using whatever database flavor you like
# Note, this has been tested with PostgreSQL and SQLite, but should work with MySQL or MariaDB
# Here I'll use an internal function to set up a SQLite database connection for a DB called 'tempdb'
cn <- nhldata::connect_to_db(db_path = '/path/to/database.sqlite')

# Using that connection, we'll build tables with data from the 2016/2017 through 2019/2020 seasons
build_new_nhl_db(seasons = c('20162017', '20172018', '20182019', '20192020'), 
                 num_cores = 8, 
                 conn = cn)

DBI::dbDisconnect(cn)
```

The /inst/ folder contains two CSVs that describe the database that is build above:
* nhl_database_dict.csv -- tables, columns, and data-types
* nhl_database_indexes.csv -- The table names, and indexes that are built during schema construction

### Updating an existing database

A wrapper function to update an existing database with new data exists:
``` r
# Again, connect to your DB
cn <- nhldata::connect_to_db()

# Get all the NHL data for the past 15 days, and upsert it into the Database.
# This will handle duplicates for you, and only insert the new data
nhldata::update_nhl_database(look_back_days = 15, 
                             conn = cn)

```

## Accessing the Data without a database

You can simply pull data into R using fetch functions, but you usually have to build up to it.

``` r
# Fetch the games that occurred on a given day (2020-02-02)
games <- fetch_schedule(season = '20192020', start_date = '2020-02-02', end_date = '2020-02-02')

# find the game you want in the table and use the game ID to get data
# Here we'll look at the penguins and capitals
pens_at_caps <- fetch_boxscore_stats('2019020806')

# We can fetch play-by-play information too
pens_at_caps_pbp <- fetch_play_by_play('2019020806')

# At this point we only have IDs for players, so the easiest way to get the link between IDs and players is
# using the fetch_player_info function 
all_skaters <- do.call('rbind', lapply(pens_at_caps$skater_stats$playerid, fetch_player_info))
all_goalies <- do.call('rbind', lapply(pens_at_caps$goalie_stats$playerid, fetch_player_info))

```

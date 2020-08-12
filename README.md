README
================

## nhldata Package 

This package can be used to interact with the NHL.com API to pull hockey statistics.

### Building a database

The following code will build a brand new database:

``` r
# Set up a connection using whatever database flavor you like
# Note, this has been tested with PostgreSQL and SQLite, but should work with MySQL or MariaDB
# Here I'll use an internal function to set up a SQLite database connection for a DB called 'tempdb'
cn <- nhldata::connect_to_db()

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

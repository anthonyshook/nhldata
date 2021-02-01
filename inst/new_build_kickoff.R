# Database Build Kickoff Script

# Set up a connection
connection_type <- 'postgres'

cn <- nhldata::connect_to_db(type = connection_type,
                             dbname = 'hockey',
                             schema = 'nhl',
                             host = 'localhost',
                             port = 5432,
                             user = 'postgres',
                             password = Sys.getenv("NHL_PASS")
)

# Set the search path
DBI::dbSendQuery(cn, statement = 'SET search_path = nhl, public;')

nhldata::build_new_nhl_db(seasons = c('20152016', '20162017', '20172018', '20182019', '20192020'), num_cores = 8, conn = cn)
#build_new_nhl_db(seasons = c('20192020'), num_cores = 8, conn = cn)

DBI::dbDisconnect(cn)

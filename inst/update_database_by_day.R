# Database Update Kickoff Script

# Set up a connection
connection_type <- 'postgres'

cn <- nhldata::connect_to_db(type = connection_type,
                             dbname = 'hockey',
                             schema = 'nhl',
                             host = 'localhost',
                             port = 5432,
                             user = 'postgres',
                             password = Sys.getenv("NHL_PASS") # getPass::getPass()
)

# Set the search path
DBI::dbSendQuery(cn, statement = 'SET search_path = nhl, public;')

nhldata::update_nhl_database(look_back_days = 30, conn = cn)

DBI::dbDisconnect(cn)

rm(cn)

# Database Update Kickoff Script

# Set up a connection
connection_type <- 'postgres'
read_pass_file <- readLines('D:/RPkgs/Secrets/nhl-pw.txt')

cn <- nhldata::connect_to_db(type = connection_type,
                             dbname = 'hockey',
                             schema = 'nhl',
                             host = 'localhost',
                             port = 5432,
                             user = 'postgres',
                             password = read_pass_file # Sys.getenv("NHL_PASS") # getPass::getPass()
)

# Set the search path
DBI::dbSendQuery(cn, statement = 'SET search_path = nhl, public;')

nhldata::update_nhl_database(look_back_days = 90, conn = cn)

DBI::dbDisconnect(cn)

rm(cn)



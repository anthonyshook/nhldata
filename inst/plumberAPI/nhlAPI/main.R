library(plumber)

r <- plumb("plumber.R")
r$run(port=200, host="0.0.0.0")

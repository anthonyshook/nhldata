% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build-teams-tables.R
\name{build_teams_tables}
\alias{build_teams_tables}
\title{Build teams tables}
\usage{
build_teams_tables(seasons, conn = connect_to_db())
}
\arguments{
\item{seasons}{A vector of seasons (format: 20182019)}

\item{conn}{A connection to a database - defaults to creating a new one}

\item{return_playerids}{If TRUE, will return all the player IDs (Default = True)}
}
\description{
The internals here are hard-coded, as this is not meant to be
something used outside of the current process, at the moment.
In the future, perhaps something config-based could be created
This is meant to create the table brand new, not update it. If the table already
exists, it will be re-written by running this function.
Builds Roster and Teams tables
}
